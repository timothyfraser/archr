# Script: 22_evaluation_failure_rates.R
# Original: example_failure_rates.R
# Topic: Failure rates primer
# Section: Evaluation
# Developed by: Timothy Fraser, PhD
# example_failure_rates.R

# Introduction to Failure Rates and Related Measures


# Load necessary libraries
library(dplyr)
library(ggplot2)

# 1. Reliability
# Let's learn some key terms.

# Lifespan Distribution: distribution (PDF) for a vector of product lifespans.
# Reflects the probability that a product failed after X hours or years
# Eg. Here's a vector of 10 items' lifespans, in hours.
products = c(24, 273, 41, 282, 14, 210, 325, 276, 96, 149)

products %>% hist()

products %>% density() %>% plot()

ggplot() +
  geom_density(data = tibble(products), mapping = aes(x = products))


# Mean Time to Failure: the mean of a lifespan distribution.
# Describes the average hours to failure per unit.
# Eg. let's get the MTTF for our products' life distribution.
mu = mean(products)

mu

# Failure Rate (Lambda): inverse of mean time to failure.
# Describes the average number of times a product fails per time-step (eg. per hour).
# Eg. let's get the Failure Rate for our products' life distribution.
lambda = 1 / mean(products)
lambda


# Exponential Distribution: a common form for lifespan distributions,
# characterized by one parameter, lambda.
# If you have lambda, you can get the MTTF.
# Eg. what's the cumulative probability of a product failing 
# at or before 100 hours, given an Exp. Distr. with MTTF mu?
pexp(100, rate = 1/mu)

# F(t) = 1 - exp(-lambda * t)
# F(t) = 1 - e^(-lambda*t)

# Probability of Failure F(t): cumulative probability of failure by time t.
# expcdf() will give you F(t) in an exponential distribution.
# Probability of Reliability/Survival R(t): cumulative probability it DOESN'T fail by time t.
# For example, R(t = 100) = 1 - expcdf(100, mu).
# Eg. what's the cumulative probability of product survives for 100 hours,
# given an Exp. Distr. with MTTF mu?
1 - pexp(100, rate = 1/mu)


# HOW TO VISUALIZE?

# Take a random sample!
rexp(n = 1000, rate = 1 / mu) %>% hist()

rexp(n = 1000, rate = 1 / mu) %>% density() %>% plot()

data = tibble(t = rexp(n = 1000, rate = 1 / mu))
ggplot() +
  geom_density(data = data, mapping = aes(x = t))

ggplot() +
  geom_density(data = data, mapping = aes(x = t))

# Cleanup!
rm(list = ls())
