# Script: 09_architecting_cost_function_examples.R
# Original: example_cost_functions.R
# Topic: Cost function modeling examples
# Section: Architecting Systems
# Developed by: Timothy Fraser, PhD
# example_cost_functions.R

# Script to demonstrate how to make a cost function.

# Setup #####################################################
library(dplyr)
library(ggplot2)


# Estimating Cost Functions #################################

# smartboards
data = tribble(
  ~unit, ~cost,
  1,     2000,
  10,    16000,
  50,    90000,
  100,   140000,
)

# NY 
# 3 schools per town * 10 town * 1 county * 50 smartboards
# 150

ggplot() +
  geom_point(data = data, mapping = aes(x = unit, y = cost))

# Estimate a linear model of cost
m = data %>% lm(formula = cost ~ unit)
# Cost = $4,920 + $1,418 * unit

# Equivalently stated as a function:
get_cost = function(unit){ 4920 + 1418 * unit }

# Calculate it
data2 = tibble(
  unit = 150,
  # pred = get_cost(unit), # this is equivalent
  pred = predict(m, newdata = tibble(unit))
)




# Projecting Cost ###################################

# Using the same logic, we can project predicted cost
# over a long range of time

data3 = tibble(
  unit = 1:150,
  pred = predict(m, newdata = tibble(unit))
)

data3

# Let's visualize them
ggplot() +
  geom_point(data = data, mapping = aes(x = unit, y = cost)) +
  geom_line(data = data3, mapping = aes(x = unit, y = pred)) +
  geom_point(data = data2, mapping = aes(x = unit, y = pred), color = "red")


# Logged Predictions ###############################

# A lot of the time, we need to take the log of cost,
# because cost is a naturally right-skewed variable

# By default, 
# log = natural log
# log(x, 10)

m2 = data %>% lm(formula = log(cost) ~ unit)
m2


# ln(cost) = 8.63484 ln$ + 0.03726 ln$ * unit 
data4 = tibble(
  unit = 1:150,
  pred = predict(m2, newdata = tibble(unit))
) %>%
  # remember to exponentiate the prediction!
  mutate(pred = exp(pred))

# And visualize
ggplot() +
  geom_point(data = data, mapping = aes(x = unit, y = cost)) +
  geom_line(data = data3, mapping = aes(x = unit, y = pred), color = "blue") +
  geom_line(data = data4, mapping = aes(x = unit, y = pred), color = "red") +
  geom_point(data = data2, mapping = aes(x = unit, y = pred), color = "blue")

# Cleanup
rm(list = ls())
