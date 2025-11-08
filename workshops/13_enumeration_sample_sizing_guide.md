---
title: "[13] Minimum sample sizing utility Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `13_enumeration_sample_sizing.R` and unpacks the workshop on minimum sample sizing utility. You will see how it advances the Enumeration sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `13_enumeration_sample_sizing.R` within the Enumeration module.
- Connect the topic "Minimum sample sizing utility" to systems architecting decisions.
- Load packages with `library()` and verify they attach without warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or architecture tables.
- Define custom functions to package repeatable logic.

## Application

### Step 1 – Define `get_minsize()`

Create the helper function `get_minsize()` so you can reuse it throughout the workshop.


``` r
get_minsize = function(data, decisions = c("d1")){
  library(dplyr)
  library(tidyr)
```

### Step 2 – Practice the Pipe

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

### Step 3 – Load Packages

Attach dplyr to make its functions available.


``` r
library(dplyr)
library(tidyr)
library(archr)
```

### Step 4 – Create `a`

Create the object `a` so you can reuse it in later steps.


``` r
a = enumerate_sf(n = c(2,5,4))
```

### Step 5 – Run the Code Block

to count sample size needed...


``` r
get_minsize(a, decisions = c("d1"))
get_minsize(a, decisions = c("d1", "d2"))
get_minsize(a, decisions = c("d1", "d2", "d3"))
```

### Step 6 – Clear Objects

Remove objects from the environment to prevent name clashes.


``` r
rm(list = ls())
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "13_enumeration_sample_sizing.R"))` from the Console or press the Source button while the script is active.

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
