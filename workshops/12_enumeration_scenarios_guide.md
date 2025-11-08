---
title: "[12] Enumeration scenario examples Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `12_enumeration_scenarios.R` and unpacks the workshop on enumeration scenario examples. You will see how it advances the Enumeration sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `12_enumeration_scenarios.R` within the Enumeration module.
- Connect the topic "Enumeration scenario examples" to systems architecting decisions.
- Load packages with `library()` and verify they attach without warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or architecture tables.

## Application

### Step 1 – Load Packages

Attach dplyr to make its functions available.


``` r
library(dplyr)
library(tidyr)
library(archr)
```

### Step 2 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
enumerate_sf(n = 3)
enumerate_sf(n = 2)
enumerate_ds(n = 2, k = 2)
```

### Step 3 – Create `a`

Create the object `a` so you can reuse it in later steps.


``` r
a = expand_grid(
  enumerate_sf(n = 3, .did = 1),
  enumerate_sf(n = 2, .did = 2),
  enumerate_ds(n = 2, k = 2, .did = 3)
)
```

### Step 4 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
a
```

### Step 5 – Practice the Pipe

k = what's the max number of options you can choose simulataneously minimum number??


``` r
enumerate_ds(n = 2, k = 2, .did = 3) %>%
  mutate(count =  d3_1 + d3_2 ) %>%
  filter(count >= 1)
```

### Step 6 – Create `a`

Create the object `a` so you can reuse it in later steps.


``` r
a = expand_grid(
  enumerate_sf(n = 3, .did = 1),
  enumerate_sf(n = 2, .did = 2),
  enumerate_ds(n = 2, k = 2, .did = 3) %>%
    mutate(count =  d3_1 + d3_2 ) %>%
    filter(count >= 1) %>%
    select(-count)
)
```

### Step 7 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
a
```

### Step 8 – Load Packages

Attach dplyr to make its functions available.


``` r
library(dplyr)
library(tidyr)
library(archr)
library(ggplot2)
```

### Step 9 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
enumerate_ds(n = 5, k = 5, .did = 1) %>%
  filter((d1_1 + d1_2 + d1_3 + d1_4 + d1_5) > 0)
enumerate_sf(n = 3)
enumerate_ds(n = 2)
```

### Step 10 – Create `a`

Create the object `a` so you can reuse it in later steps.


``` r
a = expand_grid(
  enumerate_ds(n = 5, k = 5, .did = 1) %>%
    filter((d1_1 + d1_2 + d1_3 + d1_4 + d1_5) > 0),
  enumerate_sf(n = 3, .did = 2),
  enumerate_ds(n = 2, k = 2, .did = 3)
)
```

### Step 11 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
a
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "12_enumeration_scenarios.R"))` from the Console or press the Source button while the script is active.

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
