# case_study_dashboard.R

library(dplyr)
library(readr)
library(archr)

# An idea of how to make your own get_cost() function
# for an architecture for a dashboard

a = tibble(
  # Mobile 0 or Web 1 or Both 2
  d1 = 1,
  # Navigation Structure (A = 0 or B = 1)
  d2 = 1,
  # Customizable (no = 0 or yes = 1)
  d3 = 0
)

# **Option A: Super Specific**
# testing values
# d1 = 1; d2 = 1; d3 = 0
get_cost = function(d1,d2,d3){
  m1_cost = case_when(
    d1 == 0 ~ 150,
    d1 == 1 ~ 150,
    d1 == 2 ~ 200
  )
  
  m2_hours = case_when(
    d2 == 0 ~ 10, # hours
    d2 == 1 ~ 10 # hours
  )
  
  # m1_cost * m2_hours
  m3_hours = case_when(
    d3 == 0 ~ 0, # hours
    d3 == 1 ~ 50 # hours
  )
  
  # total cost
  metric = m1_cost * (m2_hours + m3_hours)
  return(metric)
}



# **Option B: Less Specific**

# likert scale - 3 point (low = 0, medium = 1, high = 2)
m1 = case_when(
  d1 == 0 ~ 0,
  d1 == 1 ~ 0,
  d1 == 2 ~ 1
)
m2 = case_when(
  d2 == 0 ~ 1,
  d2 == 1 ~ 1
)

m1 + m2
mean(c(m1,m2)) # average cost on a 3 point scale from low = 0 to high = 2


