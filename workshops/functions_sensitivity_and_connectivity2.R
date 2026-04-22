# Hi folks, this is Tim Fraser!
# Here's a tentative fix for some issues in the connectivity() function.

# functions_sensitivity_and_connectivity2.R
# Fixed + Rcpp-accelerated versions
# -------------------------------------------------------
# BUG FIXED (connectivity):
#   Original me_ij() produced NaN when filtering dj != value_j left only one
#   unique value of di (so mean(m[di == FALSE]) was mean(numeric(0)) = NaN).
#   Also, abs(diff(stat)) inside connectivity_ij was applied on an unordered
#   grouped tibble, risking wrong pairing of notj=TRUE vs notj=FALSE rows.
#
# FIXES APPLIED:
#   1. me_ij()           — added na.rm = TRUE throughout; return NA (not NaN)
#                          when a group is empty/degenerate.
#   2. sensitivity_ij()  — propagate na.rm = TRUE.
#   3. connectivity_ij() — sort rows by notj before diff() so pairing is
#                          deterministic; use na.rm = TRUE in final mean.
#   4. Rcpp versions     — drop-in C++ replacements for inner hot-loops,
#                          wrapped in R functions with identical signatures.
#
# DEFINITION (Bartolomei & Hastings / DSM literature):
#   Sensitivity(i)      = mean over values v of |E[m | di=v] - E[m | di≠v]|
#   Connectivity(i,j)   = mean over values j of |S(i|dj=j) - S(i|dj≠j)|
#   Connectivity(i)     = mean over all j≠i of Connectivity(i,j)
# -------------------------------------------------------

library(tidyverse)
library(Rcpp)
library(RcppArmadillo)  # only needed for fast matrix ops; remove if not installed

# ============================================================
# SECTION 1 – Pure-R versions (fixed)
# ============================================================

#' Main effect of setting decision_i = value vs. everything else
me <- function(data, decision = "d2", value = 1, metric = "m1") {
  data %>%
    select(any_of(c(alt = decision, metric = metric))) %>%
    mutate(decision = decision) %>%
    select(decision, alt, metric) %>%
    summarize(
      xhat = mean(metric[alt == value],  na.rm = TRUE),
      x    = mean(metric[alt != value],  na.rm = TRUE),
      dbar = xhat - x
    ) %>%
    pull(dbar)
}

#' Sensitivity of decision_i (mean absolute main effect over all its values)
sensitivity <- function(data, decision_i = "d2", metric = "m1") {
  values <- sort(unique(data[[decision_i]]))
  mes    <- vapply(values, function(v) me(data, decision = decision_i, value = v, metric = metric), numeric(1))
  mean(abs(mes), na.rm = TRUE)
}

#' Conditional main effect of decision_i=value_i, given decision_j == or != value_j
#'
#' FIX: return NA (not NaN) when either conditional group is empty/degenerate.
me_ij <- function(data, decision_i, value_i, decision_j, value_j,
                  metric = "m1", notj = FALSE) {
  d <- data %>%
    select(any_of(c(di = decision_i, dj = decision_j, m = metric)))

  d <- if (notj) filter(d, dj != value_j) else filter(d, dj == value_j)

  # Safety: if fewer than 2 distinct di values survive, effect is undefined
  di_vals <- unique(d$di)
  if (length(di_vals) < 2) return(NA_real_)

  d %>%
    mutate(di = (di == value_i)) %>%
    summarize(
      xhat = mean(m[di == TRUE],  na.rm = TRUE),
      x    = mean(m[di == FALSE], na.rm = TRUE),
      diff = xhat - x
    ) %>%
    pull(diff)
}

#' Sensitivity of decision_i conditional on decision_j being fixed/excluded at value_j
sensitivity_ij <- function(data, decision_i, decision_j, value_j,
                            metric = "m1", notj = FALSE) {
  values_i <- sort(unique(data[[decision_i]]))
  mes <- vapply(
    values_i,
    function(v) me_ij(data, decision_i = decision_i, value_i = v,
                      decision_j = decision_j, value_j = value_j,
                      metric = metric, notj = notj),
    numeric(1)
  )
  mean(abs(mes), na.rm = TRUE)
}

