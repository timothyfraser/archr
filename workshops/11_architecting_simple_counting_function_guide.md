---
title: "[11] Counting function recitation Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `11_architecting_simple_counting_function.R` and unpacks the workshop on counting function recitation. You will see how it advances the Architecting Systems sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `11_architecting_simple_counting_function.R` within the Architecting Systems module.
- Connect the topic "Counting function recitation" to systems architecting decisions.
- Load packages with `library()` and verify they attach without warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or architecture tables.
- Define custom functions to package repeatable logic.

## Application

### Step 1 – Define `count_n_m()`

Create the helper function `count_n_m()` so you can reuse it throughout the workshop.


``` r
count_n_m = function(n, m){  n + m }
```

### Step 2 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
archr::
count_n_m = function(n, m){  
  # testing values
  # library(dplyr)
  # n = 3
  # m = 2
```

### Step 3 – Create `data`

Create the object `data` so you can reuse it in later steps.


``` r
  data = tibble(n = n, 
         m = m) %>%
    mutate(count = n + m)
  output = data$count
  return(output)
}
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "11_architecting_simple_counting_function.R"))` from the Console or press the Source button while the script is active.

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
