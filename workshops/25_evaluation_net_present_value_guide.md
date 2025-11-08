---
title: "[25] Net present value calculations Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `25_evaluation_net_present_value.R` and unpacks the workshop on net present value calculations. You will see how it advances the Evaluation sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `25_evaluation_net_present_value.R` within the Evaluation module.
- Connect the topic "Net present value calculations" to systems architecting decisions.
- Load packages with `library()` and verify they attach without warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or architecture tables.
- Iterate on visualisations built with `ggplot2`.

## Application

### Step 1 – Load Packages

Setup #####################################################. Attach dplyr to make its functions available.


``` r
library(dplyr)
library(ggplot2)
```

### Step 2 – Create `t`

Create a data frame,.


``` r
t = tibble(
  time = 1:5,      # Time periods
  # supposing a fixed annual cost and return...
  benefit = 30000, # Annual benefits
  cost = 5000,     # Annual costs
  # Where the funds lose 5% in value each year...
  discount = 0.05  # Discount rate
)
```

### Step 3 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
t
```

### Step 4 – Practice the Pipe

Calculate net revenue. Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
t = t %>% 
  mutate(netrev = benefit - cost)
t
```

### Step 5 – Practice the Pipe

Calculate net present value for each time.


``` r
t = t %>% 
  mutate(npv = netrev / (1 + discount)^time)
```

### Step 6 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
t
```

### Step 7 – Run the Code Block

View the results. Execute the block and pay attention to the output it produces.


``` r
t
```

### Step 8 – Start a ggplot

Plotting NPV over time.


``` r
ggplot(t, aes(x = time, y = npv)) +       
  geom_point() +
  labs(x = "Time", y = "Net Present Value") +
  ggtitle("Net Present Value Over Time")
```

### Step 9 – Clear Objects

Cleanup. Remove objects from the environment to prevent name clashes.


``` r
rm(list= ls())
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "25_evaluation_net_present_value.R"))` from the Console or press the Source button while the script is active.

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
