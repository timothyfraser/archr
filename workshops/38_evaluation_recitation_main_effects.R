# Script: 38_evaluation_recitation_main_effects.R
# Original: tutorial_tradespace_3 (recitation april 11)
# Topic: Recitation on main effects
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

me = function(data, decision = "d2", value = 1, metric = "m1"){
  data2 = data %>%
    select(any_of(c(alt = decision, metric = metric))) %>%
    mutate(decision = decision) %>%
    select(decision, alt, metric)
  data3 = data2 %>%
    summarize(
      xhat = mean(metric[alt == value], na.rm = TRUE),
      x = mean(metric[alt != value], na.rm = TRUE),
      dbar = xhat - x  
    )
  output = data3$dbar  
  
  return(output)
}

me1 = me(data, decision = "d2", value = 1, metric = "m1")
me2 = me(data, decision = "d2", value = 0, metric = "m1")
me3 = me(data, decision = "d2", value = 2, metric = "m1")

(abs(me1) + abs(me2) + abs(me3)) / 3

# SENSITIVITY FUNCTION #############################

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



