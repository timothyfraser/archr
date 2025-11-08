# Script: 19_enumeration_filters.R
# Original: tutorial_enumeration_6.R
# Topic: Filtering enumerated architectures
# Section: Enumeration
# Developed by: Timothy Fraser, PhD
#' @name tutorial_enumeration_6.R

# Script to compare **what kind of random sampling is most helpful for enumeration**

# Load packages
library(dplyr) # for data wrangling
library(ggplot2) # for plotting
library(ggpubr) # for combining plots 


# random sample from a uniform distribution
# -- 2 parameters min (a) and max (b)
runif(n = 5, min = 0, max = 10)


# Suppose we have 10000 architectures,
# each with an x, y, and z metrics
data = tibble(
  x = runif(n = 10000, min = 0, max = 1),
  y = runif(n = 10000, min = 0, max = 1),
  z = sample(x = c("a", "b", "c"), size = 10000, replace = TRUE)) %>%
  # Also, we'll just create some stratifying variables for later.
  mutate(x_quarters = ntile(x, 4),
       y_quarters = ntile(y, 4))

# Population
g1 = ggplot() +
  geom_point(data = data, mapping = aes(x = x, y = y, color = z),
             alpha = 0.5)

# The whole population would look like this...
g1


# Pure Random Sample
# Use sample_n() to sample 100 architectures
sample1 = data %>%
  sample_n(size = 1000)

# A purely random sample would look like this...
g2 = ggplot() +
  geom_point(data = sample1, mapping = aes(x = x, y = y, color = z), 
             alpha = 0.5)

g2

sample2 = data %>%
  group_by(x_quarters, y_quarters, z) %>%
  sample_n(size = round(1000/(4*4*3)))


g3 = ggplot() +
  geom_point(data = sample2, mapping = aes(x = x, y = y, color = z), 
             alpha = 0.5)
library(ggpubr)

ggarrange(g2,g3, nrow = 1)



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


# What's the breakdown by our 3 stratifying variables?
get_percentages(x = sample2$x_quarters)
get_percentages(x = sample2$y_quarters)
get_percentages(x = sample2$z)

# Compare that to the pure random sample
get_percentages(x = sample1$x_quarters)
get_percentages(x = sample1$y_quarters)
get_percentages(x = sample1$z)

# Fairly similar, but some cases are quite off.


# Clean up!
rm(list = ls())


