This tutorial complements `34_evaluation_storytelling.R` and unpacks the
workshop on evaluation storytelling lab. You will see how it advances
the Evaluation sequence while building confidence with base R and
tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working
  directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines
  interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from
  earlier workshops.

## Skills

- Navigate the script `34_evaluation_storytelling.R` within the
  Evaluation module.
- Connect the topic “Evaluation storytelling lab” to systems
  architecting decisions.
- Load packages with `library()` and verify they attach without
  warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or
  architecture tables.
- Define custom functions to package repeatable logic.
- Iterate on visualisations built with `ggplot2`.

## Process Overview

``` mermaid
flowchart LR
    A[Load Packages] --> B[Start a ggplot]
    B[Start a ggplot] --> C[Practice the Pipe]
    C[Practice the Pipe] --> D[Practice the Pipe (Step 55)]
```

## Application

### Step 1 – Load Packages

Load required libraries. Attach dplyr to make its functions available.

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

Calculate net revenue. Use the `%>%` operator to pass each result to the
next tidyverse verb.

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

View the results. Execute the block and pay attention to the output it
produces.

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

### Step 9 – Create `data`

smartboards. Create the object `data` so you can reuse it in later
steps.

``` r
data = tribble(
  ~unit, ~cost,
   1,     2000,
   10,    16000,
   50,    90000,
   100,   140000,
)
```

### Step 10 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.

``` r
ggplot() +
  geom_point(data = data, mapping = aes(x = unit, y = cost))
```

### Step 11 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
m = data %>% lm(formula = cost ~ unit)
# Cost = $4,920 + $1,418 * unit
```

### Step 12 – Define `get_cost()`

Create the helper function `get_cost()` so you can reuse it throughout
the workshop.

``` r
get_cost = function(unit){ 4920 + 1418 * unit }
```

### Step 13 – Create `data2`

Create the object `data2` so you can reuse it in later steps.

``` r
data2 = tibble(
  unit = 150,
  # pred = get_cost(unit), # this is equivalent
  pred = predict(m, newdata = tibble(unit))
)
```

### Step 14 – Create `data3`

Create the object `data3` so you can reuse it in later steps.

``` r
data3 = tibble(
  unit = 1:150,
  pred = predict(m, newdata = tibble(unit))
)
```

### Step 15 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
data3
```

### Step 16 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.

``` r
ggplot() +
  geom_point(data = data, mapping = aes(x = unit, y = cost)) +
  geom_line(data = data3, mapping = aes(x = unit, y = pred)) +
  geom_point(data = data2, mapping = aes(x = unit, y = pred), color = "red")
```

### Step 17 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
m2 = data %>% lm(formula = log(cost) ~ unit)
m2
```

### Step 18 – Create `data4`

ln(cost) = 8.63484 ln\$ + 0.03726 ln\$ \* unit.

``` r
data4 = tibble(
  unit = 1:150,
  pred = predict(m2, newdata = tibble(unit))
) %>%
  mutate(pred = exp(pred))
```

### Step 19 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.

``` r
ggplot() +
  geom_point(data = data, mapping = aes(x = unit, y = cost)) +
  geom_line(data = data3, mapping = aes(x = unit, y = pred), color = "blue") +
  geom_line(data = data4, mapping = aes(x = unit, y = pred), color = "red") +
  geom_point(data = data2, mapping = aes(x = unit, y = pred), color = "blue")
```

### Step 20 – Create `p_fail`

Define probabilities. Create the object `p_fail` so you can reuse it in
later steps.

``` r
p_fail = 0.05
p_works = 1 - p_fail
```

### Step 21 – Create `pay_min`

Define utility function for pay Choose what means min utility (0) for
you.

``` r
pay_min = 0
# Choose what means max utility (1) for you
pay_max = 10000
```

### Step 22 – Create `pay_works`

Calculate utility of drone working (by rescaling).

``` r
pay_works = 10000
u_pay_works = (pay_works - pay_min) / (pay_max - pay_min)
```

### Step 23 – Create `pay_fail`

Calculate utility if drone fails.

``` r
pay_fail = -5000
u_pay_fail = (pay_fail - pay_min) / (pay_max - pay_min)
```

### Step 24 – Create `u_pay`

Calculate expected utility that you would earn Expected utility here is
~0.93.

``` r
u_pay = p_works * u_pay_works + p_fail * u_pay_fail
u_pay # View
```

### Step 25 – Create `e_min`

Define utility function for emissions.

``` r
e_min = 0
e_max = 20
```

### Step 26 – Create `e_works`

Create the object `e_works` so you can reuse it in later steps.

``` r
e_works = 10
```

### Step 27 – Create `u_e_works`

Create the object `u_e_works` so you can reuse it in later steps.

``` r
u_e_works = (e_works - e_min) / (e_max - e_min)
```

### Step 28 – Create `e_fail`

Create the object `e_fail` so you can reuse it in later steps.

``` r
e_fail = 3
u_e_fail = (e_fail - e_min) / (e_max - e_min)
```

### Step 29 – Create `u_e`

So the expected utility here is ~0.52 on a scale from 0 to 20. Calculate
expected utility for emissions.

``` r
u_e = p_works * u_e_works + p_fail * u_e_fail
u_e # View
1 - u_e
```

### Step 30 – Create `w_e`

Define weights. Create the object `w_e` so you can reuse it in later
steps.

``` r
w_e = 0.30
w_pay = 0.70
```

### Step 31 – Create `t`

Combine utilities. Create the object `t` so you can reuse it in later
steps.

``` r
t = tibble(
  type = c("emissions", "pay"),           # Types of utilities
  # remember to make high emissions BAD
  # remember direction matters!
  u = c(1 - u_e, u_pay),                      # Utility values
  w = c(w_e, w_pay)                       # Weights
)
```

### Step 32 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
t
```

