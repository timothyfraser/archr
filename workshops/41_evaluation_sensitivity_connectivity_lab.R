# Script: 41_evaluation_sensitivity_connectivity_lab.R
# Original: tutorial_sensitivity_and_connectivity.R
# Topic: Sensitivity and connectivity lab
# Section: Evaluation
# Developed by: Timothy Fraser, PhD
# Sensitivity and Connectivity Functions

# DATA ###########################
# Enumerate Architectures
# This perfectly replicates the example 
# from Slides in Class

library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)
library(archr)

source("workshops/00_sensitivity_connectivity_utilities.R")

# Replicate the exact data structure from the slides
data = enumerate_sf(n = c(2, 3, 2)) %>%
  # Add metrics
  mutate(m1 = c(33,73, 40, 80, 30, 70, 66, 146, 80, 160, 60, 140),
         m2 = c(0.8910, 0.9801, 0.8991, 0.9890, 0.4500, 0.4950, 0.9899, 0.9998, 0.9900, 0.9999, 0.7425, 0.7499)) %>%
  mutate(d1 = d1 + 1, d2 = d2 + 1, d3 = d3+1) %>%
  select(d1 = d3, d2 = d2, d3 = d1, m1, m2) 

data

# me(data, decision = "d2", value = 1, metric = "m1")
# 
# me_ij(data, 
#       decision_i = "d3", value_i = 1, 
#       decision_j = "d2", value_j = 1, 
#       notj = FALSE, metric = "m1")
# 
# sensitivity_ij(data, decision_i = "d3", decision_j = "d2", value_j = 1, metric = "m1", notj = FALSE)
# sensitivity_ij(data, decision_i = "d3", decision_j = "d2", value_j = 2, metric = "m1", notj = FALSE)
# sensitivity_ij(data, decision_i = "d3", decision_j = "d2", value_j = 1, metric = "m1", notj = TRUE)
# sensitivity_ij(data, decision_i = "d3", decision_j = "d2", value_j = 2, metric = "m1", notj = TRUE)
# 
# sensitivity_ij(data, decision_i = "d3", decision_j = "d2", 
#                value_j = 1, metric = "m1", notj = FALSE)
# sensitivity_ij(data, decision_i = "d3", decision_j = "d2", 
#                value_j = 1, metric = "m1", notj = TRUE)
# sensitivity_ij(data, decision_i = "d3", decision_j = "d2", 
#                value_j = 2, metric = "m1", notj = FALSE)
# sensitivity_ij(data, decision_i = "d3", decision_j = "d2", 
#                value_j = 2, metric = "m1", notj = TRUE)
# sensitivity_ij(data, decision_i = "d3", decision_j = "d2", 
#                value_j = 3, metric = "m1", notj = FALSE)
# sensitivity_ij(data, decision_i = "d3", decision_j = "d2", 
#                value_j = 3, metric = "m1", notj = TRUE)
# 
# 
# connectivity_ij(data, decision_i = "d3", decision_j = "d2", metric = "m1" )
# connectivity_ij(data, decision_i = "d3", decision_j = "d1", metric = "m1" )
# 
# 
# connectivity(data, decision_i = "d1", decisions = c("d1","d2","d3"), metric = "m1")
# connectivity(data, decision_i = "d2", decisions = c("d1","d2","d3"), metric = "m1")
# connectivity(data, decision_i = "d3", decisions = c("d1","d2","d3"), metric = "m1")
# connectivity(data, decision_i = "d1", decisions = c("d1","d2","d3"), metric = "m2")
# connectivity(data, decision_i = "d2", decisions = c("d1","d2","d3"), metric = "m2")
# connectivity(data, decision_i = "d3", decisions = c("d1","d2","d3"), metric = "m2")


#' @param data data.frame of decisions and metrics
#' @param decision_i eg. "d2"
#' @param decisions a vector of all your decisions eg. c("d1","d2","d3")
#' @param metric eg. "m1"
connectivity(data = data, decision_i = "d2", decisions = c("d1","d2","d3"), metric = "m1")

#' @param data data.frame of decisions and metrics
#' @param decision_i eg. "d2"
#' @param metric eg. "m1"
sensitivity(data = data,decision_i = "d2", metric = "m1") 


# VISUAL ###################################
points = expand_grid(
  decision = c("d1","d2","d3"),
  metric = c("m1","m2")
) %>%
  group_by(decision, metric) %>%
  #rowwise() %>% 
  summarize(
    c = connectivity(data = data, decision_i = decision, decisions = c("d1","d2","d3"), metric = metric),
    s = sensitivity(data = data, decision_i = decision, metric = metric),
    .groups = "drop"
  )

points

# sensitivity checks out perfectly.
# connectivity is really darn close to the graph in the slides; to the best of my knowledge, our calculation is correct.

ggplot() +
  geom_point(data = points, mapping = aes(
    x = c, y = s, color = decision),
    size = 10) +
  geom_text(data = points, mapping = aes(
    x = c, y = s, label = decision), 
    color = "white") +
  facet_wrap(~metric, scales = "free") +
  theme(legend.position = "none") 

pointsm1 = points %>%
  filter(metric == "m1")


ggplot() +
  geom_point(data = pointsm1, mapping = aes(
    x = c, y = s, color = decision),
    size = 10) +
  geom_text(data = pointsm1, mapping = aes(
    x = c, y = s, label = decision), 
    color = "white") +
  theme(legend.position = "none") +
  geom_vline(xintercept = 12.5) +
  geom_hline(yintercept = 30) +
  scale_x_continuous(limits = c(0, 25)) +
  scale_y_continuous(limits = c(0, 60)) +
  labs(x = "Connectivity Score (Metric X)",
       y = "Sensitivity Score (Metric X)")



