---
title: "[16] Enumeration with constraints Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `16_enumeration_constraints.R` and unpacks the workshop on enumeration with constraints. You will see how it advances the Enumeration sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `16_enumeration_constraints.R` within the Enumeration module.
- Connect the topic "Enumeration with constraints" to systems architecting decisions.
- Load packages with `library()` and verify they attach without warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or architecture tables.

## Application

### Step 1 – Load Packages

Attach dplyr to make its functions available.


``` r
library(dplyr)
library(readr)
library(tidyr)
library(archr)
```

### Step 2 – Create `decision1`

D1: Get a donut (Binary: 0, 1)?


``` r
decision1 = enumerate_binary(n = 1, .did = 1)
# D2a: Features on Donut (DS) (0,1, 0,1)
decision2a = enumerate_ds(n = 2, k = 2, .did = 2) %>%
  select(d2a_1 = d2_1, d2a_2 = d2_2) %>%
  mutate(d2b = 3)
# D2b: If not Donut, what other breakfast? (0,1,2,3)
decision2b = enumerate_sf(n = c(4), .did = 2) %>%
  select(d2b = d2) %>%
  mutate(d2a_1 = 0, d2a_2 = 0)
```

### Step 3 – Create `part1`

Create the object `part1` so you can reuse it in later steps.


``` r
part1 = expand_grid(
  decision1 %>% filter(d1 == 0),
  decision2a
)
```

### Step 4 – Create `part2`

Create the object `part2` so you can reuse it in later steps.


``` r
part2 = expand_grid(
  decision1 %>% filter(d1 == 1),
  decision2b
)
```

### Step 5 – Create `arch`

Create the object `arch` so you can reuse it in later steps.


``` r
arch = bind_rows(
  part1, part2
)
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "16_enumeration_constraints.R"))` from the Console or press the Source button while the script is active.

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
