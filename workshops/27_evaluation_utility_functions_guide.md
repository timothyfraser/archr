---
title: "[27] Utility function design Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `27_evaluation_utility_functions.R` and unpacks the workshop on utility function design. You will see how it advances the Evaluation sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `27_evaluation_utility_functions.R` within the Evaluation module.
- Connect the topic "Utility function design" to systems architecting decisions.
- Load packages with `library()` and verify they attach without warnings.

## Application

### Step 1 – Load Packages

Setup #################################################. Attach dplyr to make its functions available.


``` r
library(dplyr)
library(ggplot2)
```

### Step 2 – Create `p_fail`

Define probabilities. Create the object `p_fail` so you can reuse it in later steps.


``` r
p_fail = 0.05
p_works = 1 - p_fail
```

### Step 3 – Create `pay_min`

Define utility function for pay Choose what means min utility (0) for you.


``` r
pay_min = 0
# Choose what means max utility (1) for you
pay_max = 10000
```

### Step 4 – Create `pay_works`

Calculate utility of drone working (by rescaling).


``` r
pay_works = 10000
u_pay_works = (pay_works - pay_min) / (pay_max - pay_min)
```

### Step 5 – Create `pay_fail`

Calculate utility if drone fails.


``` r
pay_fail = -5000
u_pay_fail = (pay_fail - pay_min) / (pay_max - pay_min)
```

### Step 6 – Create `u_pay`

Calculate expected utility that you would earn Expected utility here is ~0.93.


``` r
u_pay = p_works * u_pay_works + p_fail * u_pay_fail
u_pay # View
```

### Step 7 – Create `e_min`

Define utility function for emissions.


``` r
e_min = 0
e_max = 20
```

### Step 8 – Create `e_works`

Create the object `e_works` so you can reuse it in later steps.


``` r
e_works = 10
```

### Step 9 – Create `u_e_works`

Create the object `u_e_works` so you can reuse it in later steps.


``` r
u_e_works = (e_works - e_min) / (e_max - e_min)
```

### Step 10 – Create `e_fail`

Create the object `e_fail` so you can reuse it in later steps.


``` r
e_fail = 3
u_e_fail = (e_fail - e_min) / (e_max - e_min)
```

### Step 11 – Create `u_e`

So the expected utility here is ~0.52 on a scale from 0 to 20. Calculate expected utility for emissions.


``` r
u_e = p_works * u_e_works + p_fail * u_e_fail
u_e # View
1 - u_e
```

### Step 12 – Create `w_e`

Define weights. Create the object `w_e` so you can reuse it in later steps.


``` r
w_e = 0.30
w_pay = 0.70
```

### Step 13 – Create `t`

Combine utilities. Create the object `t` so you can reuse it in later steps.


``` r
t = tibble(
  type = c("emissions", "pay"),           # Types of utilities
  # remember to make high emissions BAD
  # remember direction matters!
  u = c(1 - u_e, u_pay),                      # Utility values
  w = c(w_e, w_pay)                       # Weights
)
```

### Step 14 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
t
```

### Step 15 – Create `combined_additive`

Calculate combined utility additively.


``` r
combined_additive = sum(t$u * t$w)
combined_additive
```

### Step 16 – Create `combined_multiplicative`

Calculate combined utility multiplicatively.


``` r
combined_multiplicative = prod(t$u * t$w)
combined_multiplicative
```

### Step 17 – Clear Objects

Remove objects from the environment to prevent name clashes.


``` r
rm(list = ls())
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "27_evaluation_utility_functions.R"))` from the Console or press the Source button while the script is active.

</details>

**Learning Check 2.** Why does the script begin by installing or loading packages before exploring the exercises?

<details>
<summary>Show answer</summary>

Those commands make sure the required libraries are available so every subsequent code chunk runs without missing-function errors.

</details>

**Learning Check 3.** In your own words, what key idea does the topic "Utility function design" reinforce?

<details>
<summary>Show answer</summary>

It highlights how utility function design supports the overall systems architecting process in this course.

</details>
