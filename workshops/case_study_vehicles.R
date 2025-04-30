# case_study_vehicles.R

library(dplyr)
library(GA)
library(rmoo)

# design a set of policies in Tompkins County that optimizes...

# - minimizes emissions, 
# - max usage of buses

# d1 - congestion toll (0/1)
# d2 - buy more buses (0/1)
# d3 - invest in jetpacks (0/1)

# 300,000 tons of CO2e in Tompkins county 
get_emissions = function(d1,d2,d3){
  # If I enact a congestion toll
  m1 = case_when(d1 == 1 ~ 100000, TRUE ~ 0)
  # If I buy more buses
  m2 = case_when(d2 == 1 ~ 30000, TRUE ~ 0)
  # If I invest in jetpacks,
  m3 = case_when(d3 == 1 ~ 5000, TRUE ~ 0)
  # Get remaining emissions
  output = 300000 - (m1+m2+m3)
  
  # What is our highest possible emissions level?
  max = 300000
  # What is our lowest possible emissions level?
  min = 300000 - 100000 - 30000 - 5000
  
  # Let's rescale this so that...
  # 1 = most emissions; 0 = least emissions 
  rescaled = (output - min) / (max - min) 
  
  # Let's rescale this so that high means 'better'
  # 1 = least emissions; 0 = most emissions
  output = 1 - rescaled
  
  return(output)
}

get_riders = function(d1,d2){
  # riders = 10,000 people
  # If congestion toll
  m1 = case_when(d1 == 1 ~ 5000, TRUE ~ 0)
  # If I buy more buses
  m2 = case_when(d2 == 1 ~ 10000, TRUE ~ 0)
  # Get resulting total # of bus riders
  output =10000 + (m1 + m2)
  
  # Highest possible # of riders  
  max = 10000 + 5000 + 10000
  # Lowest possible # of riders
  min = 10000
  
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

f1 = function(x, nobj = 2, ...){
  # Get our bits vector x
  # turn it into integer vector xhat
  xhat = bit2int(x)
  # Get our metrics
  m1 = get_emissions(d1 = xhat[1], d2 = xhat[2], d3 = xhat[3])
  
  m2 = get_riders(d1 = xhat[1], d2 = xhat[2])
  # Format as a matrix
  output = matrix(c(m1,m2), nrow = 1)
  return(output)
}


o = rmoo(
  fitness = f1, type = "binary", algorithm = "NSGA-III",
  lower = c(0,0,0), upper = c(1,1,1), monitor = TRUE, summary = TRUE,
  nObj = 2, nBits = 3, popSize = 50, maxiter = 100
)

data = o@solution %>%
  as_tibble() %>%
  select(d1 = x1, d2 = x2, d3 = x3) %>%
  mutate(emissions = get_emissions(d1 = d1, d2 = d2, d3 = d3),
         riders = get_riders(d1 = d1, d2 = d2))

ggplot() +
  geom_point(data = data, mapping = aes(x = riders, y = emissions))

# archr::enumerate_sf(n = c(2,2,2))

