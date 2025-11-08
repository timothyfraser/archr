# Script: 44_optimization_exercise_equipment_case.R
# Original: case_study_exercise_equipment.R
# Topic: Exercise equipment optimization case
# Section: Optimization
# Developed by: Timothy Fraser, PhD
# case_study_exercise_equipment.R

# A case study using your colleagues code to optimize an exercise equipment product system architecture.

# 0. SETUP ##########################################################
#install.packages("tidyr")
library(dplyr)
library(archr)
library(ggplot2)
library(tidyr)

#archs = Hw3_decisions
archs <- expand_grid(
  d1 = enumerate_sf(n = c(2), .did = 1),  # Portability
  d2 = enumerate_sf(n = c(4), .did = 2),  # Stability
  d3 = enumerate_sf(n = c(3), .did = 3),  # Mechanism
  d4 = enumerate_sf(n = c(2), .did = 4),  # Workout tracking
  d5 = enumerate_sf(n = c(2), .did = 5),  # Noise reduction
  d6 = enumerate_sf(n = c(2), .did = 6),  # Modularity
  d7 = enumerate_sf(n = c(4), .did = 7),  # Belt system
  d8 = enumerate_sf(n = c(2), .did = 8),  # Assembly type
  d9 = enumerate_sf(n = c(3), .did = 9)   # Sub-assembly structure (or similar)
)

archs <- archs %>% mutate(id = row_number())
# 1. FUNCTIONS ##################################################
# Create a full decision grid

# cost_metrics <- expand_grid(
#   d1 = enumerate_sf(n = c(2), .did = 1),
#   d2 = enumerate_sf(n = c(4), .did = 2),
#   d3 = enumerate_sf(n = c(3), .did = 3),
#   d4 = enumerate_sf(n = c(2), .did = 4),
#   d5 = enumerate_sf(n = c(2), .did = 5),
#   d6 = enumerate_sf(n = c(2), .did = 6),
#   d7 = enumerate_sf(n = c(4), .did = 7),
#   d8 = enumerate_sf(n = c(2), .did = 8), 
#   d9 = enumerate_sf(n = c(3), .did = 9)
# )
# Cost metric function
get_cost <- function(d1,d2, d3,d4, d5, d6,d7,d8,d9) {
  m1 <- case_when(d1 == 0 ~ 15, d1 == 1 ~ 8)
  m2 <- case_when(d2 == 0 ~ 12, d2 == 1 ~ 6,d2 == 2 ~ 10,d2 == 3 ~ 10)
  m3 <- case_when(d3 == 0 ~ 10, d3 == 1 ~ 20, d3 == 2 ~ 18)
  m4 <- case_when(d4 == 0 ~ 2, d4 == 1 ~ 15)
  m5 <- case_when(d5 == 0 ~ 7, d5 == 1 ~ 9)
  m6 <- case_when(d6 == 0 ~ 10, d6 == 1 ~ 0)
  m7 <- case_when(d7 == 0 ~ 10,d7 == 1 ~ 20,d7 == 2 ~ 5 ,d7 == 3 ~ 10)
  m8 <- case_when(d8 == 0 ~ 8, d8 == 1 ~ 10)
  m9 <- case_when(
    d8 == 0 & d9 == 0 ~ 8 + 15,
    d8 == 0 & d9 == 1 ~ 8 + 10,
    d8 == 0 & d9 == 2 ~ 8 + 7,
    d8 == 1 & d9 == 0 ~ 10 + 15,
    d8 == 1 & d9 == 1 ~ 10 + 10,
    d8 == 1 & d9 == 2 ~ 10 + 7,
    TRUE ~ 0
  )
  # Total manufacturing cost per unit = Cost-D1 + Cost-D2 + Cost-D3 + Cost-D4 + Cost-D5 + Cost-D6 + Cost-D7 + Cost-D8 
  output = m1 + m2 + m3 +m4 + m5 + m6+m7+m8+m9
  
  return(output)
}

# Apply the cost function to the dataset
#data <- cost_metrics %>%
# mutate(cost = get_cost(d1,d2, d3,d4, d5, d6,d7,d8,d9))
#cost_metrics
#data

# Create a full decision grid
# 
# versatility_metrics <- expand_grid(
#   
#   d2 = enumerate_sf(n = c(4), .did = 2),
#   d3 = enumerate_sf(n = c(3), .did = 3),
#   d4 = enumerate_sf(n = c(2), .did = 4),
#   d6 = enumerate_sf(n = c(2), .did = 6),
#   d7 = enumerate_sf(n = c(4), .did = 7),
# )

# Function to compute manufacturing cost
# here we prepare cost function as per decision , for example 
# m1 = if the architecture is built with  decision 1 then the manufacturing cost = 15$ and if it is stationery it will cost 8$
# like wise all decisions are coded

