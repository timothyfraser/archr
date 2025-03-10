# example_conditional_statements.R

# Script to demonstrate how to code cost / other measures
# using condition statements

# SETUP ####################################
# Load packages
library(dplyr)
library(archr)
library(ggplot2)

# Make architectures to work with
a = enumerate_sf(n = c(2,2,2))

# Suppose 
get_cost = function(d1, d2, d3){
  # Let's make some objects JUST for testing - be sure to comment them out when done
  # d1 = 1; d2 = 1; d3 = 1
  
  # For each decision dX, make a metric mX
  
  # When d1 is 1, make m1 3; When d1 is 0, make m1 0
  # and repeat for other problem
  # Or, try using case when
  m1 = case_when(d1 == 1 ~ 3, d1 == 0 ~ 0)
  m2 = case_when(d2 == 1 ~ 6, d2 == 0 ~ 0)
  m3 = case_when(d3 == 1 ~ 9, d3 == 0 ~ 0)
  
  # Or, try using switch
  # m1 = switch(EXPR = d1, "1" = 3, "0" = 0)
  # m2 = switch(EXPR = d2, "1" = 6, "0" = 0)
  # m3 = switch(EXPR = d3, "1" = 9, "0" = 0)
  
  # # Or, try using if-else statements
  # m1 = if(d1 == 1){ 3}else if(d1 == 0){ 0 }
  # m2 = if(d2 == 1){ 6}else if(d2 == 0){ 0 }
  # m3 = if(d3 == 1){ 9}else if(d3 == 0){ 0 }
  
  # Compute overall metric
  metric = m1+m2+m3
  return(metric)
}

# Make sure you don't have d1,d2,d3 in your environment
# remove(d1,d2,d3)

# Let's try it
a %>%
  mutate(cost = get_cost(d1,d2,d3))


# Use both
data = a %>%
  mutate(cost = get_cost(d1,d2,d3)) 

# View histogram of cost values for your architectures!
data$cost %>% hist()


# Cleanup!
rm(list = ls())
