This tutorial complements `08_architecting_metric_design.R` and unpacks
the workshop on metric design walkthrough. You will see how it advances
the Architecting Systems sequence while building confidence with base R
and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working
  directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines
  interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from
  earlier workshops.

## Skills

- Navigate the script `08_architecting_metric_design.R` within the
  Architecting Systems module.
- Connect the topic “Metric design walkthrough” to systems architecting
  decisions.
- Load packages with `library()` and verify they attach without
  warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or
  architecture tables.
- Define custom functions to package repeatable logic.

## Process Overview

``` mermaid
flowchart LR
    A[Load Packages] --> B[Define get_cost()]
    B[Define get_cost()] --> C[Define get_reliability()]
    C[Define get_reliability()] --> D[Practice the Pipe]
```

## Application

### Step 1 – Load Packages

Attach dplyr to make its functions available.

``` r
library(dplyr)
library(archr)
```

### Step 2 – Create `archs`

Create the object `archs` so you can reuse it in later steps.

``` r
archs = enumerate_binary(n = 5, .id = TRUE)
```

### Step 3 – Define `get_cost()`

Cost metric function. Create the helper function `get_cost()` so you can
reuse it throughout the workshop.

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

Benefit metric function. Create the helper function `get_benefit()` so
you can reuse it throughout the workshop.

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

Reliability metric function. Create the helper function
`get_reliability()` so you can reuse it throughout the workshop.

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

2.  METRICS
    \###########################################################################.
    Use the `%>%` operator to pass each result to the next tidyverse
    verb.

``` r
archs = archs %>% mutate(cost = get_cost(d1,d2,d3,d4,d5))
archs = archs %>% mutate(benefit = get_benefit(d1,d2,d3,d4,d5))
archs = archs %>% mutate(reliability = get_reliability(t = 1000, d1,d2,d3,d4,d5))
```

## Learning Checks

**Learning Check 1.** What role does the helper `get_cost()` defined in
Step 3 play in this workflow?

<details>
<summary>
Show answer
</summary>

It encapsulates the conditional cost schedule so you can reuse it
whenever you mutate architecture rows.

</details>

**Learning Check 2.** What role does the helper `get_benefit()` defined
in Step 4 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 3.** What role does the helper `get_reliability()`
defined in Step 5 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 4.** Which libraries does Step 1 attach, and why do you
run that chunk before others?

<details>
<summary>
Show answer
</summary>

It attaches dplyr and archr, ensuring their functions are available
before you execute the downstream code.

</details>
