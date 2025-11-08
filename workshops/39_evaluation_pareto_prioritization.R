# Script: 39_evaluation_pareto_prioritization.R
# Original: tutorial_tradespace_4.R
# Topic: Pareto prioritization workshop
# Section: Evaluation
# Developed by: Timothy Fraser, PhD
#' @name tutorial_tradespace_4.R
#' @author Tim Fraser
#' @description
#' Tutorial on how to make a really nice pareto rank plot!

# 0. SETUP ##################################
library(dplyr)
library(archr)
library(ggplot2)
# Let's run this script,
# getting a data.frame of architectures `archs`
# with `cost`, `benefit`, and `risk` metrics
source("workshops/08_architecting_metric_design.R")


# 1. PARETO RANK #############################################

# Here's a new function - it's actually the same as archr::pareto(),
# just with a light adjustment to the very last line.
# archr::pareto() turns the pareto rank into TRUE/FALSE
# this pareto_rank() function just returns the raw pareto ranks.
source("workshops/00_pareto_rank_utilities.R")

# 2. VISUALIZE ######################################

# Here are a few ideas for visualizing the pareto rank space.

# First, we could try...


## 2.1 COLOR SCALE ###########################

# Pareto Rank as Color, with Front as a Line

# Let's get the pareto front (TRUE / FALSE)
archs = archs %>% mutate(front = pareto(x = cost, y = -benefit))
# Then, let's get the pareto rank (0, 1,2,3,... infinity)
archs = archs %>% mutate(rank = pareto_rank(x = cost, y = -benefit))


archs %>% glimpse()


# Visualize!
ggplot() +
  geom_point(data = archs, mapping = aes(
    x = benefit, y = cost,
    color = rank)) +
  geom_line(
    data = archs %>% filter(front == TRUE),
    mapping = aes(x = benefit, y = cost),
    color = "blue") +
  # Add a color scale
  scale_color_gradient(low = "blue", high = "black") +
  # Remember to Label
  labs(x = "Benefit", y = "Cost", color = "Pareto Rank")


# In fact, we could probably spice this up 
# if we add some outlines to each point.

ggplot() +
  # Plot the front beneath everything
  geom_line(
    data = archs %>% filter(front == TRUE),
    mapping = aes(x = benefit, y = cost),
    color = "steelblue") +
  # Add a point layer with black, large points
  geom_point(
    data = archs,
    mapping = aes(x = benefit, y = cost),
    color = "black", size = 2) +
  # Add a point layer with color gradient, slightly smaller points.
  geom_point(data = archs, mapping = aes(
    x = benefit, y = cost,
    color = rank), size = 1.5) +
  # Add a color scale
  scale_color_gradient(low = "steelblue", high = "white")  +
  # Remember to Label
  labs(x = "Benefit", y = "Cost", color = "Pareto Rank")


## 2.2 COLOR GROUPS ###########################

# Alternatively, we could use color to show thresholds

# Let's get the pareto front (TRUE / FALSE)
archs = archs %>% mutate(front = pareto(x = cost, y = -benefit))
# Then, let's get the pareto rank (0, 1,2,3,... infinity)
archs = archs %>% mutate(rank = pareto_rank(x = cost, y = -benefit))

# Visualize!

ggplot() +
  # Visuals all points
  geom_point(
    data = archs,
    mapping = aes(x = benefit, y = cost, color = "Others"), size = 2) +
  # Visualize overtop just the Rank < 5 points 
  geom_point(
    data = archs %>% filter(rank < 5),
    mapping = aes(x = benefit, y = cost, color = "Rank < 5"), size = 2) +
  # Visualize overtop just the Rank < 0 points
  geom_point(
    data = archs %>% filter(rank == 0),
    mapping = aes(x = benefit, y = cost, color = "Rank = 0"), size = 2) +
  # Remember to Label
  labs(x = "Benefit", y = "Cost", color = "Pareto Rank")


## 2.3 LABELS ################################

# Plotting text values

# Let's get the pareto front (TRUE / FALSE)
archs = archs %>% mutate(front = pareto(x = cost, y = -benefit))

# Then, let's get the pareto rank (0, 1,2,3,... infinity)
archs = archs %>% mutate(rank = pareto_rank(x = cost, y = -benefit))

# Plot the raw scores - only a good idea if you have a small number of architectures.
ggplot() +
  # _text puts the numbers, no white outline
  # geom_text(data = archs, mapping = aes(x = benefit, y = cost, label = rank, color = rank))
  # _label puts the numbers with a nice white outline 
  geom_label(data = archs, mapping = aes(x = benefit, y = cost, label = rank, color = rank))


