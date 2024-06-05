# case_study_green_space.R
# courtesy of Laura, Terrence, Veronica, and Sai
# with light edits from Tim

# ENUMERATION ###################################

## Load packages ####
library(dplyr)
library(tidyr)
library(archr)
library(ggplot2)

## enumerate ###############
e = expand_grid(
  #decision on location
  #options:
  # Section 0: closer to monuments and parks (angled parking)
  # Section 1: Restaurants/Businesses (angled parking)
  # Section 2: cultural trail and games (parallel parking)
  enumerate_sf(n=3, .did = 1),
  #Location: SF : 3 options
  #Moving Function
  # Options:
  # d1_0 = Walking
  # d1_1 = Biking
  # d1_2 = Running
  #create constraint, if we select biking lane, we cannot have a running lane as well
  enumerate_ds (n = 3, k = 2, .did = 2)
) %>%
  # CONSTRAINTS
  filter(!(d2_1 == 1 & d2_2 == 1)) %>%
  expand_grid(
    #Space function
    #options:
    # 0 = shelters
    # 1 = green space
    enumerate_sf(n = 2, .did = 3),
    #decision on space allocation
    #options:
    # 0 = 60% movingF ,40% spaceF
    # 1 = 40% movingF ,60% spaceF
    enumerate_sf (n = 2, .did = 4), #Space Allocation: SF: 2 options
    #decision on Street traffic
    #options:
    # 0 = One-way;
    # 1 = Two-way;
    # 2 = Alternating (lane that changes direction based on traffic need)
    enumerate_sf(n = 3, .did = 5),
    #decision
    #Placement of <a1 = Crosswalks, a2 = Benches, a3 = Street Lights>:
    # b1 = At intersection
    # b2 = At middle of block
    #create constraint, we cannot have bench without a street light (for safety)
    enumerate_assignment(n = 3, m = 2, k = 2, n_alts = 2, .did = 6)
  )  %>%
  # CONSTRAINTS
  filter(! (((d6_a2_b1)&!(d6_a3_b1))
            | ((d6_a2_b2)&!(d6_a3_b2))))  %>%
  expand_grid(
    #decision on speed limit
    #options: 0 = 10 mph; 1 = 15 mph; 2 = 20 mph; 3 = 25 mph
    #add constraint, if traffic is one way, limit has to be below 15mph
    #d5$d1 == 0 d7$d1 >= 2
    enumerate_sf(n = 4, .did = 7)
  ) %>%
  # CONSTRAINTS
  filter(!(d5 == 0 & d7 >= 2 )) %>%
  expand_grid(
    #Median Design:
    #options:  0 = 0 ft; 1 = 5 ft, with bushes; 2 = 5 ft, with trees
    enumerate_sf(n = 3, .did = 8),
    #Barrier Design:
    #options: 0 = Outer; 1 = Inner
    enumerate_sf (n = 2, .did = 9)
  )


e %>% glimpse()

# SAMPLING ##########################################

# To take a stratified sample stratifying by d2,
# We'll need to concatenate its multiple columns into one column, like this
e = e %>%
  mutate(d2 = paste0(d2_1, d2_2, d2_3)) 
# Stratified sample of 100 architectures per strata!
sample = e %>%
  group_by(d1, d2, d3, d5) %>%
  sample_n(size = 100) %>%
  ungroup()
# View it!
sample %>% glimpse()



# METRICS ############################

get_duration = function(d3,d4,d8, d9){
  # Testing values
  # d1 = 1; d2 = 1; d3 = 1
  # Get the duration statistics
  # Recode decision 3 so that when decision 1 equals, it costs $1
  m3 = case_when(d3 == 1 ~ 15, d3 == 0 ~ 75)
  # Recode decision 4
  m4 = case_when(d4 == 1 ~ 100, d4 == 0 ~ 70)
  # Recode decision 8
  m8 = case_when(d8 == 2 ~ 35, d8 == 1 ~ 33, d8 == 0 ~ 25)
  # Recode decision 8
  m9 = case_when(d9 == 1 ~ 2, d9 == 0 ~ 5)
  # Compute our overall metric
  metric = m3 + m4 + m8 +m9
  return(metric)
}


