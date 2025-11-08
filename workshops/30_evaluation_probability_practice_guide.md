This tutorial complements `30_evaluation_probability_practice.R` and
unpacks the workshop on probability practice exercises. You will see how
it advances the Evaluation sequence while building confidence with base
R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working
  directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines
  interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from
  earlier workshops.

## Skills

- Navigate the script `30_evaluation_probability_practice.R` within the
  Evaluation module.
- Connect the topic “Probability practice exercises” to systems
  architecting decisions.
- Load packages with `library()` and verify they attach without
  warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or
  architecture tables.
- Iterate on visualisations built with `ggplot2`.

## Process Overview

``` mermaid
flowchart LR
    A[Load Packages] --> B[Practice the Pipe]
    B[Practice the Pipe] --> C[Run the Code Block]
    C[Run the Code Block] --> D[Practice the Pipe (Step 27)]
```

## Application

### Step 1 – Load Packages

Load required libraries. Attach dplyr to make its functions available.

``` r
library(dplyr)
library(readr)
library(ggplot2)
```

### Step 2 – Create `cost`

Import data! Cost distribution stats (\$1000s) by subsystem.

``` r
cost = tribble(
  ~type, ~system, ~dist,    ~mu, ~sigma,
  "cost", "app",  "normal", 40,  2,
  "cost", "mak",  "exponential", 30,  NA,
  "cost", "dec",  "normal", 60,  4,
  "cost", "qc",  "poisson", 20,  NA,
  "cost", "del",  "normal", 80,  5
)
```

### Step 3 – Create `time`

Time distribution stats (hours) by subsystem.

``` r
time <- tribble(
  ~type, ~system, ~dist,        ~mu, ~sigma,
  "time", "app",  "normal",      500,   25,
  "time", "mak",  "exponential", 1500,  NA,
  "time", "dec",  "normal",      400,   25,
  "time", "qc",   "poisson",     1200,  NA,
  "time", "del",  "normal",      1300,  30
)
```

### Step 4 – Create `bench`

pnorm, pexp, ppois, etc. - cumulative distribution rnorm, rexp, rpois,
etc. - simulates times dnorm, dexp, dpois, etc - value of pdf Set
parameters.

``` r
bench <- 520 # suppose 520 hours is our firm deadline from funders
```

### Step 5 – Clear Objects

Eg. What % of cases would should we expect take \> 520 hours? Assume a
normal distribution.

``` r
1 - pnorm(bench, mean = 500, sd = 25)
```

### Step 6 – Clear Objects

100 random draws if normal…….

``` r
rnorm(n = 100, mean = 500, sd = 25)
```

### Step 7 – Create `o`

Create the object `o` so you can reuse it in later steps.

``` r
o <- tibble(
  app = rnorm(n = 1000, mean = 500, sd = 25),
  mak = rexp(n = 1000, rate = 1 / 1500),
  dec = rnorm(n = 1000, mean = 400, sd = 25),
  qc = rpois(n = 1000, lambda = 1200),
  del = rnorm(n = 1000, mean = 1300, sd = 30)
)
```

### Step 8 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
o %>%
  mutate(id = 1:n()) %>%
  group_by(id) %>%
  mutate(max = max(c(app, mak, dec, qc, del)))
```

### Step 9 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
o %>%
  rowwise() %>%
  mutate(max = max(c(app, mak, dec, qc, del)))
```

### Step 10 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
o %>%
  rowwise() %>%
  mutate(sum = sum(c(app, mak, dec, qc, del)))
```

### Step 11 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
o = o %>%
  rowwise() %>%
  mutate(max = max(c(app, mak, dec, qc, del))) %>%
  mutate(sum = sum(c(app, mak, dec, qc, del)))
```

### Step 12 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
o
```

### Step 13 – Practice the Pipe

Get max. Use the `%>%` operator to pass each result to the next
tidyverse verb.

``` r
o = o %>% 
  rowwise() %>%
  mutate(max = max(c(app, mak, dec, qc, del)))
```

### Step 14 – Practice the Pipe

Get total. Use the `%>%` operator to pass each result to the next
tidyverse verb.

``` r
o = o %>% 
  rowwise() %>%
  mutate(sum = sum(c(app, mak, dec, qc, del)))
