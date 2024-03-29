% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/part4_functions.R
\name{evaluate_tidy}
\alias{evaluate_tidy}
\title{Evaluate Architecture Metrics in a Tidyverse-Friendly Way}
\usage{
evaluate_tidy(par, d, vars = NULL, c = NULL, invalid = 0)
}
\arguments{
\item{par}{architecture(s), either as a vector of integers or a tibble of architectures}

\item{d}{data.frame of decision-alternative items}

\item{vars}{vector of metric names. Must be columns in \code{d}.}

\item{c}{(Optional) data.frame of constraints.}

\item{invalid}{value that an invalid architecture receives.}
}
\description{
Let's write an evaluate function that will, for any enumerated tidy data.frame,
join in your metrics and compute them, then return a final dataframe
Only works with \code{data.frames} generated by \code{enumerate()}. Soon to be deprecated. Encourage users to make their own \code{evaluate()} functions.
}
\details{
PART 4 FUNCTIONS
This script contains a series of functions that allow for evaluating architectural matrices/data.frames.

Some of these are internal functions, while others are functions intended to be used by actual R users.
If you encounter an issue with any of these functions, please tag it in a Github Issue.
}
\author{
Tim Fraser
}
