This tutorial complements `21_enumeration_capstone.R` and unpacks the
workshop on enumeration capstone lab. You will see how it advances the
Enumeration sequence while building confidence with base R and tidyverse
tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working
  directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines
  interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from
  earlier workshops.

## Skills

- Navigate the script `21_enumeration_capstone.R` within the Enumeration
  module.
- Connect the topic “Enumeration capstone lab” to systems architecting
  decisions.
- Load packages with `library()` and verify they attach without
  warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or
  architecture tables.
- Define custom functions to package repeatable logic.

## Process Overview

``` mermaid
flowchart LR
    A[Load Packages] --> B[Practice the Pipe]
    B[Practice the Pipe] --> C[Load Packages (Step 8)]
    C[Load Packages (Step 8)] --> D[Clear Objects]
```

## Application

### Step 1 – Load Packages

Attach dplyr to make its functions available.

``` r
library(dplyr)
library(tidyr)
```

### Step 2 – Create `grid`

Get full factorial grid of combinations.

``` r
grid = expand_grid(
  # Catalyst K
  k = c("A", "B"),
  # Concentration C
  c = c(20, 40),
  # Temperature t
  t = c(160, 180),
) %>%
  # order columns as shown in the example...
  mutate(run = 1:n()) %>%
  select(run, t, c, k)
```

### Step 3 – Practice the Pipe

We run the experiment once and get these results.

``` r
data = grid %>% mutate(y = c(60,72,54,68,52,83,45, 80))
```

### Step 4 – Practice the Pipe

Calculate the direct (one-way) treatment effects.

``` r
data %>%
  summarize(
    dbar_c = mean( y[c==40] - y[c==20] ),
    dbar_t = mean( y[t== 180] - y[t==160] ),
    dbar_k = mean( y[k== "B"] - y[k=="A"] )
  )
```

### Step 5 – Practice the Pipe

Calculate the two-way treatment effects.

``` r
data %>%
  reframe(
    xbar1 = y[ (t==180 & k=="B") | (t==160& k=="A") ] %>% mean(),
    xbar0 = y[ (t==160 & k=="B") | (t==180& k=="A")] %>% mean(),
    dbar = xbar1 - xbar0
  )
```

### Step 6 – Define `get_minsize()`

Create the helper function `get_minsize()` so you can reuse it
throughout the workshop.

``` r
get_minsize = function(data, decisions = c("d1")){
  library(dplyr)
  library(tidyr)
```

### Step 7 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
  data %>%
    select(any_of(decisions)) %>%
    # Count up k, the number of unique alternatives per decision
    summarize(across(everything(), .fns = ~length(unique(.x)))) %>%
    # Pivot it longer
    tidyr::pivot_longer(
      cols = everything(), 
      names_to = "k", values_to = "value") %>%
    # Count up the minimum number of architectures necessary to test
    # that number of main effects
    summarize(minsize = 1 + sum(value - 1)) %>%
    # Return it as a vector
    with(minsize)        
}
```

### Step 8 – Load Packages

Attach dplyr to make its functions available.

``` r
library(dplyr)
library(tidyr)
library(archr)
```

### Step 9 – Create `a`

Create the object `a` so you can reuse it in later steps.

``` r
a = enumerate_sf(n = c(2,5,4))
```

### Step 10 – Run the Code Block

to count sample size needed…

``` r
get_minsize(a, decisions = c("d1"))
get_minsize(a, decisions = c("d1", "d2"))
get_minsize(a, decisions = c("d1", "d2", "d3"))
```

### Step 11 – Clear Objects

Remove objects from the environment to prevent name clashes.

``` r
rm(list = ls())
```

## Learning Checks

**Learning Check 1.** Which libraries does Step 1 attach, and why do you
run that chunk before others?

<details>
<summary>
Show answer
</summary>

It attaches dplyr and tidyr, ensuring their functions are available
before you execute the downstream code.

</details>

**Learning Check 2.** After Step 2, what does `grid` capture?

<details>
<summary>
Show answer
</summary>

It creates `grid` that adds derived columns, and selects a focused set
of columns. Get full factorial grid of combinations.

</details>

**Learning Check 3.** After Step 3, what does `data` capture?

<details>
<summary>
Show answer
</summary>

It creates `data` that adds derived columns, and threads the result
through a dplyr pipeline. We run the experiment once and get these
results.

</details>

**Learning Check 4.** After Step 4, what does `dbar_c` capture?

<details>
<summary>
Show answer
</summary>

It creates `dbar_c` that computes summary statistics, and threads the
result through a dplyr pipeline. Calculate the direct (one-way)
treatment effects.

</details>