get_cost = function(d3,d5,d8,d6a1b1,d6a1b2,d6a2b1,d6a2b2,d6a3b1,d6a3b2){
  # Testing values
  # d1 = 1; d2 = 1; d3 = 1
  # Get the cost statistics
  # Recode decision 3 so that when decision 1 equals, it costs $1
  m3 = case_when(d3 == 1 ~ 1245, d3 == 0 ~ 15000)
  # Recode decision 5
  m5 = case_when(d5 == 2 ~ 110000, d5 == 1 ~ 500, d5 == 0 ~ 375)
  # Recode decision 8
  m8 = case_when(d8 == 2 ~ 17880, d8 == 1 ~ 6792, d8 == 0 ~ 237.6)
  # Recode decision 6
  m6a1b1 = case_when(d6a1b1 == 1 ~ 2600, d6a1b1 == 0 ~ 0)
  m6a1b2 = case_when(d6a1b2 == 1 ~ 2600, d6a1b2 == 0 ~ 0)
  m6a2b1 = case_when(d6a2b1 == 1 ~ 1000, d6a2b1 == 0 ~ 0)
  m6a2b2 = case_when(d6a2b2 == 1 ~ 1000, d6a2b2 == 0 ~ 0)
  m6a3b1 = case_when(d6a1b1 == 1 ~ 3000, d6a1b1 == 0 ~ 0)
  m6a3b2 = case_when(d6a1b2 == 1 ~ 3000, d6a1b2 == 0 ~ 0)
  # Compute our overall metric
  metric = m3 + m5 + m8 + m6a1b1+m6a1b2+m6a2b1+m6a2b2+m6a3b1+m6a3b2
  return(metric)
}


# SubFunction: perf_metric_walkability
# Inputs:
# d1 = Location
# Output: metric (evaluation of the walkability score per architecture)
# Define the performance metric function for Transportation Emissions
# The larger the value, the larger the benefit
get_walkability <- function(d1){
  # Define the min/max of the utility scale
  w_min = 1;
  w_max = 5;
  # Recode decision #5 for emissions metric
  m1 = case_when(d1 == 0 ~ 4, # Monuments/Parks
                 d1 == 1 ~ 2, # Restaurants
                 d1 == 2 ~ 2, # Cultural Trail
                 TRUE ~ 0) # Else condition
  # Calculate the overall metric
  metric = (m1)
  return(metric)
}

# SubFunction: perf_metric_traveltimes
# Inputs:
# d5 = Street Traffic
# d7 = Speed Limit
# Output: metric (evaluation of the travel times score per architecture)
# Define the performance metric function for Transportation Emissions
# The larger the value, the larger the benefit
get_traveltimes <- function(d5, d7){
  # Define the min/max of the utility scale
  w_min = 0;
  w_max = 20;
  # Recode decision #5 for emissions metric
  m5 = case_when(d5 == 0 ~ 0.3, # One-Way; High Travel; Slow
                 d5 == 1 ~ 0.8, # Two-Way; Low Travel; Fast
                 d5 == 2 ~ 0.3, # Alternating Lane; Slow
                 TRUE ~ 0) # Else condition
  
  # Recode decision #7 for emissions metric
  m7 = case_when(d7 == 0 ~ 0.9, # 10 MPH
                 d7 == 1 ~ 0.7, # 15 MPH
                 d7 == 2 ~ 0.5, # 20 MPH
                 d7 == 3 ~ 0.3, # 25 MPH
                 TRUE ~ 0) # Else condition
  # Calculate the overall metric
  metric = (m5 * m7) * (w_max - w_min) + w_min;
  return(metric)
}

# SubFunction: perf_metric_emissions
# Inputs:
# d4 = Space Allocation
# d5 = Street Traffic
# d7 = Speed Limit
# Output: metric (evaluation of the emissions score per architecture)
# Define the performance metric function for Transportation Emissions
# The larger the value, the larger the benefit
get_emissions <- function(d4, d5, d7){
  # Define the min/max of the utility scale
  w_min = 0;
  w_max = 100;
  # Recode decision #4 for emissions metric
  m4 = case_when(d4 == 0 ~ 1.0, # 60% MovingF, 40% SpaceF
                 d4 == 1 ~ 0.5, # 40% MovingF, 60% SpaceF
                 TRUE ~ 0) # Else condition
  # Recode decision #5 for emissions metric
  m5 = case_when(d5 == 0 ~ 0.3, # One-Way; High Travel; Slow
                 d5 == 1 ~ 0.8, # Two-Way; Low Travel; Fast
                 d5 == 2 ~ 0.3, # Alternating Lane; Slow
                 TRUE ~ 0) # Else condition
  # Recode decision #7 for emissions metric
  m7 = case_when(d7 == 0 ~ 0.9, # 10 MPH
                 d7 == 1 ~ 0.7, # 15 MPH
                 d7 == 2 ~ 0.5, # 20 MPH
                 d7 == 3 ~ 0.3, # 25 MPH
                 
                 TRUE ~ 0) # Else condition
  # Calculate the overall metric
  metric = (m4 * m5 * m7) * (w_max - w_min) + w_min;
  return(metric)
}


