# Script: 46_optimization_time_series_case.R
# Original: case_study_vehicles_over_time.R
# Topic: Time series optimization case
# Section: Optimization
# Developed by: Timothy Fraser, PhD
# case_study_vehicles_over_time.R

# Extended case study on optimization over time

# SETUP ###########################################

## packages #####################################

library(dplyr) # for data wrangling
library(purrr) # for tidy iteration
library(ggplot2) # for visualization
library(GA) # for genetic algorithms
library(rmoo) # for multi-objective optimization

## context #######################################

# design a set of policies in Tompkins County that optimizes over n years....

# - minimizes emissions, 
# - max usage of buses

# d1 - congestion toll (0/1)
# d2 - buy more buses (0/1)
# d3 - invest in jetpacks (0/1)

## functions #############################################
# 300,000 tons of CO2e in Tompkins county 
get_emissions = function(t,d1,d2,d3){
  # Suppose that the impact of each policy changes over time,
  # because of varying demand and emissions factors.
  
  # If I enact a congestion toll
  m1 = case_when(d1 == 1 ~ 100000*sqrt(t), TRUE ~ 0)
  # If I buy more buses
  m2 = case_when(d2 == 1 ~ 30000*t^(1/3), TRUE ~ 0)
  # If I invest in jetpacks,
  m3 = case_when(d3 == 1 ~ 5000*sin(t), TRUE ~ 0)
  # Get remaining emissions
  output = 300000 - (m1+m2+m3)
  
  # Let's give a wide berth.
  # What is our highest possible emissions level?
  max = 400000
  # What is our lowest possible emissions level?
  min = 0
  
  # Let's rescale this so that...
  # 1 = most emissions; 0 = least emissions 
  rescaled = (output - min) / (max - min) 
  
  # Let's rescale this so that high means 'better'
  # 1 = least emissions; 0 = most emissions
  output = 1 - rescaled
  
  return(output)
}

get_riders = function(t,d1,d2){
  # Suppose that the impact on bus ridership varies over time due to changing demand, etc.
  # base # of bus riders = 10,000 people
  # If congestion toll
  m1 = case_when(d1 == 1 ~ 5000*sin(t) + 2000*t^2, TRUE ~ 0)
  # If I buy more buses
  m2 = case_when(d2 == 1 ~ 10000*sin(t) + 1000*t, TRUE ~ 0)
  # Get resulting total # of bus riders
  output =10000 + (m1 + m2)
  
  # Highest possible # of riders  
  max = 100000
  # Lowest possible # of riders
  min = 0
  
  # Let's rescale this so that...
  # 1 = most riders; 0 = least riders 
  rescaled = (output - min) / (max - min) 
  
  return(rescaled)
  
}

bit2int = function(x){
  xhat1 = binary2decimal(x == x[1])
  xhat2 = binary2decimal(x == x[2])
  xhat3 = binary2decimal(x == x[3])
  output = c(xhat1,xhat2,xhat3)
  return(output)
}


# OPTIMIZE OVER TIME #####################################
# Let's try optimizing OVER TIME,
# selecting the optimal policy configuration EACH YEAR,
# allowing for change each year.

# Notice that f1 is also in terms of t now
f1 = function(x, nobj = 2, t = 1, ...){
  # Get our bits vector x
  # turn it into integer vector xhat
  xhat = bit2int(x)
  # Get our metrics
  m1 = get_emissions(t= t, d1 = xhat[1], d2 = xhat[2], d3 = xhat[3])
  
  m2 = get_riders(t = t, d1 = xhat[1], d2 = xhat[2])
  # Format as a matrix
  output = matrix(c(m1,m2), nrow = 1)
  return(output)
}


results = tibble()
for(t in 1:5){
  
  # Add a new t argument, setting t equal to t in the for loop
  fnew = f1 %>% purrr::partial(t = t)

  o = rmoo(
    fitness = fnew,
    type = "binary", algorithm = "NSGA-III",
    lower = c(0,0,0), upper = c(1,1,1), monitor = TRUE, summary = TRUE,
    nObj = 2, nBits = 3, popSize = 50, maxiter = 100
  )
  
  data = o@solution %>%
    as_tibble() %>%
    select(d1 = x1, d2 = x2, d3 = x3) %>%
    mutate(emissions = get_emissions(t = t, d1 = d1, d2 = d2, d3 = d3),
           riders = get_riders(t = t, d1 = d1, d2 = d2)) %>%
    # Add the year
    mutate(t = t)
  
  # Bind them together...
  results = bind_rows(results, data)
}
# View results
results

# View change in pareto optimal architectures' metrics over time
ggplot() +
  geom_point(data = results, mapping = aes(x = riders, y = emissions, color = t), size = 5)

ggplot() +
  geom_point(data = results, mapping = aes(x = riders, y = emissions, color = t), size = 5) +
  facet_wrap(~t)


# OPTIMIZE CUMULATIVELY ###################################

# Let's try optimizing over time cumulatively, 
# where we add the previous timestep's metrics to the current timestep's metrics.
# In this case, we are selecting just 1 ARCHITECTURE for the entire epoch and allowing no change over time.

# Notice that f2 is also in terms of t now
f2 = function(x, nobj = 2, t = 1, ...){
  # Get our bits vector x
  # turn it into integer vector xhat
  xhat = bit2int(x)
  
  # *****Get our metrics, summed cumulatively from time 1 to time t*****
  m1 = get_emissions(t= 1:t, d1 = xhat[1], d2 = xhat[2], d3 = xhat[3]) %>% sum()
  m2 = get_riders(t = 1:t, d1 = xhat[1], d2 = xhat[2]) %>% sum()
  
  # Format as a matrix
  output = matrix(c(m1,m2), nrow = 1)
  return(output)
}

