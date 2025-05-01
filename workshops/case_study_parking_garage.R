# case_study_parking_garage.R

# Optimization over Time example from slides

# SETUP #################################

## packages #####################################
library(dplyr) # for data wrangling
library(archr) # for enumeration
library(ggplot2) # for visualization
library(GA) # for genetic algorithm
library(rmoo) # for multi-objective genetic algorithms

## problem #######################################
# We're going to find the optimal number of levels to build in a parking garage.
# This problem has 1 decision variable: parking garage levels, eg. 0, 1, 2, 3, 4...
# The primary metric of interest is net present value.
# We'll need several functions to help us calculate it.

## functions ######################################
#' @name get_npv
#' @title Get Net Present Value at time t
#' @param r cash flow (revenue - cost) at time t
#' @param i discount rate
#' @param t time of the cash flow
get_npv = function(t, r, i){r / (1 + i)^t }

#' @name get_capacity
#' @param d1 number of levels of parking garage
#' @description Provides capacity for 200 cars per level
get_capacity = function(d1){ d1 * 200 }

#' @name get_usage
#' @title Get number of spaces used
get_usage = function(demand, capacity){
  if_else(demand > capacity, true = capacity, false = demand)
}

get_revenue = function(t, usage){ 10000 * t * usage }

# Demand is projected at a rate of 46.47 cars a year
# data = tribble(
#   ~t, ~demand,
#   1, 750,
#   2,  893,
#   3,  1015,
#   10, 1500,
#   19, 1688,
#   20, 1696
# ) 
# 
# # This log of t captures the trend quite well.
# data %>% lm(formula = demand ~ log(t) )
# 
# ggplot() +
#   geom_point(data = data, mapping = aes(x = t, y = demand)) +
#   geom_smooth(data = data, mapping = aes(x = t, y= demand), method = "lm", formula = y ~ log( x ))

#' @name get_demand
#' @param t time
get_demand = function(t){ log(t) * 334.4 + 697.7 }

get_operating_cost = function(capacity){
  # $2k/year/spaces available
  2000 * capacity
}

get_lease_cost = function(){ 3.6 * 1000000 }
get_construction_cost = function(capacity, levels = 0){
  base = 16000 * capacity
  base + 0.10*base*levels
}



# DETERMINISTIC PROJECTION ###############################

## calculate #############################

# First, we'll make a deterministic projection,
# where we account for no uncertainty when estimating NPV.

# We're going to estimate net present value given each possible number of levels in the garage,
# FOR EVERY YEAR over 20 years.

# Let's make our architectures - 1 decision, the number of levels in the garage
a = archr::enumerate_sf(
  n = 15
) %>%
  # repeat over time for 20 years
  expand_grid(
    t = 1:20
  ) %>%
  # approximate net present value
  mutate(
    # first approximate demand for parking spots...
    demand = get_demand(t = t),
    # then calculate intermediates...
    capacity = get_capacity(d1 = d1),
    usage = get_usage(demand = demand, capacity = capacity),
    revenue = get_revenue(t = t, usage = usage),
    operation_cost = get_operating_cost(capacity = capacity),
    lease_cost = get_lease_cost(),
    construction_cost = get_construction_cost(capacity = capacity, levels = d1),
    cash_flow = revenue - (operation_cost + lease_cost + construction_cost),
    # then calculate net present value at time t with a discount rate of 12%
    npv = get_npv(t = t, r = cash_flow, i = 0.12) 
  )


## visualize ##########################################

# Show expected change in net present value over time,
# depending on this decision (how many levels you build)
ggplot() +
  geom_point(data = a, mapping = aes(x = t, y = npv, color = factor(d1))) +
  geom_line(data = a, mapping = aes(x = t, y = npv, group = d1, color = factor(d1) ))

# Find the maximum 20-year NPV 
# given number of levels of parking garage (d1)
ggplot() +
  geom_point(
    data = a %>% filter(t == 20),
    mapping = aes(x = d1, y = npv))

## filter #################################

# Find the peak numerically -- 9 levels
a %>% filter(t == 20) %>%
  filter(npv == max(npv))

# Note that this example may differ slightly from the slides,
# because I had to approximate the demand function.



# UNCERTAINTY #######################################

# What if annual volatility is 10%?
# This 10% can be interpreted as the coefficient of variation,
# and incorporated into normal distribution simulations

# (Or, can use Brownian Motion - more advanced concept, not discussed here.)

## simulate ######################################
# Let's make our architectures - 1 decision, the number of levels in the garage
a2 = archr::enumerate_sf(
  n = 15
) %>%
  # repeat over time for 20 years
  expand_grid(
    t = 1:20
  ) %>%
  # approximate net present value
  mutate(
    demand = get_demand(t = t),
    # Estimate volatility as 10% of that year's demand
    volatility = 0.10*demand
  ) %>%
  # Estimate volatility with 1000 draws from a normal distribution,
  # for each number of levels and year
  group_by(d1,t) %>%
  reframe(demand = rnorm(n = 1000, mean = demand, sd = volatility)) %>%
  # calculate npv for each simulation
  mutate(
    capacity = get_capacity(d1 = d1),
    usage = get_usage(demand = demand, capacity = capacity),
    revenue = get_revenue(t = t, usage = usage),
    operation_cost = get_operating_cost(capacity = capacity),
    lease_cost = get_lease_cost(),
    construction_cost = get_construction_cost(capacity = capacity, levels = d1),
    cash_flow = revenue - (operation_cost + lease_cost + construction_cost),
    npv = get_npv(t = t, r = cash_flow, i = 0.12) 
  ) %>%
  # For each number of levels and year,
  # estimate the confidence interval around net present value
  # conservative estimate will be lower 95% confidence interval,
  # eg. the 2.5th percentile of NPV.
  group_by(d1,t) %>%
  summarize(
    mean = mean(npv, na.rm = TRUE),
    lower = quantile(npv, probs = 0.025),
    upper = quantile(npv, probs = 0.975)
  ) %>%
  ungroup()

## filter ##########################

# Find the peak
a2 %>% filter(t == 20) %>%
  filter(lower == max(lower))

## visualize #########################

# Show that the peak occurs at 7 levels not, not 9. 
ggplot() +
  geom_line(
    data = a %>% filter(t == 20),
    mapping = aes(x = d1, y = npv, color = "No Uncertainty")) +
  geom_line(
    data = a2 %>% filter(t == 20),
    mapping = aes(x = d1, y = lower, color = "Lower 95% Estimate"))








