# Script: 08_architecting_metric_design.R
# Original: example_metrics.R
# Topic: Metric design walkthrough
# Section: Architecting Systems
# Developed by: Timothy Fraser, PhD
# example_metrics.R
# This is a sccript that can be run
# To return a matrix of `archs`
# with cost, benefit, and risk metrics calculated

library(dplyr)
library(archr)

archs = enumerate_binary(n = 5, .id = TRUE)


# 1. FUNCTIONS ##################################################

# Cost metric function
get_cost = function(d1,d2,d3,d4,d5){
  m1 = case_when(d1 == 1 ~ 40, TRUE ~ 0)
  m2 = case_when(d2 == 1 ~ 750, TRUE ~ 0)
  m3 = case_when(d3 == 1 ~ 200, TRUE ~ 0)
  m4 = case_when(d4 == 1 ~ 500, TRUE ~ 0)
  m5 = case_when(d5 == 1 ~ 1000, TRUE ~ 0)
  output = m1+m2+m3+m4+m5
  return(output)
}

# Benefit metric function
get_benefit = function(d1,d2,d3,d4,d5){
  # 10-point ordinal scale
  m1 = case_when(d1 == 1 ~ 3, TRUE ~ 2)
  m2 = case_when(d2 == 1 ~ 2, TRUE ~ 4)
  m3 = case_when(d3 == 1 ~ 5, TRUE ~ 7)
  m4 = case_when(d4 == 1 ~ 9, TRUE ~ 2)
  m5 = case_when(d5 == 1 ~ 5, TRUE ~ 3)
  output = m1+m2+m3+m4+m5
  return(output)
}

# Reliability metric function
get_reliability = function(t = 100, d1,d2,d3,d4,d5){
  # Several ways to model a decision's impact on overall reliability...
  # Option 1:
  # If we adopt technology d1=1, the failure rate is 1/1000, so the reliability at time t will be...
  p1 = case_when(d1 == 1 ~ 1 - pexp(t, rate = 1/1000),
                 # If we DON'T adopt that technology, the OTHER technology has a failure rate of 1/10000
                 d1 == 0 ~ 1 - pexp(t, rate = 1/10000))
  # Option 2:
  p2 = case_when(
    # If we adopt tech d2=1....
    d2 == 1 ~ 1 - pexp(t, rate = 1/2000),
    # If we DON'T adopt tech d2=1, no tech to fail, so R=1
    TRUE ~ 1)
  p3 = case_when(d3 == 1 ~ 1 - pexp(t, rate = 1/15000), TRUE ~ 1)
  p4 = case_when(d4 == 1 ~ 1 - pexp(t, rate = 1/5000), TRUE ~ 1)
  # Option 3:
  # Maybe d5 has no relevance to operational risk.
  # p5 = case_when(d1 == 1 ~ 1 - pexp(t, rate = 1/500000), TRUE ~ 1)
  # Whether d5=1 or d5=0, reliability will still be 100%
  p5 = 1
  
  output = p1*p2*p3*p4*p5
  return(output)
}

# 2. METRICS ###########################################################################
archs = archs %>% mutate(cost = get_cost(d1,d2,d3,d4,d5))
archs = archs %>% mutate(benefit = get_benefit(d1,d2,d3,d4,d5))
archs = archs %>% mutate(reliability = get_reliability(t = 1000, d1,d2,d3,d4,d5))
