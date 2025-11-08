# Script: 24_evaluation_monte_carlo.R
# Original: example_monte_carlo.R
# Topic: Monte Carlo evaluation
# Section: Evaluation
# Developed by: Timothy Fraser, PhD
#' @name example_monte_carlo.R
#' @author Tim Fraser

# This script demonstrates how to run 
# monte-carlo simulations to measure uncertainty in a metric.


# SETUP ##########################################################
# Load required libraries
library(dplyr)
library(ggplot2)

# EX1: MONTE CARLO SIMULATION #############################################

r = tibble(
  mu = 500 # miles
)
# mean time to failure! = mean miles travelled
# failure rate = 1 / mean time to failure
# use it in an exponential distribution
# take 1000 random samples from that distribution

r2 = r %>%
  reframe(sim = rexp(n = 1000, rate = 1 / mu))

r3 = r2 %>%
  summarize(
    p50 = quantile(sim, probs = 0.50),
    p75 = quantile(sim, probs = 0.75),
    sd = sd(sim),
    mean = mean(sim),
    max = max(sim),
    min = min(sim),
    p99 = quantile(sim, prob = 0.99),
    p01 = quantile(sim, prob = 0.01)
  )

r3


# EX2: MONTE CARLO SIMULATION ###################################

library(archr)
library(dplyr)

# Say we've got 3 binary decisions
# d1 = EIRP of transmitter  (option 1 vs. option 0)
# d2 = G/T of receiver  (option 1 vs. option 0)
# d3 = Slant Range (option 1 vs. option 0)
a = archr::enumerate_binary(n = 3)

# Let's write a function that will help us 
# measure performance while incorporating uncertainty!

get_performance = function(d1,d2,d3, n = 1000, benchmark = 0){
  
  # testing values
  # d1 = 1; d2 = 1; d3 = 1; n = 1000; benchmark = 0;
  
  # d1 = EIRP of transmitter  (option 1 vs. option 0)
  sim1 = case_when(d1 == 1 ~ rnorm(n = n, mean = 30, sd = 5),
                 d1 == 0 ~ rnorm(n = n, mean = 0, sd = 0) )
  # d2 = G/T of receiver  (option 1 vs. option 0)
  sim2 = case_when(d2 == 1 ~ rnorm(n = n, mean = 0, sd = 2),
                 d2 == 0 ~ rnorm(n = n, mean = 0, sd = 0))
  # d3 = Slant Range (option 1 vs. option 0)
  sim3 = case_when(d3 == 1 ~ rnorm(n = n, mean = 4, sd = 2),
                   d3 == 0 ~ rnorm(n = n, mean = 0, sd = 0))
    
  # Get total simulated metrics
  sim = sim1 + sim2 + sim3
  
  # Calculate percentage that are less than benchmark!
  metric = sum(sim < benchmark) / length(sim)

  return(metric)
}

get_performance(d1 = 1, d2 = 2, d3 = 3, n = 1000, benchmark = 0)



# EX3: MONTE CARLO SIMULATION ###################################

# Additional options for processing metrics

library(archr)
library(dplyr)

# Say we've got 3 binary decisions
# d1 = EIRP of transmitter  (option 1 vs. option 0)
# d2 = G/T of receiver  (option 1 vs. option 0)
# d3 = Atmospheric Losses (option 1 vs. option 0)
a = archr::enumerate_binary(n = 3)



get_performance = function(d1, d2, d3, n, benchmark){
  # Testing values
  # d1 = 1; d2 = 1; d3 = 1; n = 100; benchmark = 30  
  
  # Performance = Quality of Connectivity (dB)
  
  # transmitter
  # m1 = case_when(d1 == 1 ~ 30,  d1 == 0 ~ 0)
  sim1 = case_when(d1 == 1 ~ rnorm(n = n, mean = 30, sd = 5), 
                   d1 == 0 ~ rnorm(n = n, mean = 0, sd = 0) )
  # receiver
  sim2 = case_when(d2 == 1 ~ rnorm(n = n, mean = 0, sd = 2),
                   d2 == 0 ~ rnorm(n = n, mean = 0, sd = 0) )
  # climate that the tech is deployed in
  sim3 = case_when(d3 == 1 ~ rnorm(n = n, mean = 4, sd = 2),
                   d3 == 0 ~ rnorm(n = n, mean = 0, sd = 0))
  # combine
  sims = sim1 + sim2 + sim3 
  
  # sims %>% hist()
  # Option 1
  # metric = mean(sims)

  # Option 2
  # metric = sd(sims)
  
  # Option 3
  # metric = sd(sims)
  # metric = metric < benchmark
  
  # Option 4
  metric = sum(sims < benchmark) / n
  
  return(metric)
}

get_performance(d1 = 1, d2 = 1, d3 = 1, n = 100, benchmark = 2)
get_performance(d1 = 0, d2 = 0, d3 = 0, n = 100, benchmark = 2)

get_performance(d1 = 1, d2 = 1, d3 = 1, n = 100, benchmark = 30)

# Let's calculate performance here 'rowwise'
a %>% 
  rowwise() %>%
  mutate(m1 = get_performance(d1 = d1, d2 = d2, d3 = d3, n = 1000, benchmark = 30)) %>%
  ungroup()











