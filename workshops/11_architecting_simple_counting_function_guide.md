This tutorial complements `11_architecting_simple_counting_function.R`
and unpacks the workshop on counting function recitation. You will see
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

- Navigate the script `11_architecting_simple_counting_function.R`
  within the Architecting Systems module.
- Connect the topic “Counting function recitation” to systems
  architecting decisions.
- Load packages with `library()` and verify they attach without
  warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or
  architecture tables.
- Define custom functions to package repeatable logic.

## Process Overview

``` mermaid
flowchart LR
    A[Define count_n_m()] --> B[Run the Code Block]
    B[Run the Code Block] --> C[Create data]
```

## Application

### Step 1 – Define `count_n_m()`

Create the helper function `count_n_m()` so you can reuse it throughout
the workshop.

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

**Learning Check 1.** What role does the helper `count_n_m()` defined in
Step 1 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 2.** Which libraries does Step 2 attach, and why do you
run that chunk before others?

<details>
<summary>
Show answer
</summary>

It attaches dplyr, ensuring their functions are available before you
execute the downstream code.

</details>

**Learning Check 3.** After Step 3, what does `data` capture?

<details>
<summary>
Show answer
</summary>

It creates `data` that adds derived columns, and builds a tibble of
scenario data. Create the object `data` so you can reuse it in later
steps.

</details>
