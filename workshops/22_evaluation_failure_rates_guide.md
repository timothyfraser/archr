---
title: "[22] Failure rates primer Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `22_evaluation_failure_rates.R` and unpacks the workshop on failure rates primer. You will see how it advances the Evaluation sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `22_evaluation_failure_rates.R` within the Evaluation module.
- Connect the topic "Failure rates primer" to systems architecting decisions.
- Load packages with `library()` and verify they attach without warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or architecture tables.
- Iterate on visualisations built with `ggplot2`.

## Application

### Step 1 – Load Packages

Load necessary libraries. Attach dplyr to make its functions available.


``` r
library(dplyr)
library(ggplot2)
```

### Step 2 – Create `products`

Lifespan Distribution: distribution (PDF) for a vector of product lifespans. Reflects the probability that a product failed after X hours or years Eg. Here's a vector of 10 items' lifespans, in hours.


``` r
products = c(24, 273, 41, 282, 14, 210, 325, 276, 96, 149)
```

### Step 3 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
products %>% hist()
```

### Step 4 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
products %>% density() %>% plot()
```

### Step 5 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_density(data = tibble(products), mapping = aes(x = products))
```

### Step 6 – Create `mu`

Mean Time to Failure: the mean of a lifespan distribution. Describes the average hours to failure per unit. Eg. let's get the MTTF for our products' life distribution.


``` r
mu = mean(products)
```

### Step 7 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
mu
```

### Step 8 – Create `lambda`

Failure Rate (Lambda): inverse of mean time to failure. Describes the average number of times a product fails per time-step (eg. per hour). Eg. let's get the Failure Rate for our products' life distribution.


``` r
lambda = 1 / mean(products)
lambda
```

### Step 9 – Run the Code Block

Exponential Distribution: a common form for lifespan distributions, characterized by one parameter, lambda. If you have lambda, you can get the MTTF. Eg. what's the cumulative probability of a product failing at or before 100 hours, given an Exp. Distr. with MTTF mu?


``` r
pexp(100, rate = 1/mu)
```

### Step 10 – Run the Code Block

Probability of Failure F(t): cumulative probability of failure by time t. expcdf() will give you F(t) in an exponential distribution. Probability of Reliability/Survival R(t): cumulative probability it DOESN'T fail by time t. For example, R(t = 100) = 1 - expcdf(100, mu). Eg. what's the cumulative probability of product survives for 100 hours, given an Exp. Distr. with MTTF mu?


``` r
1 - pexp(100, rate = 1/mu)
```

### Step 11 – Practice the Pipe

Take a random sample!


``` r
rexp(n = 1000, rate = 1 / mu) %>% hist()
```

### Step 12 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
rexp(n = 1000, rate = 1 / mu) %>% density() %>% plot()
```

### Step 13 – Create `data`

Create the object `data` so you can reuse it in later steps.


``` r
data = tibble(t = rexp(n = 1000, rate = 1 / mu))
ggplot() +
  geom_density(data = data, mapping = aes(x = t))
```

### Step 14 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_density(data = data, mapping = aes(x = t))
```

### Step 15 – Clear Objects

Cleanup! Remove objects from the environment to prevent name clashes.


``` r
rm(list = ls())
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "22_evaluation_failure_rates.R"))` from the Console or press the Source button while the script is active.

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
