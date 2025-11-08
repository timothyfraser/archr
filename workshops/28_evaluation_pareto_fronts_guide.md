This tutorial complements `28_evaluation_pareto_fronts.R` and unpacks
the workshop on pareto fronts exploration. You will see how it advances
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

- Navigate the script `28_evaluation_pareto_fronts.R` within the
  Evaluation module.
- Connect the topic “Pareto fronts exploration” to systems architecting
  decisions.
- Load packages with `library()` and verify they attach without
  warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or
  architecture tables.
- Iterate on visualisations built with `ggplot2`.

## Process Overview

``` mermaid
flowchart LR
    A[Load Packages] --> B[Practice the Pipe]
    B[Practice the Pipe] --> C[Start a ggplot]
    C[Start a ggplot] --> D[Clear Objects]
```

## Application

### Step 1 – Load Packages

SETUP \################################# Load packages.

``` r
library(dplyr)
library(archr)
library(ggplot2)
# Load data
data("donuts", package = "archr")
donuts
```

### Step 2 – Create `m`

PARETO FRONT \############################ Make a table m we’ll build
Enumerate architectures, including an .id.

``` r
m = enumerate_binary(n = nrow(donuts), .id = TRUE)
```

### Step 3 – Practice the Pipe

Record the architectures as a matrix.

``` r
a = m %>% select(-id) %>% as.matrix()
```

### Step 4 – Practice the Pipe

Add in columns for total metrics.

``` r
m = m %>% 
  mutate(
    # For this example, we'll calculate benefit and cost with matrix multiplication,
    # but you could calculate cost or benefit many different ways
    # Matrix multiple the matrix by the vector of benefits
    benefit = a %*% donuts$benefit,
    # Matrix multiple the matrix by the vector of costs
    cost =   a %*% donuts$cost)
```

### Step 5 – Practice the Pipe

View last five. Use the `%>%` operator to pass each result to the next
tidyverse verb.

``` r
m %>% select(id, benefit, cost) %>% tail(5)
```

### Step 6 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.

``` r
ggplot() +
  geom_point(data = m, mapping = aes(x = benefit, y = cost))
```

### Step 7 – Practice the Pipe

Get the ids of the pareto front with pareto().

``` r
m = m %>%
  mutate(front = pareto(x = cost, y = -benefit))
```

### Step 8 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
m %>% select(id, cost, benefit, front)
# ?archr::pareto()
```

### Step 9 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.

``` r
ggplot() +
  geom_point(data = m, mapping = aes(x = benefit, y = cost),
             color = "grey") +
  geom_line(data = m %>% filter(front == TRUE),
            mapping = aes(x = benefit, y = cost),
            color = "red")
```

### Step 10 – Practice the Pipe

Thresholds \##################################### Show just a slice of
the architectures based on thresholds.

``` r
m %>% 
  filter(front == TRUE & benefit > 20 & cost < 100)
```

### Step 11 – Start a ggplot

Add those thresholds for context usinge geom_hline and geom_vline!

``` r
ggplot() +
  geom_point(data = m, mapping = aes(x = benefit, y = cost),
             color = "grey") +
  geom_line(data = m %>% filter(front == TRUE),
            mapping = aes(x = benefit, y = cost),
            color = "red") +
  geom_hline(yintercept = 100, color = "blue") +
  geom_vline(xintercept = 20, color = "blue")
```

### Step 12 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
m
```

### Step 13 – Clear Objects

Cleanup ! Remove objects from the environment to prevent name clashes.

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

It attaches dplyr, archr and ggplot2, ensuring their functions are
available before you execute the downstream code.

</details>

**Learning Check 2.** After Step 2, what does `m` capture?

<details>
<summary>
Show answer
</summary>

It creates `m` that enumerates architecture combinations with `archr`
helpers. PARETO FRONT \############################ Make a table m we’ll
build Enumerate architectures, including an .id.

</details>

**Learning Check 3.** After Step 3, what does `a` capture?

<details>
<summary>
Show answer
</summary>

It creates `a` that selects a focused set of columns, and threads the
result through a dplyr pipeline. Record the architectures as a matrix.

</details>

**Learning Check 4.** After Step 9, what does `color` capture?

<details>
<summary>
Show answer
</summary>

It creates `color` that filters rows to the cases of interest, and
initialises a ggplot visualisation. Initialize a ggplot so you can layer
geoms and customise aesthetics.

</details>
