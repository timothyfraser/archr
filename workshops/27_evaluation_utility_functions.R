# Script: 27_evaluation_utility_functions.R
# Original: example_utility_functions.R
# Topic: Utility function design
# Section: Evaluation
# Developed by: Timothy Fraser, PhD
# example_utility_functions.R

# Script to demonstrate how to make utility functions in R!


# Setup #################################################
library(dplyr)
library(ggplot2)

# What's a Utility Function? ########################################

# As discussed in Lecture Evaluation III, 
# utility functions are functions that tell us 
# the utility (value-added) of a technology, called u(x), 
# given one or more predictors (called x). 

# These functions tend to be models (best fitting lines) 
# that approximate the relationship between x and u(x), 
# observed and recorded for a technology dozens and dozens of times.

# Utility functions can help us make decisions in our architecture 
# when it is not immediately clear which alternative(s) we should select.
# When multiple attributes (x-es) contribute to
# the utility of a decision/technology,
# we can form **multi-attribute** or **multi-linear** utility functions
# to combine them. 

# The key requirement is, 
# the attributes you are combining need to be independent; 
# otherwise, you'll be overweighting or doublecounting 
# some attributes more than others.

# Here are several ways to build utility functions to multiple attributes.


# EX1: Drone Utility ###############################

# Let's do a quick example.
# Let's say you're deploying your donut-delivery system, 
# and you're deciding whether to develope a drone-delivery system or not.

# Let's say it's not entirely certain that 
# your drone-delivery subsystem will work.
# Maybe it has a chance of failure of 5%, 
# so the chance it works reliably is 95%. 
# The payoff of this drone delivery system working is $10,000. 
# In contrast, if the drone delivery system fails, you will owe $5000! 

# Let's calculate the expected utility from this uncertain choice.

# Define probabilities
p_fail = 0.05
p_works = 1 - p_fail

# Define utility function for pay
# Choose what means min utility (0) for you
pay_min = 0
# Choose what means max utility (1) for you
pay_max = 10000


# Calculate utility of drone working (by rescaling)
pay_works = 10000
u_pay_works = (pay_works - pay_min) / (pay_max - pay_min)




# Calculate utility if drone fails
pay_fail = -5000
u_pay_fail = (pay_fail - pay_min) / (pay_max - pay_min)



# Calculate expected utility that you would earn
# Expected utility here is ~0.93
u_pay = p_works * u_pay_works + p_fail * u_pay_fail
u_pay # View


# EX2: Multiple Types of Utility #####################################

# Suppose there are extra forms of utility here, 
# not just utility in terms of pay. 

# Maybe your drone system will generate 
# 10 kilotons of carbon emissions if it works, 
# while if it fails, 
# you will still have produced 3 kilotons of emissions in production. 

# Suppose that society views 20 kilotons of emissions 
# as the worst possible emissions for a delivery system of your size.


# Define utility function for emissions
e_min = 0
e_max = 20

e_works = 10

u_e_works = (e_works - e_min) / (e_max - e_min)

e_fail = 3
u_e_fail = (e_fail - e_min) / (e_max - e_min)


# So the expected utility here is ~0.52 on a scale from 0 to 20.
# Calculate expected utility for emissions
u_e = p_works * u_e_works + p_fail * u_e_fail
u_e # View
1 - u_e


# EX3: Combining Utility ######################################


# We now need to combine these forms of utility. 
# Conveniently they are measured on the same 0 to 1 scale, 
# but we have to decide 
# (either theoretically, analytically, or based on empirical data) 
# how to weight pay versus emissions when combining them.

# Suppose that our mission statement agreed to let us 
# weight **emissions** at an importance level of 30% 
# versus **profitability** at an importance level of 70%.

# Define weights
w_e = 0.30
w_pay = 0.70

# Combine utilities
t = tibble(
  type = c("emissions", "pay"),           # Types of utilities
  # remember to make high emissions BAD
  # remember direction matters!
  u = c(1 - u_e, u_pay),                      # Utility values
  w = c(w_e, w_pay)                       # Weights
)

t

# We can combine them several different ways.

# Calculate combined utility additively
combined_additive = sum(t$u * t$w)
combined_additive

# Calculate combined utility multiplicatively
combined_multiplicative = prod(t$u * t$w)
combined_multiplicative



# Or if we know that high profitability 
# and low emissions together have an interaction effect on utility, 
# by attracting more users, prestige, etc., 
# we could add that interaction effect as a weight called w_e_pay too. 
# (This one is a little harder, 
# because you should have some rationale for it.)


rm(list = ls())
