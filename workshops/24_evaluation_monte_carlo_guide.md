---
title: "[24] Monte Carlo evaluation Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `24_evaluation_monte_carlo.R` and unpacks the workshop on monte carlo evaluation. You will see how it advances the Evaluation sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `24_evaluation_monte_carlo.R` within the Evaluation module.
- Connect the topic "Monte Carlo evaluation" to systems architecting decisions.
- Load packages with `library()` and verify they attach without warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or architecture tables.
- Define custom functions to package repeatable logic.

## Application

### Step 1 – Load Packages

SETUP ########################################################## Load required libraries.


``` r
library(dplyr)
library(ggplot2)
```

### Step 2 – Create `r`

Create the object `r` so you can reuse it in later steps.


``` r
r = tibble(
  mu = 500 # miles
)
# mean time to failure! = mean miles travelled
# failure rate = 1 / mean time to failure
# use it in an exponential distribution
# take 1000 random samples from that distribution
```

### Step 3 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
r2 = r %>%
  reframe(sim = rexp(n = 1000, rate = 1 / mu))
```

### Step 4 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
r3 = r2 %>%
  summarize(
    p50 = quantile(sim, probs = 0.50),
    p75 = quantile(sim, probs = 0.75),
    sd = sd(sim),
    mean = mean(sim),
    max = max(sim),
    min = min(sim),
    p99 = quantile(sim, prob = 0.99),
    p01 = quantile(sim, prob = 0.01)
  )
```

### Step 5 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
r3
```

### Step 6 – Load Packages

Attach archr to make its functions available.


``` r
library(archr)
library(dplyr)
```

### Step 7 – Create `a`

Say we've got 3 binary decisions d1 = EIRP of transmitter (option 1 vs. option 0) d2 = G/T of receiver (option 1 vs. option 0) d3 = Slant Range (option 1 vs. option 0).


``` r
a = archr::enumerate_binary(n = 3)
```

### Step 8 – Define `get_performance()`

Create the helper function `get_performance()` so you can reuse it throughout the workshop.


``` r
get_performance = function(d1,d2,d3, n = 1000, benchmark = 0){
```

### Step 9 – Clear Objects

d1 = EIRP of transmitter (option 1 vs. option 0).


``` r
  sim1 = case_when(d1 == 1 ~ rnorm(n = n, mean = 30, sd = 5),
                 d1 == 0 ~ rnorm(n = n, mean = 0, sd = 0) )
  # d2 = G/T of receiver  (option 1 vs. option 0)
  sim2 = case_when(d2 == 1 ~ rnorm(n = n, mean = 0, sd = 2),
                 d2 == 0 ~ rnorm(n = n, mean = 0, sd = 0))
  # d3 = Slant Range (option 1 vs. option 0)
  sim3 = case_when(d3 == 1 ~ rnorm(n = n, mean = 4, sd = 2),
                   d3 == 0 ~ rnorm(n = n, mean = 0, sd = 0))
```

### Step 10 – Create `sim`

Get total simulated metrics.


``` r
  sim = sim1 + sim2 + sim3
```

### Step 11 – Create `metric`

Calculate percentage that are less than benchmark!


``` r
  metric = sum(sim < benchmark) / length(sim)
```

### Step 12 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
  return(metric)
}
```

### Step 13 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
get_performance(d1 = 1, d2 = 2, d3 = 3, n = 1000, benchmark = 0)
```

### Step 14 – Load Packages

Attach archr to make its functions available.


``` r
library(archr)
library(dplyr)
```

### Step 15 – Create `a`

Say we've got 3 binary decisions d1 = EIRP of transmitter (option 1 vs. option 0) d2 = G/T of receiver (option 1 vs. option 0) d3 = Atmospheric Losses (option 1 vs. option 0).


``` r
a = archr::enumerate_binary(n = 3)
```

### Step 16 – Define `get_performance()`

Create the helper function `get_performance()` so you can reuse it throughout the workshop.


``` r
get_performance = function(d1, d2, d3, n, benchmark){
  # Testing values
  # d1 = 1; d2 = 1; d3 = 1; n = 100; benchmark = 30
```

### Step 17 – Clear Objects

transmitter m1 = case_when(d1 == 1 ~ 30, d1 == 0 ~ 0).


``` r
  sim1 = case_when(d1 == 1 ~ rnorm(n = n, mean = 30, sd = 5), 
                   d1 == 0 ~ rnorm(n = n, mean = 0, sd = 0) )
  # receiver
  sim2 = case_when(d2 == 1 ~ rnorm(n = n, mean = 0, sd = 2),
                   d2 == 0 ~ rnorm(n = n, mean = 0, sd = 0) )
  # climate that the tech is deployed in
  sim3 = case_when(d3 == 1 ~ rnorm(n = n, mean = 4, sd = 2),
                   d3 == 0 ~ rnorm(n = n, mean = 0, sd = 0))
  # combine
  sims = sim1 + sim2 + sim3
```

### Step 18 – Create `metric`

Option 4. Create the object `metric` so you can reuse it in later steps.


``` r
  metric = sum(sims < benchmark) / n
```

### Step 19 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
  return(metric)
}
```

### Step 20 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
get_performance(d1 = 1, d2 = 1, d3 = 1, n = 100, benchmark = 2)
get_performance(d1 = 0, d2 = 0, d3 = 0, n = 100, benchmark = 2)
```

### Step 21 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
get_performance(d1 = 1, d2 = 1, d3 = 1, n = 100, benchmark = 30)
```

### Step 22 – Practice the Pipe

Let's calculate performance here 'rowwise'.


``` r
a %>% 
  rowwise() %>%
  mutate(m1 = get_performance(d1 = d1, d2 = d2, d3 = d3, n = 1000, benchmark = 30)) %>%
  ungroup()
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "24_evaluation_monte_carlo.R"))` from the Console or press the Source button while the script is active.

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