## mutate() method ####################
sample = sample %>%
  mutate(duration = get_duration(d3 = d3, d4 = d4, d8 = d8, d9 = d9)) %>%
  mutate(cost = get_cost(
    d3 = d3, d5 = d5, d8 = d8, 
    d6a1b1 = d6_a1_b1, d6a1b2 = d6_a1_b2, d6a2b1 = d6_a2_b1,
    d6a2b2 = d6_a2_b2, d6a3b1 = d6_a3_b1, d6a3b2 = d6_a3_b2 )) %>%
  mutate(
    walk = get_walkability(d1 = d1),
    travel = get_traveltimes(d5 = d5, d7 = d7),
    emis = get_emissions(d4 = d4, d5 = d5, d7 = d7)
  )


sample = sample %>%
  mutate(d6 = paste0(d6_a1_b1, d6_a1_b2, d6_a2_b1, d6_a2_b2, d6_a3_b1, d6_a3_b2))

sample %>% glimpse()
# OR

# unlist(sample[1, 1:16])
evaluate = function(int){
  # Testing value
  # int = unlist(e[1,1:16])
  
  # Take a vector 'int' of integers and get decision values
  d1 = int[1]
  d2_1 = int[2]; d2_2 = int[3]; d2_3 = int[4]
  d3 = int[5]; d4 = int[6]; d5 = int[7]
  d6_a1_b1 = int[8]
  d6_a1_b2 = int[9]
  d6_a2_b1 = int[10]
  d6_a2_b2 = int[11]
  d6_a3_b1 = int[12]
  d6_a3_b2 = int[13]
  d7 = int[14]; d8 = int[15]; d9 = int[16]
  
  # Get metrics
  duration = get_duration(d3 = d3, d4 = d4, d8 = d8, d9 = d9)
  cost = get_cost(
    d3 = d3, d5 = d5, d8 = d8, 
    d6a1b1 = d6_a1_b1, d6a1b2 = d6_a1_b2, d6a2b1 = d6_a2_b1,
    d6a2b2 = d6_a2_b2, d6a3b1 = d6_a3_b1, d6a3b2 = d6_a3_b2 )
  
  walk = get_walkability(d1 = d1)
  travel = get_traveltimes(d5 = d5, d7 = d7)
  emis = get_emissions(d4 = d4, d5 = d5, d7 = d7)
  
  # Turn into a matrix
  output = matrix(
    data = c(duration, cost, walk, travel, emis), 
    byrow = TRUE, ncol = 5)
  # Set column names in matrix
  colnames(output) = c("duration", "cost", "walk", "travel", "emis")

  return(output)
}

# Let's try and evaluate a few
evaluate(int = e[150,1:16])


# HELPER FUNCTIONS ###########################
# Load functions
source("workshops/functions_entropy.R")
# Load pareto_rank() function
source("workshops/functions_pareto_rank.R")
# Load sensitivity
source("workshops/functions_sensitivity_and_connectivity.R")


sample %>%
  glimpse()


# ENTROPY ##################################

# Is that architecture good?
sample = sample %>% 
  mutate(good = cost > median(cost))

# Does that architecture have a certain feature?
sample = sample %>%
  # If location = businesses ^& traffic = 2-way
  mutate(feature = case_when(d1 == 1 & d5 == 1 ~ TRUE, TRUE ~ FALSE)) 

# Information gain!
ig(good = sample$good, feature = sample$feature)


ggplot() +
  geom_density(
    data = sample, 
    mapping = aes(x = cost, fill = feature),
    alpha = 0.5)

ggplot() +
  geom_jitter(
    data = sample, 
    mapping = aes(x = walk, y = cost, 
                  color = feature),
    alpha = 0.5
  ) + facet_wrap(~feature)

ggplot() +
  geom_jitter(
    data = sample, mapping = aes(
      x = duration, y = cost,
      color = feature),
    alpha = 0.5
  ) +
  facet_wrap(~feature)

# Check information gain from lots of features
# in this case we'll count each decision as a feature, as an example
# e %>%
#   select(d1:d9, good) %>%
#   pivot_longer(cols = c(d1:d9), names_to = "type", values_to = "feature") %>%
#   group_by(type) %>%
#   summarize(ig(good = good, feature = feature))



# TRANSFORM DIFFICULT VARIABLES ########################################
e = e %>% 
  mutate(d6 = paste0(d6_a1_b1, d6_a1_b2, d6_a2_b1, 
                     d6_a2_b2, d6_a3_b1, d6_a3_b2 ))
# View a few
e %>% select(d6) %>% sample_n(size = 5)

# Allows you to do sensitivity analysis on tricky metrics, by turning them into, essentially, a standard form problem with many discrete categories
sensitivity(data = e, decision_i = 'd6', metric = 'cost')
connectivity(data = e, decision_i = 'd6', decisions = c("d1","d3", "d6"), metric = "cost")

