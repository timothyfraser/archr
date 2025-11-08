# Script: 32_evaluation_scenarios.R
# Original: tutorial_evaluation_3.R
# Topic: Evaluation scenario analysis
# Section: Evaluation
# Developed by: Timothy Fraser, PhD
# tutorial_evaluation_3.R

library(dplyr)
library(readr)
library(tidyr)
library(archr)

data("donuts", package = "archr")

donuts

# Let's enumerate!s
a = enumerate_binary(n = 10)

a
# colSums(t(a)) * donuts$benefit

# MATRIX MULTIPLICATION METHODS #######################################
# Let's enumerate!s
a = enumerate_binary(n = 10)

tibble(
  benefit = colSums(t(a) * donuts$benefit),
  cost = colSums(t(a) * donuts$cost)
)

a %>%
  mutate(benefit = as.matrix(a) %*% donuts$benefit)

donuts
donuts$benefit

# Clear
rm(list = ls())


# JOINING METHOD ###############################

# Let's enumerate!s
a = enumerate_binary(n = 10)

data("d_donuts", package = "archr")
d_donuts


a %>%
  select(d1,d2) %>%
  left_join(
    by = c("d1" = "altid"),
    y = d_donuts %>% 
      filter(did == 1) %>%
      select(altid,
             d1_benefit = benefit)) %>%
  left_join(
    by = c("d2" = "altid"),
    y = d_donuts %>% 
      filter(did == 2) %>%
      select(altid,
             d2_benefit = benefit)) %>%
  mutate(benefit = d1_benefit + d2_benefit)

# Clear
rm(list = ls())

# FOR LOOP ########################################

# Let's enumerate!s
a = enumerate_binary(n = 10)

data("d_donuts", package = "archr")

# For each column (decision)
for(i in 1:length(a)){
  # For each row
  for(j in 1:nrow(a)){
    
    #i = 1; j = 1
    # Get the value from our matrix  
    this_a = a[[j,i]]
    # Grab our stats
    values = d_donuts %>% filter(did == i) %>% filter(altid == this_a)
    # Reassign the value to be the benefit
    a[[j,i]] <- values$benefit  
  }  
}

# A data.frame of benefits per decision (column) per architecture (row)
a %>%
  mutate(benefit = d1+d2+d3+d4+d5+d6+d7+d8+d9+d10)
  

# Clear
rm(list = ls())

# SUPER FOR LOOP ########################################
# Let's enumerate!s
a = enumerate_binary(n = 10)

data("d_donuts", package = "archr")

# Benefits (make a blank matrix, then turn it into a tibble)
b = matrix(NA, nrow = nrow(a), ncol = ncol(a), dimnames = list(NULL, names(a))) %>% as_tibble()
# Costs (make a blank matrix, then turn it into a tibble)
c = matrix(NA, nrow = nrow(a), ncol = ncol(a), dimnames = list(NULL, names(a))) %>% as_tibble()

# For each decison
for(i in 1:length(a)){
  # For each row (architecture)
  for(j in 1:nrow(a)){
    
    # i = 1; j = 1
    # Get the value from our matrix  
    this_a = a[[j,i]]
    # Grab our stats
    values = d_donuts %>% filter(did == i) %>% filter(altid == this_a)
    
    # Reassign the value to be the benefit
    b[[j,i]] <- values$benefit
    
    # Reassign the value to be the costs
    c[[j,i]] <- values$cost  
  }  
}

# A data.frame of benefits per decision (column) per architecture (row)
b %>% mutate(benefit = d1+d2+d3+d4+d5+d6+d7+d8+d9+d10) 
# A data.frame of costs per decision (column) per architecture (row)
c %>% mutate(cost = d1+d2+d3+d4+d5+d6+d7+d8+d9+d10) 
# Our original clean data.frame
a

# Clear
rm(list = ls())


# RECODING ##############################################
# Let's enumerate!s
a = enumerate_binary(n = 10)

data("d_donuts", package = "archr")


d_donuts

