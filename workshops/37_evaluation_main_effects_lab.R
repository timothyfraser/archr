# Script: 37_evaluation_main_effects_lab.R
# Original: tutorial_tradespace_3.R
# Topic: Main effects lab
# Section: Evaluation
# Developed by: Timothy Fraser, PhD
#' @name tutorial_tradespace_3.R
#' @author Tim Fraser

# MAIN EFFECTS #####################################################


# Enumerate Architectures
# Example from Slides in Class
data = enumerate_sf(n = c(2, 3, 2)) %>%
  # Add metrics
  mutate(m1 = c(33,73, 40, 80, 30, 70, 66, 146, 80, 160, 60, 140),
         m2 = c(0.8910, 0.9801, 0.8991, 0.9890, 0.4500, 0.4950, 0.9899, 0.9998, 0.9900, 0.9999, 0.7425, 0.7499))


data


# Calculate main effect
me = function(data, decision = "d2", value = 1, metric = "m1"){
  # Testing values
  # decision = "d2"; value = 1; metric = "m1"
  data2 = data %>%
    # Grab any columns with these character strings as their column names
    select(any_of(c(alt = decision, metric = metric))) %>%
    # Add a decision column
    mutate(decision = decision) %>%
    # Reorder them
    select(decision, alt, metric)
  # Calculate effect
  data3 = data2 %>%
    summarize(
      xhat = mean(metric[alt == value], na.rm = TRUE),
      x = mean(metric[alt != value], na.rm = TRUE),
      dbar = xhat - x  
    )
  output = data3$dbar  
  
  return(output)
}


# Get main effects for each level
me1 = me(data, decision = "d2", value = 1, metric = "m1")
me2 = me(data, decision = "d2", value = 0, metric = "m1")
me3 = me(data, decision = "d2", value = 2, metric = "m1")

# Calculate sensitivity
(abs(me1) + abs(me2) + abs(me3)) / 3

# SENSITIVITY FUNCTION #############################

## OLD VERSION ####################################
# Let's build a sensitivity function you can use to get 1 sensitivity score.

# # Beginning attempt at a sensitivity
# sensitivity = function(data, decision = "d2", metric = "m1"){
#   # Testing Values
#   # decision = "d2"; metric = "m1"
#   # Get values for your ith decision
#   values = unlist(unique(data[, decision]))
#    
#   
#   # Create a table to hold my results
#   holder = tibble(values = values, me = NA_real_)
#   for(i in 1:length(values)){
#     holder$me[i] = me(data, decision = decision, value = values[i], metric = metric)
#   }
#   
#   s = holder %>%
#     summarize(stat = mean(abs(me)))
#   
#   output = s$stat
#   return(output)    
# }
# 
# # Try it
# sensitivity(data, decision = "d2", metric = "m1")
# sensitivity(data, decision = "d1", metric = "m1")
# sensitivity(data, decision = "d3", metric = "m1")
# sensitivity(data, decision = "d1", metric = "m2")
# sensitivity(data, decision = "d2", metric = "m2")
# sensitivity(data, decision = "d3", metric = "m2")
# 
# # Can we make a get_sensitivity() that gets sensitivity scores for EVERY decision and EVERY metric?
# 
# get_sensitivity = function(data, decisions = c("d1", "d2"), metrics = c("m1", "m2")){
#   # Testing values  
#   # decisions = c("d1", "d2"); metrics = c("m1", "m2")
#   # Get a grid of all submitted decision-metric pairs
#   output = expand_grid(
#     decision = decisions,
#     metric = metrics
#   ) %>%
#   # Assign each a unique ID
#   mutate(id = 1:n()) %>%
#   # For each pair,
#   group_by(id, decision, metric) %>%
#   # Calculate sensitivity
#   summarize(sensitivity = sensitivity(data = data, decision = decision, metric = metric))
#   
#   return(output)
# }

# Let's try using this function to get sensitivity scores for every decision and metric
#get_sensitivity(data, decisions = c("d1", "d2", "d3"), metrics = c("m1","m2"))

## NEW VERSION #############################

# I'd suggest you use the final versions of these functions developed in:
# 00_sensitivity_connectivity_utilities.R
source("workshops/00_sensitivity_connectivity_utilities.R")

# Let's try using this function to get sensitivity scores for every decision and metric
sensitivity(data, decision_i = "d1", metric = "m1")
connectivity(data, decision_i = "d3", decisions = c("d1", "d2", "d3"), metric = "m1")

# PLOTTING #####################################################

library(dplyr)
library(ggplot2)

# An example data.frame matching what we just talked about in lecture

data = tibble(
  decision = c("D1", "D2", "D3", "D1", "D2", "D3"),
  sensitivity = c(5, 20, 30, 5, 10, 15),
  connectivity = c(8, 30, 20, 2, 5, 30),
  metric = c("cost", "cost", "cost", "benefit", "benefit", "benefit")
) %>%
  mutate(metric = case_when(
    metric == "cost" ~ "Cost (USD)",
    metric == "benefit" ~ "Range (Mi)"
  ))

quandrants = tibble(
  label = c("Q1", "Q2", "Q3", "Q4"),
  sensitivity = c(18, 18, 12, 12),
  connectivity = c(18, 12,18,  12)
)

divisions = data %>%
  summarize(sensitivity = (max(sensitivity) - 0) / 2,
            connectivity = (max(connectivity) - 0) / 2 )

gg = ggplot() +
  # Plot points
  geom_point(
    data = data, 
    mapping = aes(
      x = connectivity, y = sensitivity, 
      color = metric),
    size = 15
  ) +
  # Plot labels for points on top
  geom_text(
    data = data,
    mapping = aes(
      x = connectivity, y = sensitivity,
      label = decision
    )
  ) +
  # geom_hline(yintercept = 15) +
  # geom_vline(xintercept = 15) +
  geom_hline(data = divisions, mapping = aes(yintercept = sensitivity)) +
  geom_vline(data = divisions, mapping = aes(xintercept = connectivity)) +
  # Pop some labels for quandrants
  geom_text(
    data = quandrants,
    mapping = aes(
      x = sensitivity, y = connectivity,
      label = label),
    color = "darkgrey"
    ) +
  theme_bw() +
  # Specify the limits
  scale_y_continuous(limits = c(0, 30)) +
  scale_x_continuous(limits = c(0, 30)) +
  # Put legend on bottom
  theme(legend.position = "bottom")


# Split up into panels
gg + 
  facet_wrap(~metric, scales = "free")
  
# Or make plots separately then put them side by side
# ggpubr
# ggarrange()




