# Script: 13_enumeration_sample_sizing.R
# Original: example_size.R
# Topic: Minimum sample sizing utility
# Section: Enumeration
# Developed by: Timothy Fraser, PhD
# example_size.R

# A script and function to test 
# **How many architectures do I need in my sample?**


#' @name get_minsize
#' @title Get Minimum Number of Architectures to test Main Effects
#' @param data data.frame of enumerated architectures, where columns are decisions and values are alternatives
#' @param decisions:[str] string vector of decisions you want to test main effects for. Defaults to 1.
#' @importFrom dplyr `%>%` select any_of summarize everything across
#' @importFrom tidyr pivot_longer
get_minsize = function(data, decisions = c("d1")){
  library(dplyr)
  library(tidyr)
  
  data %>%
    select(any_of(decisions)) %>%
    # Count up k, the number of unique alternatives per decision
    summarize(across(everything(), .fns = ~length(unique(.x)))) %>%
    # Pivot it longer
    tidyr::pivot_longer(
      cols = everything(), 
      names_to = "k", values_to = "value") %>%
    # Count up the minimum number of architectures necessary to test
    # that number of main effects
    summarize(minsize = 1 + sum(value - 1)) %>%
    # Return it as a vector
    with(minsize)        
}



library(dplyr)
library(tidyr)
library(archr)

a = enumerate_sf(n = c(2,5,4))

# to count sample size needed...
get_minsize(a, decisions = c("d1"))
get_minsize(a, decisions = c("d1", "d2"))
get_minsize(a, decisions = c("d1", "d2", "d3"))


rm(list = ls())
