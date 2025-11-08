---
title: "[33] Metric design exercises Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `33_evaluation_metric_design.R` and unpacks the workshop on metric design exercises. You will see how it advances the Evaluation sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `33_evaluation_metric_design.R` within the Evaluation module.
- Connect the topic "Metric design exercises" to systems architecting decisions.
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

Exponential Distribution: a common form for lifespan distributions, characterized by one parameter, lambda. Note: MATLAB wants instead the mean time to failure (MTTF) for its exponential functions, but if you have lambda, you can get the MTTF. Eg. what's the cumulative probability of a product failing at or before 100 hours, given an Exp. Distr. with MTTF mu?


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

### Step 15 – Create `r_a`

Suppose at time t = 100 hours...


``` r
r_a = 0.88
r_b = 0.99
r_c = 0.95
# 82% chance that the whole system stays reliable for 100 hours
r_a * r_b * r_c
```

### Step 16 – Create `t`

My coffee shop's system has 3 serially-connected components: A = coffee maker (MTTF = 500 hours) B = bean grinder (MTTF = 5000 hours) C = dishwasher (MTTF = 1000 hours) What's the probability the system survives 100 hours?


``` r
t <- 100
```

### Step 17 – Create `r_a`

Reliability of A (coffee maker) by time t R_a(t) = 1 - F_a(t).


``` r
r_a <- 1 - pexp(t, rate = 1/500)
```

### Step 18 – Create `r_b`

Reliability of B (bean grinder) by time t.


``` r
r_b <- 1 - pexp(t, rate = 1/5000)
```

### Step 19 – Create `r_c`

Reliability of C (dishwasher) by time t.


``` r
r_c <- 1 - pexp(t, rate = 1/1000)
```

### Step 20 – Create `r_s`

Reliability of System by time t = 100.


``` r
r_s <- r_a * r_b * r_c
r_s
```

### Step 21 – Create `r_a1`

Suppose we buy 3 coffee makers - as long as one works, we can maintain the system.


``` r
r_a1 <- r_a
r_a2 <- r_a
r_a3 <- r_a
```

### Step 22 – Create `r_a_parallel`

Let's find chance at least 1 remains functional.


``` r
r_a_parallel <- 1 - prod(1 - c(r_a1, r_a2, r_a3))
r_a_parallel
```

### Step 23 – Run the Code Block

If series. Execute the block and pay attention to the output it produces.


``` r
r_a1 * r_a2 * r_a3
```

### Step 24 – Create `overall_reliability`

We could compute the reliability of the overall system at time t like so!


``` r
overall_reliability <- r_a_parallel * r_b * r_c
overall_reliability
```

### Step 25 – Create `s`

Learning Curve Formula: Y = aX^b suppose a 80% learning curve.


``` r
s <- 0.80
```

### Step 26 – Create `gains`

means each time quantity doubles, you gain 20% in efficiency.


``` r
gains <- 1 - s
```

### Step 27 – Create `b`

Calculate the slope of the learning curve.


``` r
b <- log(s) / log(2.00)
```

### Step 28 – Create `a`

If it takes 30 hours to make tool A at the beginning...


``` r
a <- 30
```

### Step 29 – Create `x`

What happens if we make tool A many times?


``` r
x <- c(1, 2, 5, 10, 20, 50, 100, 150, 200)
```

### Step 30 – Create `y`

Our slope suggests that the average time to make Tool A becomes...


``` r
y <- a * x^b
y
```

### Step 31 – Create `data`

Let's plot that learning curve!


``` r
data = tibble(x, y)
```

### Step 32 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_line(data = data, mapping = aes(x = x, y = y)) +
  labs(x = "Number of times made (X)", y = "Average time (Y) to make Tool A")
```

### Step 33 – Create `data2`

Create the object `data2` so you can reuse it in later steps.


``` r
data2 = bind_rows(
  tibble(
    a = 30,
    x = c(1, 2, 5, 10, 20, 50, 100, 150, 200),
    s = 0.80,
    y = a * x^ (log(s) / log(2.00))
  ),
  tibble(
    a = 30,
    x = c(1, 2, 5, 10, 20, 50, 100, 150, 200),
    s = 0.90,
    y = a * x^ (log(s) / log(2.00))
  )
)
```

### Step 34 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_line(data = data2, 
            mapping = aes(
              x = x, y = y,
              group = s, color = s)) +
  labs(x = "Number of times made (X)",
       y = "Average time (Y) to make Tool A")
```

### Step 35 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
data3 = tibble(s = c(0.80, 0.85, 0.90, 0.92, 0.97, 0.99)) %>%
  # For each s...
  group_by(s) %>%
  # Make this vector!
  reframe(
    a = 30,
    x = c(1, 2, 5, 10, 20, 50, 100, 150, 200),
    y = a * x^ (log(s) / log(2.00))    
  )
```

### Step 36 – Run the Code Block

View it! Execute the block and pay attention to the output it produces.


``` r
data3
```

### Step 37 – Start a ggplot

Visualize it! Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  # Let's make color = factor(s)
  # That splits the colors into a discrete color scale
  geom_line(data = data3, 
            mapping = aes(
              x = x, y = y,
              group = s, color = factor(s) )) +
  labs(x = "Number of times made (X)",
       y = "Average time (Y) to make Tool A")
```

### Step 38 – Clear Objects

Z. Done! Clear environment.


``` r
rm(list = ls())
```

### Step 39 – Create `cpu`

Create the object `cpu` so you can reuse it in later steps.


``` r
cpu = 0.99
keys = 0.98
keys2 = 0.999999999999
display = 0.96
mouse = 0.95
# Reliability of your system is just 88%
cpu * keys * display * mouse
```

### Step 40 – Run the Code Block

Two keys = 86%.


``` r
cpu * keys^2 * display * mouse
```

### Step 41 – Run the Code Block

All keys = 40%.


``` r
cpu * keys^40 * display * mouse
```

### Step 42 – Run the Code Block

All keys = 40%.


``` r
cpu * keys2^40 * display * mouse
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "33_evaluation_metric_design.R"))` from the Console or press the Source button while the script is active.

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
