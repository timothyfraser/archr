# Script: 23_evaluation_learning_curves.R
# Original: example_learning_curves.R
# Topic: Learning curve analysis
# Section: Evaluation
# Developed by: Timothy Fraser, PhD
# example_learning_curves.R

# Learning Curves  ###########################################
# Load packages
library(dplyr)
library(ggplot2)

# We might also want to estimate the learning curve involved in certain decisions. 
# For example, suppose we have Decision X, 
# the choice to make and use tool A instead of tool B. 
# Decision X is costly to our time at first, 
# but over time, we are expected to get better at making tool A.
# Suppose Tool A has an S = 80% learning curve.

# Learning Curve Formula: Y = aX^b
# suppose a 80% learning curve 
s <- 0.80

# means each time quantity doubles, you gain 20% in efficiency.
gains <- 1 - s

# Calculate the slope of the learning curve
b <- log(s) / log(2.00)

# If it takes 30 hours to make 
# tool A at the beginning...
a <- 30

# What happens if we make tool A many times?
x <- c(1, 2, 5, 10, 20, 50, 100, 150, 200)

# Our slope suggests that the average time to make Tool A becomes...
y <- a * x^b
y

# Let's plot that learning curve!
data = tibble(x, y)

# Visualize it!
ggplot() +
  geom_line(data = data, mapping = aes(x = x, y = y)) +
  labs(x = "Number of times made (X)", y = "Average time (Y) to make Tool A")


# Using 2 Learning Curves #########################

data2 = bind_rows(
  tibble(
    a = 30,
    x = c(1, 2, 5, 10, 20, 50, 100, 150, 200),
    s = 0.80,
    y = a * x^ (log(s) / log(2.00))
  ),
  tibble(
    a = 30,
    x = c(1, 2, 5, 10, 20, 50, 100, 150, 200),
    s = 0.90,
    y = a * x^ (log(s) / log(2.00))
  )
)


ggplot() +
  geom_line(data = data2, 
            mapping = aes(
              x = x, y = y,
              group = s, color = s)) +
  labs(x = "Number of times made (X)",
       y = "Average time (Y) to make Tool A")

# Using 3 Learning Curves! #######################


data3 = tibble(s = c(0.80, 0.85, 0.90, 0.92, 0.97, 0.99)) %>%
  # For each s...
  group_by(s) %>%
  # Make this vector!
  reframe(
    a = 30,
    x = c(1, 2, 5, 10, 20, 50, 100, 150, 200),
    y = a * x^ (log(s) / log(2.00))    
  )

# View it!
data3

# Visualize it!
ggplot() +
  # Let's make color = factor(s)
  # That splits the colors into a discrete color scale
  geom_line(data = data3, 
            mapping = aes(
              x = x, y = y,
              group = s, color = factor(s) )) +
  labs(x = "Number of times made (X)",
       y = "Average time (Y) to make Tool A")


# Z. Done!
# Clear environment
rm(list = ls())