```

### Step 15 – Start a ggplot

2.3 Compute Quantities of Interest View the histogram / approximate the
PDF!

``` r
ggplot(o, aes(x = sum)) +
  geom_histogram(binwidth = 100, fill = "green", color = "black") +
  labs(x = "System Completion Time (hours)", y = "Frequency")
```

### Step 16 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.

``` r
ggplot(o, aes(x = max)) +
  geom_histogram(binwidth = 100, fill = "purple", color = "black") +
  labs(x = "Max Subsystem Completion Time (hours)", y = "Frequency")
```

### Step 17 – Run the Code Block

Compute the median, mean, and standard deviation of this distribution!
“If simultaneously…

``` r
median(o$max)
mean(o$max)
sd(o$max)
```

### Step 18 – Run the Code Block

“If sequentially… Execute the block and pay attention to the output it
produces.

``` r
median(o$sum)
mean(o$sum)
sd(o$sum)
```

### Step 19 – Run the Code Block

TASK 2: SIMULATE OVERALL SYSTEM Try your best to repeat this process,
but this time, simulate the **TOTAL COST** of the system overall, using
our table t above!

``` r
cost
```

### Step 20 – Create `k`

Create the object `k` so you can reuse it in later steps.

``` r
k = tibble(
  app = rnorm(n = 1000, mean = 40, sd = 2),
  mak = rexp(n = 1000, rate = 1 / 30),
  dec = rnorm(n = 1000, mean = 60, sd = 4),
  qc = rpois(n = 1000, lambda = 20),
  del = rnorm(n = 1000, mean = 80, sd = 5)
)
```

### Step 21 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
k %>% 
  rowwise() %>% 
  mutate(sum = sum(c(app:del)))
```

### Step 22 – Practice the Pipe

If you need to do it without using specific values.

``` r
cost %>%
  group_by(system) %>%
  reframe(
    id = 1:n(),
    sim = case_when(
    dist == "normal" ~ rnorm(n = 1000, mean = mu, sd = sigma),
    dist == "exponential" ~ rexp(n = 1000, rate = 1 / mu),
    dist == "poisson" ~ rpois(n = 1000, lambda = mu)
  ))
```

### Step 23 – Create `p`

EXAMPLE 3: SIMULATING DISCRETE DISTRIBUTIONS Let’s say in the Donut
Cannon Subsystem, every cannon has the same reliability (p = 95%).

``` r
p <- 0.95
# If we have n donuts we want to launch...
n <- 10
# We can calculate using a binomial distribution PDF quantities of interest
```

### Step 24 – Run the Code Block

3.1 What’s the probability that 9 out of 10 land successfully?

``` r
dbinom(9, size = n, prob = p)
```

### Step 25 – Run the Code Block

3.2 What’s the probability that at least 9 land successfully?

``` r
pbinom(9, size = n, prob = p)
```

### Step 26 – Run the Code Block

more than 9. Execute the block and pay attention to the output it
produces.

``` r
1 - pbinom(9, size = n, prob = p)
```

### Step 27 – Practice the Pipe

3.3 simulate 100 draws from a binomial distribution to determine the
expected number of donuts.

``` r
rbinom(100, n, p) %>% mean()
rbinom(100, n, p) %>% sd()
```

## Learning Checks

**Learning Check 1.** Which libraries does Step 1 attach, and why do you
run that chunk before others?

<details>
<summary>
Show answer
</summary>

It attaches dplyr, readr and ggplot2, ensuring their functions are
available before you execute the downstream code.

</details>

**Learning Check 2.** After Step 2, what does `cost` capture?

<details>
<summary>
Show answer
</summary>

It creates `cost` that builds a tibble of scenario data. Import data!
Cost distribution stats (\$1000s) by subsystem.

</details>

**Learning Check 3.** After Step 3, what does `time` capture?

<details>
<summary>
Show answer
</summary>

It creates `time` that builds a tibble of scenario data. Time
distribution stats (hours) by subsystem.

</details>

**Learning Check 4.** After Step 4, what does `bench` capture?

<details>
<summary>
Show answer
</summary>

It creates `bench`. pnorm, pexp, ppois, etc. - cumulative distribution
rnorm, rexp, rpois, etc. - simulates times dnorm, dexp, dpois, etc -
value of pdf Set parameters.

</details>
