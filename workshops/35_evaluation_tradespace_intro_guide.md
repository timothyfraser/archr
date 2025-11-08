---
title: "[35] Tradespace introduction Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `35_evaluation_tradespace_intro.R` and unpacks the workshop on tradespace introduction. You will see how it advances the Evaluation sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `35_evaluation_tradespace_intro.R` within the Evaluation module.
- Connect the topic "Tradespace introduction" to systems architecting decisions.
- Install any required packages highlighted with `install.packages()`.
- Load packages with `library()` and verify they attach without warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or architecture tables.
- Define custom functions to package repeatable logic.
- Iterate on visualisations built with `ggplot2`.

## Application

### Step 1 – Load Packages

Attach dplyr to make its functions available.


``` r
library(dplyr)
library(archr)
library(ggplot2)
```

### Step 2 – Create `archs`

Create the object `archs` so you can reuse it in later steps.


``` r
archs = enumerate_binary(n = 5, .id = TRUE)
```

### Step 3 – Define `get_cost()`

Cost metric function. Create the helper function `get_cost()` so you can reuse it throughout the workshop.


``` r
get_cost = function(d1,d2,d3,d4,d5){
  m1 = case_when(d1 == 1 ~ 40, TRUE ~ 0)
  m2 = case_when(d2 == 1 ~ 750, TRUE ~ 0)
  m3 = case_when(d3 == 1 ~ 200, TRUE ~ 0)
  m4 = case_when(d4 == 1 ~ 500, TRUE ~ 0)
  m5 = case_when(d5 == 1 ~ 1000, TRUE ~ 0)
  output = m1+m2+m3+m4+m5
  return(output)
}
```

### Step 4 – Define `get_benefit()`

Benefit metric function. Create the helper function `get_benefit()` so you can reuse it throughout the workshop.


``` r
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
```

### Step 5 – Define `get_reliability()`

Reliability metric function. Create the helper function `get_reliability()` so you can reuse it throughout the workshop.


``` r
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
```

### Step 6 – Create `output`

Create the object `output` so you can reuse it in later steps.


``` r
  output = p1*p2*p3*p4*p5
  return(output)
}
```

### Step 7 – Practice the Pipe

2. METRICS ###########################################################################. Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
archs = archs %>% mutate(cost = get_cost(d1,d2,d3,d4,d5))
archs = archs %>% mutate(benefit = get_benefit(d1,d2,d3,d4,d5))
archs = archs %>% mutate(reliability = get_reliability(t = 1000, d1,d2,d3,d4,d5))
```

### Step 8 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
archs
```

### Step 9 – Load Packages

3. PAIRWISE CORRELATION PLOT ######################################################### install.packages("GGally").


``` r
library(GGally)
archs %>%
  select(cost, benefit, reliability) %>%
  GGally::ggpairs(data = ., title = "Title")
```

### Step 10 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
?ggpairs
# https://ggobi.github.io/ggally/articles/ggpairs.html
```

### Step 11 – Create `gg1`

Create the object `gg1` so you can reuse it in later steps.


``` r
gg1 = ggplot() + geom_point(data = archs, mapping = aes(x = benefit, y = cost)) + theme_bw()
gg2 = ggplot() + geom_point(data = archs, mapping = aes(x = benefit, y = reliability)) + theme_bw()
gg3 = ggplot() + geom_point(data = archs, mapping = aes(x = cost, y = reliability)) + theme_bw()
library(ggpubr)
ggarrange(gg1,gg2,gg3, nrow = 1)
```

### Step 12 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
lines = archs %>%
  # Convert metrics into z-scores
  mutate(cost = scale(cost),
         benefit = scale(benefit),
         reliability = scale(reliability)) %>%
  # For each architecture...
  group_by(id) %>%
  # Reframe the metrics into this shape
  reframe(
    type = c("cost", "benefit", "reliability"),
    value = c(cost, benefit, reliability),
    # Keep features 
    d1 = c(d1,d1,d1),
    d2 = c(d2,d2,d2),
    d3 = c(d3,d3,d3),
    d4 = c(d4,d4,d4),
    d5 = c(d5,d5,d5)
  )
```

### Step 13 – Create `gg`

Create the object `gg` so you can reuse it in later steps.


``` r
gg = ggplot() +
  theme_bw() +
  geom_line(
    data = lines, 
    # Make one line per id
    mapping = aes(x = type, y = value, group = id,
                  # Color the lines by feature
                  color = factor(d5) ))  
gg # view it
```

### Step 14 – Create `gg`

Add labels. Create the object `gg` so you can reuse it in later steps.


``` r
gg = gg + 
  labs(title = "Metrics for N = 32 architectures",
       color = "Decision 5",
       y = "Metric Value (Z-score)",
       x = "Type of Metric")
gg
```

### Step 15 – Create `gg`

Relabel axis values. Create the object `gg` so you can reuse it in later steps.


``` r
gg = gg + 
  scale_x_discrete(
    # Adjust labels
    labels = c("benefit" = "Benefit", "cost" = "Cost", "reliability" = "Reliability"),
    # Change the amount of white space
    expand = expansion(c(0.05, 0.05))) +
  # Adjust labels
  scale_color_discrete(labels = c("0" = "Not Adopted", "1" = "Adopted")) 
gg
```

### Step 16 – Create `gg`

Add a nice border.


``` r
gg = gg + 
  theme_classic() +
  theme(panel.border = element_rect(fill = NA, color = "black"))
```

### Step 17 – Run the Code Block

View it! Execute the block and pay attention to the output it produces.


``` r
gg
```

### Step 18 – Run the Code Block

5. Radar ########################################################## Don't recommend.


``` r
gg + coord_polar()
```

### Step 19 – Load Packages