a %>%
  # Recode every single value
  mutate(
    d1 = case_when( d1 == 0 ~ 0,   d1 == 1 ~ 3),  
    d2 = case_when( d2 == 0 ~ 0, d2 == 1 ~ 6)
    ) %>%
  # Get total benefit
  mutate(benefit = d1+d2) %>%
  # Let's look at just our d1 and d2 columsn...
  select(d1,d2, benefit) %>%
  # Look at bottom of the data.frame
  tail()

# Clear
rm(list = ls())

# FUNCTION ######################################

# This is your best option.
# Make a get_benefit() function and a get_cost() function
# which go row by row
# and then run them in a mutate() command

# EXAMPLE FUNCTION
get_plusone = function(a = 1){
  # Testing values
  # a = 1
  # a = c(1,2)
  
  # Process
  output = a + 1
  
  # Output
  return(output)
}

get_plusone() # get_plusone(a = 1)


get_plusone(a = 2)

get_plusone(a = c(1,2,3,4,5))


## COSTS #################################
# I'm going to do this one on a smaller example, for simplicity.

# Enumerate just 3 DECISIONS
a = enumerate_binary(n = 3)
# Get benefit/cost data
data("d_donuts", package = "archr")
# Let's say we're just looking at the FIRST 3 DECISIONS
d_donuts %>% filter(did %in% 1:3)



get_cost = function(d1,d2,d3){
  # Testing values
  # d1 = 1; d2 = 1; d3 = 1
  
  # Get the cost statistics
  # Recode decision 1 so that when decision 1 equals, it costs $1
  m1 = case_when(d1 == 1 ~ 1, d1 == 0 ~ 0)
  # Recode decision 2
  m2 = case_when(d2 == 1 ~ 5, d2 == 0 ~ 0)
  # Recode decision 3
  m3 = case_when(d3 == 1 ~ 70, d3 == 0 ~ 0)
  
  # Compute our overall metric
  metric = m1 + m2 + m3
  return(metric)
}

# remove(d1,d2,d3,m1,m2,m3,metrics)

# a %>% mutate(cost = get_cost(d1,d2,d3))
# a %>% mutate(cost = get_cost(d1 = d1, d2 = d2, d3 = d3))

a %>% mutate(cost = get_cost(d1,d2,d3))





get_benefit = function(d1, d2, d3){
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
  mutate(benefit = get_benefit(d1,d2,d3))


# Use both
data = a %>%
  mutate(benefit = get_benefit(d1,d2,d3)) %>%
  mutate(cost = get_cost(d1,d2,d3))


ggplot() +
  geom_point(data = data, mapping = aes(x = benefit, y = cost))

ggplot() +
  geom_point(data = data, mapping = aes(x = d1, y = benefit))




data %>%
  group_by(d1) %>%
  summarize(benefit = mean(benefit))


data %>%
  group_by(d1,d2) %>%
  summarize(benefit = mean(benefit))

# The interaction effect of choosing 
# BOTH d1 = 1 and d2 = 1 is +9 tastiness points
13.5 - 4.5


# PARETO FRONT ############################

data("donuts", package = "archr")
donuts
# Make a table m we'll build
# Enumerate architectures, including an .id
m = enumerate_binary(n = nrow(donuts), .id = TRUE)

# Record the architectures as a matrix
a = m %>% select(-id) %>% as.matrix() 

# Add in columns for total metrics
m = m %>% 
  mutate(
    # Matrix multiple the matrix by the vector of benefits
    benefit = a %*% donuts$benefit,
    # Matrix multiple the matrix by the vector of costs
    cost =   a %*% donuts$cost)

# View last five
m %>% select(id, benefit, cost) %>% tail(5)


ggplot() +
  geom_point(data = m, mapping = aes(x = benefit, y = cost))


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

m %>% 
  filter(front == TRUE & benefit > 20 & cost < 100)



ggplot() +
  geom_point(data = m, mapping = aes(x = benefit, y = cost),
             color = "grey") +
  geom_line(data = m %>% filter(front == TRUE),
            mapping = aes(x = benefit, y = cost),
            color = "red") +
  geom_hline(yintercept = 100, color = "blue") +
  geom_vline(xintercept = 20, color = "blue")

m

