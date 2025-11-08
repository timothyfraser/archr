# Script: 26_evaluation_system_reliability.R
# Original: example_system_reliability.R
# Topic: System reliability evaluation
# Section: Evaluation
# Developed by: Timothy Fraser, PhD
# example_system_reliability.R

# Intro to System Reliability

# System reliability refers to modeling the reliability of an entire system using
# information about the components in that system. Let's learn how!

# Setup ###################################################
# Load Packages!
library(dplyr)
library(ggplot2)

# Series System #########################################
# Series System: a system that requires each successive component to work. (Like a chain of dominos.)
# eg. [ A --> B --> C ]
# Series System Reliability: Chance all components survive. Written: R_s(t) = R_a(t) x R_b(t) x R_c(t).

# Suppose at time t = 100 hours...
r_a = 0.88
r_b = 0.99
r_c = 0.95
# 82% chance that the whole system stays reliable for 100 hours
r_a * r_b * r_c



# My coffee shop's system has 3 serially-connected components:
# A = coffee maker (MTTF = 500 hours)
# B = bean grinder (MTTF = 5000 hours)
# C = dishwasher   (MTTF = 1000 hours) 
# What's the probability the system survives 100 hours?
t <- 100

# Reliability of A (coffee maker) by time t
# R_a(t) = 1 - F_a(t)
r_a <- 1 - pexp(t, rate = 1/500)

# Reliability of B (bean grinder) by time t
r_b <- 1 - pexp(t, rate = 1/5000)

# Reliability of C (dishwasher) by time t
r_c <- 1 - pexp(t, rate = 1/1000)

# Reliability of System by time t = 100
r_s <- r_a * r_b * r_c
r_s


# Parallel System #########################################

# Parallel System: a system that requires just 1 of multiple components to function. eg. [A1 or A2 or A3]
# Parallel System Reliability: Chance 1 of the components survives = 1 - probability ALL components fail. 
# Written: R_s(t) = 1 - ( F_a1(t) x F_a2(t) x F_a3(t) )

# Suppose we buy 3 coffee makers - as long as one works, we can maintain
# the system.
r_a1 <- r_a
r_a2 <- r_a
r_a3 <- r_a

# Let's find chance at least 1 remains functional.
r_a_parallel <- 1 - prod(1 - c(r_a1, r_a2, r_a3))
r_a_parallel

# If series
r_a1 * r_a2 * r_a3


# Combination Systems #########################################

# System Reliability: Using combinations of parallel and series systems, compute the reliability of the overall system!

# We could compute the reliability of the overall system at time t like so!
overall_reliability <- r_a_parallel * r_b * r_c
overall_reliability


# Comparing System vs. Component Reliability #########################################

# Demonstrate that Success of the System is much lower than Success of the Components

cpu = 0.99
keys = 0.98
keys2 = 0.999999999999
display = 0.96
mouse = 0.95
# Reliability of your system is just 88%
cpu * keys * display * mouse

# Two keys = 86%
cpu * keys^2 * display * mouse

# All keys = 40% 
cpu * keys^40 * display * mouse

# All keys = 40% 
cpu * keys2^40 * display * mouse


# Cleanup
rm(list = ls())
