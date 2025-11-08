# Script: 20_enumeration_custom_metrics.R
# Original: tutorial_enumeration_7.R
# Topic: Custom metric development
# Section: Enumeration
# Developed by: Timothy Fraser, PhD
# tutorial_enumeration_7.R

# An example of stratified sampling from a 2^3 size architectural matrix
# Pairs with slides

library(dplyr)
library(archr)



# Can be hard to compare visually, but let's check them numerically...
get_percentages = function(x, did = "d2"){
  # Testing values
  #x = mini$d2
  
  # Get the tally per alternative  
  tally = tibble(altid = x) %>%
    group_by(altid) %>%
    summarize(count = n())
  # Calculate percentages
  percentages = tally %>% 
    mutate(total = sum(count)) %>%
    mutate(percent = count / total) %>%
    mutate(label = round(percent * 100, 1)) %>%
    mutate(label = paste0(label, "%"))
  # Add a decision id and format
  percentages = percentages %>% 
    mutate(did = did) %>%
    select(did, altid, count, total, percent, label)
  
  return(percentages)
}

# Make an architecture matrix of 3 binary decisions
a = enumerate_sf(n = c(2,2,2))


# Repeat this code several times.
sample = a %>%
  group_by(d1) %>%
  sample_n(size = 2) 

get_percentages(x = sample$d1, did = "d1")
get_percentages(x = sample$d2, did = "d2")
get_percentages(x = sample$d3, did = "d3")

# See how the breakdown for d1 is ALWAYS even?

# But the breakdown for d3 isn't always even?


# One way to improve balance is to stratify by MULTIPLE variables.
# (though NEVER by ALL variables)
sample = a %>%
  group_by(d1, d2) %>%
  sample_n(size = 2) 

get_percentages(x = sample$d1, did = "d1")
get_percentages(x = sample$d2, did = "d2")
get_percentages(x = sample$d3, did = "d3")

# A little better!
rm(list = ls())
