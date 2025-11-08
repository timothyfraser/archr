This tutorial complements `06_architecting_dashboard_case_study.R` and
unpacks the workshop on dashboard architecture case study. You will see
how it advances the Architecting Systems sequence while building
confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working
  directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines
  interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from
  earlier workshops.

## Skills

- Navigate the script `06_architecting_dashboard_case_study.R` within
  the Architecting Systems module.
- Connect the topic “Dashboard architecture case study” to systems
  architecting decisions.
- Load packages with `library()` and verify they attach without
  warnings.
- Define custom functions to package repeatable logic.

## Process Overview

``` mermaid
flowchart LR
    A[Load Packages] --> B[Define get_cost()]
    B[Define get_cost()] --> C[Create metric]
    C[Create metric] --> D[Run the Code Block]
```

## Application

### Step 1 – Load Packages

Attach dplyr to make its functions available.

``` r
library(dplyr)
library(readr)
library(archr)
```

### Step 2 – Create `a`

Create the object `a` so you can reuse it in later steps.

``` r
a = tibble(
  # Mobile 0 or Web 1 or Both 2
  d1 = 1,
  # Navigation Structure (A = 0 or B = 1)
  d2 = 1,
  # Customizable (no = 0 or yes = 1)
  d3 = 0
)
```

### Step 3 – Define `get_cost()`

**Option A: Super Specific** testing values d1 = 1; d2 = 1; d3 = 0.

``` r
get_cost = function(d1,d2,d3){
  m1_cost = case_when(
    d1 == 0 ~ 150,
    d1 == 1 ~ 150,
    d1 == 2 ~ 200
  )
```

### Step 4 – Create `m2_hours`

Create the object `m2_hours` so you can reuse it in later steps.

``` r
  m2_hours = case_when(
    d2 == 0 ~ 10, # hours
    d2 == 1 ~ 10 # hours
  )
```

### Step 5 – Create `m3_hours`

m1_cost \* m2_hours. Create the object `m3_hours` so you can reuse it in
later steps.

``` r
  m3_hours = case_when(
    d3 == 0 ~ 0, # hours
    d3 == 1 ~ 50 # hours
  )
```

### Step 6 – Create `metric`

total cost. Create the object `metric` so you can reuse it in later
steps.

``` r
  metric = m1_cost * (m2_hours + m3_hours)
  return(metric)
}
```

### Step 7 – Create `m1`

likert scale - 3 point (low = 0, medium = 1, high = 2).

``` r
m1 = case_when(
  d1 == 0 ~ 0,
  d1 == 1 ~ 0,
  d1 == 2 ~ 1
)
m2 = case_when(
  d2 == 0 ~ 1,
  d2 == 1 ~ 1
)
```

### Step 8 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
m1 + m2
mean(c(m1,m2)) # average cost on a 3 point scale from low = 0 to high = 2
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

It attaches dplyr, readr and archr, ensuring their functions are
available before you execute the downstream code.

</details>

**Learning Check 3.** After Step 2, what does `a` capture?

<details>
<summary>
Show answer
</summary>

It creates `a` that builds a tibble of scenario data. Create the object
`a` so you can reuse it in later steps.

</details>

**Learning Check 4.** After Step 4, what does `m2_hours` capture?

<details>
<summary>
Show answer
</summary>

It creates `m2_hours` that encodes conditional logic with `case_when()`.
Create the object `m2_hours` so you can reuse it in later steps.

</details>