#' Connectivity between decision_i and decision_j
#'
#' FIX: arrange by notj so diff() always computes (notj=TRUE) - (notj=FALSE)
#'      i.e., |S(i|dj≠j) - S(i|dj=j)| for each value j of decision_j.
connectivity_ij <- function(data, decision_i, decision_j = "d2", metric = "m1") {
  values_j <- sort(unique(data[[decision_j]]))

  result <- map_dfr(values_j, function(vj) {
    s_given    <- sensitivity_ij(data, decision_i, decision_j, vj, metric, notj = FALSE)
    s_excluded <- sensitivity_ij(data, decision_i, decision_j, vj, metric, notj = TRUE)
    tibble(value_j = vj, delta = abs(s_excluded - s_given))
  })

  mean(result$delta, na.rm = TRUE)
}

#' Total connectivity of decision_i across all other decisions
connectivity <- function(data, decision_i = "d3",
                         decisions = c("d1", "d2", "d3"), metric = "m1") {
  other <- setdiff(decisions, decision_i)
  stats <- vapply(other, function(dj)
    connectivity_ij(data, decision_i = decision_i, decision_j = dj, metric = metric),
    numeric(1))
  mean(stats, na.rm = TRUE)
}


# ============================================================
# SECTION 2 – Rcpp versions (drop-in replacements, much faster)
# ============================================================
# These implement the same math entirely in C++ via Rcpp.
# They accept the same R data.frame + string arguments as the pure-R versions.
# Compile once per session with sourceCpp() or embed via cppFunction().