# Run optimization iteratively
results2 = tibble()
for(t in 5:5){
  
  # Add a new t argument, setting t equal to t in the for loop
  fnew = f2 %>% purrr::partial(t = t)
  
  o = rmoo(
    fitness = fnew,
    type = "binary", algorithm = "NSGA-III",
    lower = c(0,0,0), upper = c(1,1,1), monitor = TRUE, summary = TRUE,
    nObj = 2, nBits = 3, popSize = 50, maxiter = 100
  )
  
  data = o@solution %>%
    as_tibble() %>%
    select(d1 = x1, d2 = x2, d3 = x3) %>%
    group_by(d1,d2,d3) %>%
    mutate(emissions = get_emissions(t = 1:t, d1 = d1, d2 = d2, d3 = d3) %>% sum(),
           riders = get_riders(t = 1:t, d1 = d1, d2 = d2) %>% sum()) %>%
    ungroup() %>%
    # Add the year
    mutate(t = t)
  
  # Bind them together...
  results2 = bind_rows(results2, data)
}
# View results
results2 = results2 %>%
  mutate(group = paste0(d1,d2,d3))

# This makes each architecture a path through the tradespace
# Let's view the two main architectures as they progress through the tradespace
ggplot() +
  geom_label(
    data = results2, mapping = aes(x = riders, y = emissions,
                                   label = t, group = group, color = group)
  )

# Eh, that's a little boring.
# Let's try it where we optimize cumulatively, but allow switching.

# Run optimization iteratively
results2 = tibble()
for(t in 1:5){
  
  # Add a new t argument, setting t equal to t in the for loop
  fnew = f2 %>% purrr::partial(t = t)
  
  o = rmoo(
    fitness = fnew,
    type = "binary", algorithm = "NSGA-III",
    lower = c(0,0,0), upper = c(1,1,1), monitor = TRUE, summary = TRUE,
    nObj = 2, nBits = 3, popSize = 50, maxiter = 100
  )
  
  data = o@solution %>%
    as_tibble() %>%
    select(d1 = x1, d2 = x2, d3 = x3) %>%
    group_by(d1,d2,d3) %>%
    mutate(emissions = get_emissions(t = 1:t, d1 = d1, d2 = d2, d3 = d3) %>% sum(),
           riders = get_riders(t = 1:t, d1 = d1, d2 = d2) %>% sum()) %>%
    ungroup() %>%
    # Add the year
    mutate(t = t)
  
  # Bind them together...
  results2 = bind_rows(results2, data)
}
# View results
results2 = results2 %>%
  mutate(group = paste0(d1,d2,d3))

# This makes each architecture a path through the tradespace
# Let's view the two main architectures as they progress through the tradespace
ggplot() +
  geom_label(
    data = results2, mapping = aes(x = riders, y = emissions,
                                   label = t, group = group, color = group)
  )





# ROBUSTNESS ####################################

# Let's try optimizing, where the goal is to bring up the min cumulative metric score.
# No switching architectures allowed. You commit in year 1.

# Notice that f3 has 1 objective now, in terms of time t
f3 = function(x, nobj = 1, t = 1, ...){
  # Get our bits vector x
  # turn it into integer vector xhat
  xhat = bit2int(x)
  
  # Get our metrics, cumulatively summed
  m1 = get_emissions(t= 1:t, d1 = xhat[1], d2 = xhat[2], d3 = xhat[3]) %>% sum()
  m2 = get_riders(t = 1:t, d1 = xhat[1], d2 = xhat[2]) %>% sum()
  
  # Get the minimum metric value
  output = matrix(min(c(m1,m2)), nrow = 1)
  return(output)
}

# This time, we'll run it for just the 5th time period,
# showing minimum cumulative metrics by the 5th year.
results3 = tibble()
for(t in 5:5){
  
  # Add a new t argument, setting t equal to t in the for loop
  fnew = f3 %>% purrr::partial(t = t)
  
  # Run this algorithm for just 1 time step
  o = rmoo(
    fitness = fnew,
    type = "binary", algorithm = "NSGA-III",
    lower = c(0,0,0), upper = c(1,1,1), monitor = TRUE, summary = TRUE,
    nObj = 2, nBits = 3, popSize = 50, maxiter = 100
  )
  
  data = o@solution %>%
    as_tibble() %>%
    select(d1 = x1, d2 = x2, d3 = x3) %>%
    group_by(d1,d2,d3) %>%
    mutate(emissions = get_emissions(t = 1:t, d1 = d1, d2 = d2, d3 = d3) %>% sum(),
           riders = get_riders(t = 1:t, d1 = d1, d2 = d2) %>% sum()) %>%
    ungroup() %>%
    # Add the year
    mutate(t = t)
  
  # Bind them together...
  results3 = bind_rows(results3, data)
  
}
# View results
results3 = results3 %>%
  mutate(group = paste0(d1,d2,d3))


# These are the architectures that produces the highest min cumulative metrics
# kind of silly - shows almost all possible combinations, but still valid.
results3

ggplot() +
  geom_label(
    data = results3, mapping = aes(x = riders, y = emissions,
                                   label = t, group = group, color = group)
  )



# Hope this has given you several additional ideas about how to optimize over time!!!

rm(list = ls())