get_versatility <- function(d2, d3,d4,d6,d7) {
  
  m2 <- case_when(d2 == 0 ~ 2, d2 == 1 ~ 1,d2 == 2 ~ 3,d2 == 3 ~ 3)
  m3 <- case_when(d3 == 0 ~ 2, d3 == 1 ~ 3, d3 == 2 ~ 3)
  m4 <- case_when(d4 == 0 ~ 1, d4 == 1 ~ 4)
  m6 <- case_when(d6 == 0 ~ 3, d6 == 1 ~ 1)
  m7 <- case_when(d7 == 0 ~ 3,d7 == 1 ~ 3,d7 == 2 ~ 1,d7 == 3 ~ 1)
  
  
  # V = V-D2 x V-D3 x V-D4 x V-D6 x V-D7
  output = m2 *m3 *m4 *m6*m7
  return(output)
}


# Reliability metric function

# Create a full decision grid
# Reliability_metrics <- expand_grid(
#   
#   d2 = enumerate_sf(n = c(4), .did = 2),
#   d3 = enumerate_sf(n = c(3), .did = 3),
#   d5 = enumerate_sf(n = c(2), .did = 5),
#   d6 = enumerate_sf(n = c(2), .did = 6),
#   d8 = enumerate_sf(n = c(2), .did = 8), 
#   d9 = enumerate_sf(n = c(3), .did = 9)
# )


get_reliability <- function(d2, d3,d5,d6,d8,d9) {
  m2 <- case_when(d2 == 0 ~ 0.95, d2 == 1 ~ 0.97, d2 == 2 ~ 0.96 , d2 == 3 ~ 0.96)
  
  m3 <- case_when(d3 == 0 ~ 0.9, d3 == 1 ~ 0.98, d3 == 2 ~ 0.95)
  m5 <- case_when(d5 == 0 ~ 0.95, d5 == 1 ~ 0.92)
  m6 <- case_when(d6 == 0 ~ 0.95, d6 == 1 ~ 0.99)
  m8 <- case_when(d8 == 0 ~ 0.90, d8 == 1 ~ 0.92)
  
  m9 <- case_when(
    d8 == 0 & d9 == 0 ~ 0.9* 0.88,
    d8 == 0 & d9 == 1 ~ 0.9 * 0.94,
    d8 == 0 & d9 == 2 ~ 0.9 * 0.85,
    d8 == 1 & d9 == 0 ~ 0.92 *0.88,
    d8 == 1 & d9 == 1 ~ 0.92 *0.94,
    d8 == 1 & d9 == 2 ~ 0.92 *0.85,
    TRUE ~ 0
  )
  # All decisions are in series 
  output = m2*m3*m5*m6*m8*m9
  return(output)
}


# 2. METRICS ###########################################################################

archs = archs %>% mutate(cost = get_cost(d1,d2,d3,d4, d5, d6,d7,d8,d9))
archs = archs %>% mutate(versatility = get_versatility(d2, d3,d4,d6,d7))
archs = archs %>% mutate(Reliability = get_reliability(d2,d3,d5,d6,d8,d9))





# 3. Optimization ########################################################

archs2 = archs %>%
  select(
    id
  ) %>%
  mutate(d1 = archs$d1$d1,
         d2 = archs$d2$d2,
         d3 = archs$d3$d3,
         # d4 = archs$d4$d4,
         # d5 = archs$d5$d5,
         # d6 = archs$d6$d6,
         # d7 = archs$d7$d7,
         # d8 = archs$d8$d8,
         # d9 = archs$d9$d9,
         cost = archs$cost,
         versatility = archs$versatility, 
         Reliability = archs$Reliability
  )


archs2

library(GA)
library(rmoo)
# rmoo()
# bit2int()
# constrain()
# f1

archs2$d1 %>% unique()
archs2$d2 %>% unique()
archs2$d3 %>% unique()

bit2int = function(x){
  # valid bitstring
  # x = c(0, 0,0, 0,0)
  xhat1 = GA::binary2decimal(x[1])
  xhat2 = GA::binary2decimal(x[2:3])
  xhat3 = GA::binary2decimal(x[4:5])
  # Return our indtegers  
  xhat = c(xhat1, xhat2, xhat3)
  return(xhat)
  
}

f1 = function(x, nobjs = 2, ...){
  # valid bitstring
  # x = c(0, 0,0, 0,0)
  xhat = bit2int(x)
  m1 = get_cost(d1 = xhat[1], d2 = xhat[2], d3 = xhat[3], d4 = 0, d5 = 0, d6 = 0,d7 = 0, d8 = 0, d9 = 0)    
  m2 = get_reliability(d2 = xhat[2], d3 = xhat[3], d5 = 0, d6 = 0, d8 = 0, d9 = 0)    
  
  output = matrix(c(m1,m2), nrow = 1)
  return(output)
}

o = rmoo(
  fitness = f1, type = "binary", algorithm = "NSGA-III",
  # Upper and Lower bounds on the bitstrings
  lower = c(0,0,0,0,0), upper = c(1,1,1,1,1),
  # Settings
  monitor = TRUE, summary = TRUE,
  nObj = 2, nBits = 5, popSize = 50, maxiter = 100
)

summary(o)
o@solution # multi-objective pareto front (in binary)
bit2int(o@solution) # 