cppFunction('
// Fast conditional mean helper
// vec    : numeric metric vector
// flag   : logical vector (di == value_i)
// which  : TRUE = mean where flag is TRUE, FALSE = mean where flag is FALSE
double cond_mean(NumericVector vec, LogicalVector flag, bool which) {
  double s = 0.0; int n = 0;
  for (int k = 0; k < vec.size(); k++) {
    if (!NumericVector::is_na(vec[k]) && flag[k] == which) { s += vec[k]; n++; }
  }
  return (n == 0) ? NA_REAL : s / n;
}
', includes = '#include <Rcpp.h>')

cppFunction('
// me_ij_cpp: conditional main effect of di=value_i given dj==value_j or dj!=value_j
// [[Rcpp::export]]
double me_ij_cpp(NumericVector di_vec, NumericVector dj_vec, NumericVector m_vec,
                 double value_i, double value_j, bool notj) {
  int n = di_vec.size();
  // Filter by dj condition
  std::vector<double> di_f, m_f;
  for (int k = 0; k < n; k++) {
    bool dj_cond = notj ? (dj_vec[k] != value_j) : (dj_vec[k] == value_j);
    if (dj_cond) { di_f.push_back(di_vec[k]); m_f.push_back(m_vec[k]); }
  }
  // Need at least 2 distinct values of di
  std::set<double> di_uniq(di_f.begin(), di_f.end());
  if (di_uniq.size() < 2) return NA_REAL;

  double s1 = 0, s0 = 0; int n1 = 0, n0 = 0;
  for (size_t k = 0; k < di_f.size(); k++) {
    if (std::isnan(m_f[k])) continue;
    if (di_f[k] == value_i) { s1 += m_f[k]; n1++; }
    else                     { s0 += m_f[k]; n0++; }
  }
  double xhat = (n1 == 0) ? NA_REAL : s1 / n1;
  double x    = (n0 == 0) ? NA_REAL : s0 / n0;
  if (std::isnan(xhat) || std::isnan(x)) return NA_REAL;
  return xhat - x;
}
', includes = '#include <Rcpp.h>\n#include <set>\n#include <cmath>')

cppFunction('
// sensitivity_ij_cpp: mean |me_ij| over all values of di
// [[Rcpp::export]]
double sensitivity_ij_cpp(NumericVector di_vec, NumericVector dj_vec, NumericVector m_vec,
                           double value_j, bool notj) {
  std::set<double> vals(di_vec.begin(), di_vec.end());
  double s = 0.0; int cnt = 0;
  for (double vi : vals) {
    // Filter for dj condition
    std::vector<double> di_f, m_f;
    int n = di_vec.size();
    for (int k = 0; k < n; k++) {
      bool dj_cond = notj ? (dj_vec[k] != value_j) : (dj_vec[k] == value_j);
      if (dj_cond) { di_f.push_back(di_vec[k]); m_f.push_back(m_vec[k]); }
    }
    std::set<double> di_uniq(di_f.begin(), di_f.end());
    if (di_uniq.size() < 2) continue;

    double s1 = 0, s0 = 0; int n1 = 0, n0 = 0;
    for (size_t k = 0; k < di_f.size(); k++) {
      if (std::isnan(m_f[k])) continue;
      if (di_f[k] == vi) { s1 += m_f[k]; n1++; }
      else               { s0 += m_f[k]; n0++; }
    }
    if (n1 == 0 || n0 == 0) continue;
    double effect = std::abs(s1/n1 - s0/n0);
    s += effect; cnt++;
  }
  return (cnt == 0) ? NA_REAL : s / cnt;
}
', includes = '#include <Rcpp.h>\n#include <set>\n#include <cmath>')

# R wrapper: connectivity_ij using Rcpp inner loops
connectivity_ij_fast <- function(data, decision_i, decision_j = "d2", metric = "m1") {
  di_vec <- as.numeric(data[[decision_i]])
  dj_vec <- as.numeric(data[[decision_j]])
  m_vec  <- as.numeric(data[[metric]])

  values_j <- sort(unique(dj_vec))

  deltas <- vapply(values_j, function(vj) {
    s_given    <- sensitivity_ij_cpp(di_vec, dj_vec, m_vec, vj, notj = FALSE)
    s_excluded <- sensitivity_ij_cpp(di_vec, dj_vec, m_vec, vj, notj = TRUE)
    abs(s_excluded - s_given)
  }, numeric(1))

  mean(deltas, na.rm = TRUE)
}

# R wrapper: sensitivity using Rcpp
sensitivity_fast <- function(data, decision_i = "d2", metric = "m1") {
  di_vec <- as.numeric(data[[decision_i]])
  m_vec  <- as.numeric(data[[metric]])
  # Use a dummy dj that's always equal so notj=FALSE gives all rows
  dj_dummy <- rep(1, nrow(data))
  sensitivity_ij_cpp(di_vec, dj_dummy, m_vec, value_j = 1, notj = FALSE)
}

# R wrapper: total connectivity (fast)
connectivity_fast <- function(data, decision_i = "d3",
                              decisions = c("d1", "d2", "d3"), metric = "m1") {
  other <- setdiff(decisions, decision_i)
  stats <- vapply(other, function(dj)
    connectivity_ij_fast(data, decision_i = decision_i, decision_j = dj, metric = metric),
    numeric(1))
  mean(stats, na.rm = TRUE)
}


# ============================================================
# SECTION 3 – Quick smoke test
# ============================================================
if (FALSE) {
  # Generate a small synthetic design space
  set.seed(42)
  n  <- 3   # values per decision
  dg <- expand.grid(d1 = 1:n, d2 = 1:n, d3 = 1:n) %>%
    as_tibble() %>%
    mutate(m1 = d1 * 0.5 + d2 * 1.2 - d3 * 0.3 + rnorm(n()))

  # Pure-R
  cat("sensitivity (R)    :", sensitivity(dg, "d2", "m1"), "\n")
  cat("connectivity_ij (R):", connectivity_ij(dg, "d3", "d2", "m1"), "\n")
  cat("connectivity (R)   :", connectivity(dg, "d3", c("d1","d2","d3"), "m1"), "\n")

  # Rcpp
  cat("sensitivity (fast) :", sensitivity_fast(dg, "d2", "m1"), "\n")
  cat("connectivity_ij (F):", connectivity_ij_fast(dg, "d3", "d2", "m1"), "\n")
  cat("connectivity (fast):", connectivity_fast(dg, "d3", c("d1","d2","d3"), "m1"), "\n")

  # Benchmark
  library(bench)
  bench::mark(
    R    = connectivity(dg, "d3", c("d1","d2","d3"), "m1"),
    Rcpp = connectivity_fast(dg, "d3", c("d1","d2","d3"), "m1"),
    check = FALSE
  )
}