# You could even try something like earlier, but with labels
ggplot() +
  geom_label(
    data = archs, 
    mapping = aes(x = benefit, y = cost, label = rank, fill = "Others"),
    color = "white") +
  geom_label(
    data = archs %>% filter(rank < 10), 
    mapping = aes(x = benefit, y = cost, label = rank, fill = "Rank < 10"),
    color = "white") +
  geom_label(
    data = archs %>% filter(rank < 5), 
    mapping = aes(x = benefit, y = cost, label = rank, fill = "Rank < 5"),
    color = "white") +
  geom_label(
    data = archs %>% filter(rank == 0), 
    mapping = aes(x = benefit, y = cost, label = rank, fill = "Rank = 0"),
    color = "white") +
  # I really like the viridis color scale
  # You'll have to install it first though 
  # run --> install.packages("viridis")
  viridis::scale_fill_viridis(option = "plasma", discrete = TRUE, 
                              begin = 0.2, end = 0.8) +
  # Remember to Label
  labs(x = "Benefit", y = "Cost", fill = "Pareto Rank")

#install.packages("viridis")
# viridis


## 2.4 LINES ################################

# Pareto Rank as a series of lines

# Let's get the pareto front (TRUE / FALSE)
archs = archs %>% mutate(front = pareto(x = cost, y = -benefit))
# Then, let's get the pareto rank (0, 1,2,3,... infinity)
archs = archs %>% mutate(rank = pareto_rank(x = cost, y = -benefit))

# Get some upper lines

# Create an upper threshold line...
# when rank = 0
line0 = archs %>%
  filter(rank == 0) %>%
  group_by(benefit) %>%
  summarize(cost_upper = max(cost),
            type = "Rank = 0")

# when rank < 5
line5 = archs %>%
  filter(rank < 5) %>%
  group_by(benefit) %>%
  summarize(cost_upper = max(cost),
            type = "Rank < 5")

# when rank < 10
line10 = archs %>%
  filter(rank < 10) %>%
  group_by(benefit) %>%
  summarize(cost_upper = max(cost),
            type = "Rank < 10")

# Bundle them into one data.frame
lines = bind_rows(line0, line5, line10)

# Visualize!
ggplot() +
  # Plot normal points
  geom_point(data = archs, mapping = aes(
    x = benefit, y = cost)) +
  # Atop them, plot a bunch of lines
  geom_line(data = lines,
            mapping = aes(x = benefit, y = cost_upper,
                          group = type, color = type)) +
  # Remember to Label
  labs(x = "Benefit", y = "Cost", color = "Pareto Rank")


## 2.5 AREA ###############################

# Map pareto rankings with geom_area()

# Let's get the pareto front (TRUE / FALSE)
archs = archs %>% mutate(front = pareto(x = cost, y = -benefit))
# Then, let's get the pareto rank (0, 1,2,3,... infinity)
archs = archs %>% mutate(rank = pareto_rank(x = cost, y = -benefit))

# Get some upper lines

# Create an upper threshold line...
# when rank = 0
line0 = archs %>%
  filter(rank == 0) %>%
  group_by(benefit) %>%
  summarize(cost_upper = max(cost),
            type = "Rank = 0")
# when rank < 5
line5 = archs %>%
  filter(rank < 5) %>%
  group_by(benefit) %>%
  summarize(cost_upper = max(cost),
            type = "Rank < 5")
# when rank < 10
line10 = archs %>%
  filter(rank < 10) %>%
  group_by(benefit) %>%
  summarize(cost_upper = max(cost),
            type = "Rank < 10")
# when rank is 10 or more
line10plus = archs %>%
  group_by(benefit) %>%
  summarize(cost_upper = max(cost),
            type = "Rank >= 10")

# Visualize!
ggplot() +
  # Atop them, plot a bunch of ribbons, 
  # where y is the upper edge and 0 is the lower
  
  # Atop them, plot a bunch of lines
  # Start with the largest area
  geom_ribbon(
    data = line10plus,
    mapping = aes(x = benefit, ymin = 0, ymax = cost_upper, 
                  fill = "Others"), color = "white")  +
  # Overlap the next largest area
  geom_ribbon(
    data = line10,
    mapping = aes(x = benefit, ymin = 0, ymax = cost_upper, 
                  fill = "Rank < 10"), color = "white")  +
  # Next largest area
  geom_ribbon(
    data = line5,
    mapping = aes(x = benefit, ymin = 0, ymax = cost_upper, 
                  fill = "Rank < 5"), color = "white")  +
  # Smallest area
  geom_ribbon(
    data = line0,
    mapping = aes(x = benefit, ymin = 0, ymax = cost_upper,
                  fill = "Rank = 0"), color = "white")  +
  # Plot normal points, with a nice white outline
  geom_point(data = archs, mapping = aes(
      x = benefit, y = cost), color = "white", size = 2)  +
  geom_point(data = archs, mapping = aes(
    x = benefit, y = cost), color = "black", size = 1.5)  +
  # Add a fill scale
  # I really like the viridis color scale
  # You'll have to install it first though 
  # run --> install.packages("viridis")
  viridis::scale_fill_viridis(option = "plasma", discrete = TRUE, begin = 0.2, end = 0.8) +
  # Remember to Label
  labs(x = "Benefit", y = "Cost", fill = "Pareto Rank")






