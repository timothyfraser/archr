# Script: 28_evaluation_pareto_fronts.R
# Original: example_pareto_front.R
# Topic: Pareto fronts exploration
# Section: Evaluation
# Developed by: Timothy Fraser, PhD
# example_pareto_front.R

# A script to demonstrate how to plot a pareto front

# SETUP #################################
# Load packages
library(dplyr)
library(archr)
library(ggplot2)
# Load data
data("donuts", package = "archr")
donuts

# PARETO FRONT ############################
# Make a table m we'll build
# Enumerate architectures, including an .id
m = enumerate_binary(n = nrow(donuts), .id = TRUE)

# Record the architectures as a matrix
a = m %>% select(-id) %>% as.matrix() 

# Add in columns for total metrics
m = m %>% 
  mutate(
    # For this example, we'll calculate benefit and cost with matrix multiplication,
    # but you could calculate cost or benefit many different ways
    # Matrix multiple the matrix by the vector of benefits
    benefit = a %*% donuts$benefit,
    # Matrix multiple the matrix by the vector of costs
    cost =   a %*% donuts$cost)

# View last five
m %>% select(id, benefit, cost) %>% tail(5)


ggplot() +
  geom_point(data = m, mapping = aes(x = benefit, y = cost))

# Visualizing the Pareto Front #################################

# Get the ids of the pareto front with pareto()
m = m %>%
  mutate(front = pareto(x = cost, y = -benefit))

m %>% select(id, cost, benefit, front)
# ?archr::pareto()

ggplot() +
  geom_point(data = m, mapping = aes(x = benefit, y = cost),
             color = "grey") +
  geom_line(data = m %>% filter(front == TRUE),
            mapping = aes(x = benefit, y = cost),
            color = "red")

# Thresholds #####################################
# Show just a slice of the architectures based on thresholds
m %>% 
  filter(front == TRUE & benefit > 20 & cost < 100)


# Add those thresholds for context usinge geom_hline and geom_vline!
ggplot() +
  geom_point(data = m, mapping = aes(x = benefit, y = cost),
             color = "grey") +
  geom_line(data = m %>% filter(front == TRUE),
            mapping = aes(x = benefit, y = cost),
            color = "red") +
  geom_hline(yintercept = 100, color = "blue") +
  geom_vline(xintercept = 20, color = "blue")

m

# Cleanup !
rm(list = ls())