### Step 33 – Create `combined_additive`

Calculate combined utility additively.

``` r
combined_additive = sum(t$u * t$w)
combined_additive
```

### Step 34 – Create `combined_multiplicative`

Calculate combined utility multiplicatively.

``` r
combined_multiplicative = prod(t$u * t$w)
combined_multiplicative
```

### Step 35 – Create `r`

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

### Step 36 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
r2 = r %>%
  reframe(sim = rexp(n = 1000, rate = 1 / mu))
```

### Step 37 – Practice the Pipe

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

### Step 38 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
r3
```

### Step 39 – Load Packages

Attach archr to make its functions available.

``` r
library(archr)
library(dplyr)
```

### Step 40 – Create `a`

Say we’ve got 3 binary decisions d1 = EIRP of transmitter (option 1
vs. option 0) d2 = G/T of receiver (option 1 vs. option 0) d3 = Slant
Range (option 1 vs. option 0).

``` r
a = archr::enumerate_binary(n = 3)
```

### Step 41 – Define `get_performance()`

Create the helper function `get_performance()` so you can reuse it
throughout the workshop.

``` r
get_performance = function(d1,d2,d3, n = 1000, benchmark = 0){
```

### Step 42 – Clear Objects

d1 = EIRP of transmitter (option 1 vs. option 0).

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

### Step 43 – Create `sim`

Get total simulated metrics.

``` r
  sim = sim1 + sim2 + sim3
```

### Step 44 – Create `metric`

Calculate percentage that are less than benchmark!

``` r
  metric = sum(sim < benchmark) / length(sim)
```

### Step 45 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
  return(metric)
}
```

### Step 46 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
get_performance(d1 = 1, d2 = 2, d3 = 3, n = 1000, benchmark = 0)
```

### Step 47 – Load Packages

Attach archr to make its functions available.

``` r
library(archr)
library(dplyr)
```

### Step 48 – Create `a`

Say we’ve got 3 binary decisions d1 = EIRP of transmitter (option 1
vs. option 0) d2 = G/T of receiver (option 1 vs. option 0) d3 =
Atmospheric Losses (option 1 vs. option 0).

``` r
a = archr::enumerate_binary(n = 3)
```

### Step 49 – Define `get_performance()`

Create the helper function `get_performance()` so you can reuse it
throughout the workshop.

``` r
get_performance = function(d1, d2, d3, n, benchmark){
  # Testing values
  # d1 = 1; d2 = 1; d3 = 1; n = 100; benchmark = 30
```

### Step 50 – Clear Objects

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

### Step 51 – Create `metric`

Option 4. Create the object `metric` so you can reuse it in later steps.

``` r
  metric = sum(sims < benchmark) / n
```

### Step 52 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
  return(metric)
}
```

### Step 53 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
get_performance(d1 = 1, d2 = 1, d3 = 1, n = 100, benchmark = 2)
get_performance(d1 = 0, d2 = 0, d3 = 0, n = 100, benchmark = 2)
```

### Step 54 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
get_performance(d1 = 1, d2 = 1, d3 = 1, n = 100, benchmark = 30)
```

### Step 55 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
a %>% 
  rowwise() %>%
  mutate(m1 = get_performance(d1 = d1, d2 = d2, d3 = d3, n = 1000, benchmark = 30)) %>%
  ungroup()
```

## Learning Checks

**Learning Check 1.** What role does the helper `get_cost()` defined in
Step 12 play in this workflow?

<details>
<summary>
Show answer
</summary>

It encapsulates the conditional cost schedule so you can reuse it
whenever you mutate architecture rows.

</details>

**Learning Check 2.** What role does the helper `get_performance()`
defined in Step 41 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 3.** Which libraries does Step 1 attach, and why do you
run that chunk before others?

<details>
<summary>
Show answer
</summary>

It attaches dplyr and ggplot2, ensuring their functions are available
before you execute the downstream code.

</details>

**Learning Check 4.** After Step 2, what does `t` capture?

<details>
<summary>
Show answer
</summary>

It creates `t` that builds a tibble of scenario data. Create a data
frame,.

</details>
