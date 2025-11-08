---
title: "[05] Stakeholder network analysis demo Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `05_stakeholder_network_analysis_demo.R` and unpacks the workshop on stakeholder network analysis demo. You will see how it advances the Stakeholder Analysis sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `05_stakeholder_network_analysis_demo.R` within the Stakeholder Analysis module.
- Connect the topic "Stakeholder network analysis demo" to systems architecting decisions.
- Install any required packages highlighted with `install.packages()`.
- Load packages with `library()` and verify they attach without warnings.
- Import data files with `readr` helpers and inspect the resulting objects.
- Chain tidyverse verbs with `%>%` to explore stakeholder or architecture tables.
- Iterate on visualisations built with `ggplot2`.

## Application

### Step 1 – Load Packages

Load packages. Attach dplyr to make its functions available.


``` r
library(dplyr)
library(readr)
library(ggplot2)
library(archr)
```

### Step 2 – Create `link`

Create the object `link` so you can reuse it in later steps.


``` r
link = get_sheet(docid = "1VL0jSoWRq0CZqhpEMXQUaY7LQuqu5XbWHdgQ38wbawo", gid = "0")
e = link %>% read_csv()
e$from
e$to
e$value
e %>% select(from)
```

### Step 3 – Create `m`

Create the object `m` so you can reuse it in later steps.


``` r
m = get_adjacency(edges = e)
```

### Step 4 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
m
# Get igraph object
g = get_graph(a = m)
```

### Step 5 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
g
```

### Step 6 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
plot(g)
```

### Step 7 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
e %>% head(3)
m
colnames(m)
```

### Step 8 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
e
g
scores = get_scores(g = g, root = "Project", var = "value")
```

### Step 9 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
scores
```

### Step 10 – Create `cycles`

Create the object `cycles` so you can reuse it in later steps.


``` r
cycles = get_cycles(g = g, root = "Project", cutoff = 100, 
                    vars = "value")
cycles
```

### Step 11 – Create `gg`

Gets me coordinates for each of my nodes and edges.


``` r
gg = get_coords(g = g, layout = "kk")
```

### Step 12 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
gg$nodes
gg$edges
```

### Step 13 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
gg$nodes
```

### Step 14 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
gg$edges
```

### Step 15 – Load Packages

Attach ggplot2 to make its functions available.


``` r
library(ggplot2)
```

### Step 16 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
gg$nodes
ggplot() +
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y) )
```

### Step 17 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y)) +
  geom_segment(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y))
```

### Step 18 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y),
             color = "pink", size = 10) +
  geom_segment(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    color = "blue", linewidth = 5)
```

### Step 19 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y)) +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y))
```

### Step 20 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y)) +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    arrow = grid::arrow(type = "closed") 
    )
```

### Step 21 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y)) +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    arrow = grid::arrow(type = "closed") 
  ) +
  labs(x = "Stuff", y = "Stuff", 
       title = "More Stuff", subtitle = "Hi!",
       caption = "Still here!")
```

### Step 22 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25,
    color = "grey", linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "blue", size = 3)
```

### Step 23 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25,
    color = "grey", linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "blue", fill = "gold", 
             size = 3, shape = 21)
```

### Step 24 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25,
    color = "grey", linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "white", fill = "black", 
             size = 3, shape = 21)  +
  geom_text(
    data = gg$nodes, 
    mapping = aes(x= x, y=y, label = name))
```

### Step 25 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25,
    color = "grey", linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "white", fill = "black", 
             size = 3, shape = 21)  +
  geom_text(
    data = gg$nodes, 
    mapping = aes(x= x, y=y, label = name), nudge_y = 0.15)
```

### Step 26 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25,
    color = "grey", linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "white", fill = "black", 
             size = 3, shape = 21)  +
  geom_text(
    data = gg$nodes, 
    mapping = aes(x= x, y=y, label = name), nudge_y = 0.15) +
  theme_void()
```

### Step 27 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, 
                  xend = to_x, yend = to_y,
                  color = value),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25, linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "white", fill = "black", 
             size = 3, shape = 21)  +
  geom_text(
    data = gg$nodes, 
    mapping = aes(x= x, y=y, label = name), nudge_y = 0.15) +
  theme_void()
```

### Step 28 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, 
                  xend = to_x, yend = to_y,
                  color = value),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25, linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "white", fill = "black", 
             size = 3, shape = 21)  +
  geom_text(
    data = gg$nodes, 
    mapping = aes(x= x, y=y, label = name), nudge_y = 0.15) +
  theme_void() +
  scale_color_gradient2(mid = "white", high = "red") +
  labs(color = "Stakeholder\nValue")
```

### Step 29 – Create `g2`

Create the object `g2` so you can reuse it in later steps.


``` r
g2 = ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, 
                  xend = to_x, yend = to_y,
                  color = value),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25, linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "white", fill = "black", 
             size = 3, shape = 21)  +
  geom_text(
    data = gg$nodes, 
    mapping = aes(x= x, y=y, label = name), nudge_y = 0.15)
```

### Step 30 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
g2
```

### Step 31 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
g2 +
  theme_void(base_size = 14) +
  # Add as many optional settings here as you like, like
  theme(
    # put legend on the bottom
    legend.position = "bottom",
    # horizontally justify the plot title at 50% (0 = left and 1 = right)
    plot.title = element_text(hjust = 0.5)) +
  # Add some labels
  labs(color = "Value Flow", title = "Stakeholder Network for Technology X") +
  # We can add a color gradient, ranging from 0 to the max
  scale_color_gradient2(mid = "white", high = "red", midpoint = 0)
```

### Step 32 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
colors()
```

### Step 33 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
"steelblue"
"firebrick"
```

### Step 34 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_point(data = gg$nodes, mapping = aes(x=x, y=y),
             size = 5, fill = "thistle1", shape = 21, color = "black")
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "05_stakeholder_network_analysis_demo.R"))` from the Console or press the Source button while the script is active.

</details>

**Learning Check 2.** Why does the script begin by installing or loading packages before exploring the exercises?

<details>
<summary>Show answer</summary>

Those commands make sure the required libraries are available so every subsequent code chunk runs without missing-function errors.

</details>

**Learning Check 3.** When you import data in this workshop, what should you inspect right after the read call?

<details>
<summary>Show answer</summary>

Check the tibble in the Environment pane (or print it) to confirm column names and types look correct.

</details>

**Learning Check 4.** How does the `%>%` pipeline help you reason about multi-step transformations in this script?

<details>
<summary>Show answer</summary>

It keeps each operation in sequence without creating temporary variables, so you can narrate the data story line by line.

</details>

**Learning Check 5.** What experiment can you run on the `ggplot` layers to understand how aesthetics map to data?

<details>
<summary>Show answer</summary>

Switch one aesthetic (for example `color` to `fill` or tweak the geometry) and re-run the chunk to observe the difference.

</details>
