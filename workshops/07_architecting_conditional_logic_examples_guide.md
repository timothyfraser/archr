This tutorial complements `07_architecting_conditional_logic_examples.R`
and unpacks the workshop on conditional logic examples. You will see how
it advances the Architecting Systems sequence while building confidence
with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working
  directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines
  interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from
  earlier workshops.

## Skills

- Navigate the script `07_architecting_conditional_logic_examples.R`
  within the Architecting Systems module.
- Connect the topic “Conditional logic examples” to systems architecting
  decisions.
- Load packages with `library()` and verify they attach without
  warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or
  architecture tables.
- Define custom functions to package repeatable logic.

## Process Overview

``` mermaid
flowchart LR
    A[Load Packages] --> B[Create m1]
    B[Create m1] --> C[Practice the Pipe]
    C[Practice the Pipe] --> D[Clear Objects]
```

## Application

### Step 1 – Load Packages

SETUP \#################################### Load packages.

``` r
library(dplyr)
library(archr)
library(ggplot2)
```

### Step 2 – Create `a`

Make architectures to work with.

``` r
a = enumerate_sf(n = c(2,2,2))
```

### Step 3 – Define `get_cost()`

Suppose. Create the helper function `get_cost()` so you can reuse it
throughout the workshop.

``` r
get_cost = function(d1, d2, d3){
  # Let's make some objects JUST for testing - be sure to comment them out when done
  # d1 = 1; d2 = 1; d3 = 1
```

### Step 4 – Create `m1`

When d1 is 1, make m1 3; When d1 is 0, make m1 0 and repeat for other
problem Or, try using case when.

``` r
  m1 = case_when(d1 == 1 ~ 3, d1 == 0 ~ 0)
  m2 = case_when(d2 == 1 ~ 6, d2 == 0 ~ 0)
  m3 = case_when(d3 == 1 ~ 9, d3 == 0 ~ 0)
```

### Step 5 – Create `metric`

Compute overall metric. Create the object `metric` so you can reuse it
in later steps.

``` r
  metric = m1+m2+m3
  return(metric)
}
```

### Step 6 – Practice the Pipe

Let’s try it. Use the `%>%` operator to pass each result to the next
tidyverse verb.

``` r
a %>%
  mutate(cost = get_cost(d1,d2,d3))
```

### Step 7 – Practice the Pipe

Use both. Use the `%>%` operator to pass each result to the next
tidyverse verb.

``` r
data = a %>%
  mutate(cost = get_cost(d1,d2,d3))
```

### Step 8 – Practice the Pipe

View histogram of cost values for your architectures!

``` r
data$cost %>% hist()
```

### Step 9 – Clear Objects

Cleanup! Remove objects from the environment to prevent name clashes.

``` r
rm(list = ls())
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

**Learning Check 2.** Which libraries does Step 1 attach, and why do you
run that chunk before others?

<details>
<summary>
Show answer
</summary>

It attaches dplyr, archr and ggplot2, ensuring their functions are
available before you execute the downstream code.

</details>

**Learning Check 3.** After Step 2, what does `a` capture?

<details>
<summary>
Show answer
</summary>

It creates `a` that enumerates architecture combinations with `archr`
helpers. Make architectures to work with.

</details>

**Learning Check 4.** After Step 4, what does `m1` capture?

<details>
<summary>
Show answer
</summary>

It creates `m1` that encodes conditional logic with `case_when()`. When
d1 is 1, make m1 3; When d1 is 0, make m1 0 and repeat for other problem
Or, try using case when.

</details>