6. K-Means ########################################################. Attach broom to make its functions available.


``` r
library(broom)
```

### Step 20 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
k = archs %>%
  mutate(cost = scale(cost),
         benefit = scale(benefit),
         reliability = scale(reliability)) %>%
  select(cost, benefit, reliability) %>%
  kmeans(x = ., centers = 3)
```

### Step 21 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
k
```

### Step 22 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
k$cluster
# Easy way to extract values in a data.frame
```

### Step 23 – Practice the Pipe

Cluster means. Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
k %>% broom::tidy()
```

### Step 24 – Practice the Pipe

Clustering Model statistics. Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
k %>% broom::glance()
```

### Step 25 – Practice the Pipe

Update with cluster id.


``` r
archs = archs %>%
  # Add the cluster id in
  mutate(cluster = factor(k$cluster))
```

### Step 26 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
archs
```

### Step 27 – Create `gg1`

Create the object `gg1` so you can reuse it in later steps.


``` r
gg1 = ggplot() +
  theme_bw() +
  geom_point(data = archs, 
             mapping = aes(x = benefit, y = cost, 
                           color = cluster),
             size = 5)
gg1
```

### Step 28 – Create `gg2`

Create the object `gg2` so you can reuse it in later steps.


``` r
gg2 = ggplot() +
  theme_bw() +
  geom_point(data = archs, 
             mapping = aes(x = reliability, y = cost, color = cluster),
             size = 5)
```

### Step 29 – Create `gg3`

Create the object `gg3` so you can reuse it in later steps.


``` r
gg3 = ggpubr::ggarrange(gg1,gg2, common.legend = TRUE)
```

### Step 30 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
gg3
```

### Step 31 – Practice the Pipe

Get pareto front. Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
archs = archs %>%
  mutate(pareto = pareto(x = cost, y = -benefit))
```

### Step 32 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
archs
```

### Step 33 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_line(data = archs %>% filter(pareto == TRUE),
            mapping = aes(x = benefit, y = cost)) +
  geom_point(data = archs, mapping = aes(x = benefit, y = cost, color = pareto),
             size = 3)
```

### Step 34 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
archs = archs %>%
  mutate(pareto = pareto(x = cost, y = benefit))
```

### Step 35 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_line(data = archs %>% filter(pareto == TRUE),
            mapping = aes(x = benefit, y = cost)) +
  geom_point(data = archs, mapping = aes(x = benefit, y = cost, color = pareto),
             size = 3)
```

### Step 36 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
archs = archs %>%
  mutate(pareto = pareto(x = cost, y = reliability))
```

### Step 37 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_line(data = archs %>% filter(pareto == TRUE),
            mapping = aes(x = reliability, y = cost)) +
  geom_point(data = archs, mapping = aes(x = reliability, y = cost, color = pareto),
             size = 3)
```

### Step 38 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
archr::get_arm
```

### Step 39 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
?archr::get_arm
```

### Step 40 – Practice the Pipe

Driving Features of being in the Pareto Front.


``` r
archs %>%
  select(d1, d2, pareto) %>%
  archr::get_arm(p = "pareto")
```

### Step 41 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
archs %>%
  select(d1, d2, front = pareto) %>%
  archr::get_arm(p = "front")
```

### Step 42 – Practice the Pipe

Multiple features. Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
archs %>%
  select(d1, d2, d3, pareto) %>%
  archr::get_arm(p = "pareto")
```

### Step 43 – Practice the Pipe

Driving Features of being in Cluster 1.


``` r
archs %>%
  #mutate(cluster1 = cluster == 1) %>%
  mutate(cluster1 = case_when(cluster == 1 ~ TRUE, cluster != 1 ~ FALSE)) %>%
  select(d1, d2, cluster1) %>%
  archr::get_arm(p = "cluster1")
```

### Step 44 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
archs %>%
  #mutate(cluster2 = cluster == 1) %>%
  mutate(cluster2 = case_when(cluster == 2 ~ TRUE, cluster != 2 ~ FALSE)) %>%
  select(d1, d2, d3, d4, cluster2) %>%
  archr::get_arm(p = "cluster2")
```

### Step 45 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
viz = archs %>%
  select(d1, d2, d3, d4, d5, pareto) %>%
  archr::get_arm(p = "pareto")
```

### Step 46 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_col(data = viz, mapping = aes(x = did, y = lift_f_p))
```

### Step 47 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
viz2 = archs %>%
  # Create your own composite feature
  mutate(f = case_when(d1 == 1 & d2 == 0 & d3 == 1 ~ 1,   TRUE ~ 0)) %>%
  select(f, d1, d2, d3, d4, d5, pareto) %>%
  archr::get_arm(p = "pareto")
```

### Step 48 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_col(data = viz2, mapping = aes(x = did, y = lift_f_p))
```

### Step 49 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_col(data = viz2, mapping = aes(x = reorder(did, -lift_f_p), y = lift_f_p))
```

### Step 50 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_col(data = viz2, mapping = aes(x = reorder(did, -lift_f_p), y = lift_f_p,
                                      fill = lift_f_p)) +
  scale_fill_gradient(low = "salmon", high = "skyblue")
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "35_evaluation_tradespace_intro.R"))` from the Console or press the Source button while the script is active.

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

**Learning Check 4.** How can you build confidence that a newly defined function behaves as intended?

<details>
<summary>Show answer</summary>

Call it with the sample input from the script, examine the output, then try a new input to see how the behaviour changes.

</details>

**Learning Check 5.** What experiment can you run on the `ggplot` layers to understand how aesthetics map to data?

<details>
<summary>Show answer</summary>

Switch one aesthetic (for example `color` to `fill` or tweak the geometry) and re-run the chunk to observe the difference.

</details>
