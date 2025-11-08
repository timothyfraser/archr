---
title: "[39] Pareto prioritization workshop Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `39_evaluation_pareto_prioritization.R` and unpacks the workshop on pareto prioritization workshop. You will see how it advances the Evaluation sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `39_evaluation_pareto_prioritization.R` within the Evaluation module.
- Connect the topic "Pareto prioritization workshop" to systems architecting decisions.
- Install any required packages highlighted with `install.packages()`.
- Load packages with `library()` and verify they attach without warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or architecture tables.
- Iterate on visualisations built with `ggplot2`.

## Application

### Step 1 – Load Packages

0. SETUP ##################################. Attach dplyr to make its functions available.


``` r
library(dplyr)
library(archr)
library(ggplot2)
# Let's run this script,
# getting a data.frame of architectures `archs`
# with `cost`, `benefit`, and `risk` metrics
source("workshops/08_architecting_metric_design.R")
```

### Step 2 – Run the Code Block

Here's a new function - it's actually the same as archr::pareto(), just with a light adjustment to the very last line. archr::pareto() turns the pareto rank into TRUE/FALSE this pareto_rank() function just returns the raw pareto ranks.


``` r
source("workshops/00_pareto_rank_utilities.R")
```

### Step 3 – Practice the Pipe

Let's get the pareto front (TRUE / FALSE).


``` r
archs = archs %>% mutate(front = pareto(x = cost, y = -benefit))
# Then, let's get the pareto rank (0, 1,2,3,... infinity)
archs = archs %>% mutate(rank = pareto_rank(x = cost, y = -benefit))
```

### Step 4 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
archs %>% glimpse()
```

### Step 5 – Start a ggplot

Visualize! Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
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
```

### Step 6 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
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
```

### Step 7 – Practice the Pipe

Let's get the pareto front (TRUE / FALSE).


``` r
archs = archs %>% mutate(front = pareto(x = cost, y = -benefit))
# Then, let's get the pareto rank (0, 1,2,3,... infinity)
archs = archs %>% mutate(rank = pareto_rank(x = cost, y = -benefit))
```

### Step 8 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
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
```

### Step 9 – Practice the Pipe

Let's get the pareto front (TRUE / FALSE).


``` r
archs = archs %>% mutate(front = pareto(x = cost, y = -benefit))
```

### Step 10 – Practice the Pipe

Then, let's get the pareto rank (0, 1,2,3,... infinity).


``` r
archs = archs %>% mutate(rank = pareto_rank(x = cost, y = -benefit))
```

### Step 11 – Start a ggplot

Plot the raw scores - only a good idea if you have a small number of architectures.


``` r
ggplot() +
  # _text puts the numbers, no white outline
  # geom_text(data = archs, mapping = aes(x = benefit, y = cost, label = rank, color = rank))
  # _label puts the numbers with a nice white outline 
  geom_label(data = archs, mapping = aes(x = benefit, y = cost, label = rank, color = rank))
```

### Step 12 – Start a ggplot

You could even try something like earlier, but with labels.


``` r
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
```

### Step 13 – Practice the Pipe

Let's get the pareto front (TRUE / FALSE).


``` r
archs = archs %>% mutate(front = pareto(x = cost, y = -benefit))
# Then, let's get the pareto rank (0, 1,2,3,... infinity)
archs = archs %>% mutate(rank = pareto_rank(x = cost, y = -benefit))
```

### Step 14 – Practice the Pipe

Create an upper threshold line... when rank = 0.


``` r
line0 = archs %>%
  filter(rank == 0) %>%
  group_by(benefit) %>%
  summarize(cost_upper = max(cost),
            type = "Rank = 0")
```

### Step 15 – Practice the Pipe

when rank < 5.


``` r
line5 = archs %>%
  filter(rank < 5) %>%
  group_by(benefit) %>%
  summarize(cost_upper = max(cost),
            type = "Rank < 5")
```

### Step 16 – Practice the Pipe

when rank < 10.


``` r
line10 = archs %>%
  filter(rank < 10) %>%
  group_by(benefit) %>%
  summarize(cost_upper = max(cost),
            type = "Rank < 10")
```

### Step 17 – Create `lines`

Bundle them into one data.frame.


``` r
lines = bind_rows(line0, line5, line10)
```

### Step 18 – Start a ggplot

Visualize! Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
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
```

### Step 19 – Practice the Pipe

Let's get the pareto front (TRUE / FALSE).


``` r
archs = archs %>% mutate(front = pareto(x = cost, y = -benefit))
# Then, let's get the pareto rank (0, 1,2,3,... infinity)
archs = archs %>% mutate(rank = pareto_rank(x = cost, y = -benefit))
```

### Step 20 – Practice the Pipe

Create an upper threshold line... when rank = 0.


``` r
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
```

### Step 21 – Start a ggplot

Visualize! Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  # Atop them, plot a bunch of ribbons, 
  # where y is the upper edge and 0 is the lower
```

### Step 22 – Run the Code Block

Atop them, plot a bunch of lines Start with the largest area.


``` r
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
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "39_evaluation_pareto_prioritization.R"))` from the Console or press the Source button while the script is active.

</details>

**Learning Check 2.** Why does the script begin by installing or loading packages before exploring the exercises?

<details>
<summary>Show answer</summary>

Those commands make sure the required libraries are available so every subsequent code chunk runs without missing-function errors.

</details>

**Learning Check 3.** How does the `%>%` pipeline help you reason about multi-step transformations in this script?

<details>
<summary>Show answer</summary>

It keeps each operation in sequence without creating temporary variables, so you can narrate the data story line by line.

</details>

**Learning Check 4.** What experiment can you run on the `ggplot` layers to understand how aesthetics map to data?

<details>
<summary>Show answer</summary>

Switch one aesthetic (for example `color` to `fill` or tweak the geometry) and re-run the chunk to observe the difference.

</details>
