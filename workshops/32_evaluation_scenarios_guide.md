This tutorial complements `32_evaluation_scenarios.R` and unpacks the
workshop on evaluation scenario analysis. You will see how it advances
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

- Navigate the script `32_evaluation_scenarios.R` within the Evaluation
  module.
- Connect the topic “Evaluation scenario analysis” to systems
  architecting decisions.
- Load packages with `library()` and verify they attach without
  warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or
  architecture tables.
- Define custom functions to package repeatable logic.
- Iterate on visualisations built with `ggplot2`.

## Process Overview

``` mermaid
flowchart LR
    A[Load Packages] --> B[Practice the Pipe]
    B[Practice the Pipe] --> C[Practice the Pipe (Step 45)]
    C[Practice the Pipe (Step 45)] --> D[Run the Code Block]
```

## Application

### Step 1 – Load Packages

Attach dplyr to make its functions available.

``` r
library(dplyr)
library(readr)
library(tidyr)
library(archr)
```

### Step 2 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
data("donuts", package = "archr")
```

### Step 3 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
donuts
```

### Step 4 – Create `a`

Let’s enumerate!s. Create the object `a` so you can reuse it in later
steps.

``` r
a = enumerate_binary(n = 10)
```

### Step 5 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
a
# colSums(t(a)) * donuts$benefit
```

### Step 6 – Create `a`

MATRIX MULTIPLICATION METHODS \#######################################
Let’s enumerate!s.

``` r
a = enumerate_binary(n = 10)
```

### Step 7 – Build a Data Frame

Construct a small data frame that you can manipulate later.

``` r
tibble(
  benefit = colSums(t(a) * donuts$benefit),
  cost = colSums(t(a) * donuts$cost)
)
```

### Step 8 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
a %>%
  mutate(benefit = as.matrix(a) %*% donuts$benefit)
```

### Step 9 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
donuts
donuts$benefit
```

### Step 10 – Clear Objects

Clear. Remove objects from the environment to prevent name clashes.

``` r
rm(list = ls())
```

### Step 11 – Create `a`

Let’s enumerate!s. Create the object `a` so you can reuse it in later
steps.

``` r
a = enumerate_binary(n = 10)
```

### Step 12 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
data("d_donuts", package = "archr")
d_donuts
```

### Step 13 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
a %>%
  select(d1,d2) %>%
  left_join(
    by = c("d1" = "altid"),
    y = d_donuts %>% 
      filter(did == 1) %>%
      select(altid,
             d1_benefit = benefit)) %>%
  left_join(
    by = c("d2" = "altid"),
    y = d_donuts %>% 
      filter(did == 2) %>%
      select(altid,
             d2_benefit = benefit)) %>%
  mutate(benefit = d1_benefit + d2_benefit)
```

### Step 14 – Clear Objects

Clear. Remove objects from the environment to prevent name clashes.

``` r
rm(list = ls())
```

### Step 15 – Create `a`

Let’s enumerate!s. Create the object `a` so you can reuse it in later
steps.

``` r
a = enumerate_binary(n = 10)
```

### Step 16 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
data("d_donuts", package = "archr")
```

### Step 17 – Loop Through Values

For each column (decision).

``` r
for(i in 1:length(a)){
  # For each row
  for(j in 1:nrow(a)){
```

### Step 18 – Create `this_a`

i = 1; j = 1 Get the value from our matrix.

``` r
    this_a = a[[j,i]]
    # Grab our stats
    values = d_donuts %>% filter(did == i) %>% filter(altid == this_a)
    # Reassign the value to be the benefit
    a[[j,i]] <- values$benefit  
  }  
}
```

### Step 19 – Practice the Pipe

A data.frame of benefits per decision (column) per architecture (row).

``` r
a %>%
  mutate(benefit = d1+d2+d3+d4+d5+d6+d7+d8+d9+d10)
```

### Step 20 – Clear Objects

Clear. Remove objects from the environment to prevent name clashes.

``` r
rm(list = ls())
```

### Step 21 – Create `a`

SUPER FOR LOOP \######################################## Let’s
enumerate!s.

``` r
a = enumerate_binary(n = 10)
```

### Step 22 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
data("d_donuts", package = "archr")
```

### Step 23 – Practice the Pipe

Benefits (make a blank matrix, then turn it into a tibble).

``` r
b = matrix(NA, nrow = nrow(a), ncol = ncol(a), dimnames = list(NULL, names(a))) %>% as_tibble()
# Costs (make a blank matrix, then turn it into a tibble)
c = matrix(NA, nrow = nrow(a), ncol = ncol(a), dimnames = list(NULL, names(a))) %>% as_tibble()
```

### Step 24 – Loop Through Values

For each decison. Iterate over values to apply the same logic to each
item.

``` r
for(i in 1:length(a)){
  # For each row (architecture)
  for(j in 1:nrow(a)){
```

### Step 25 – Create `this_a`

i = 1; j = 1 Get the value from our matrix.

``` r
    this_a = a[[j,i]]
    # Grab our stats
    values = d_donuts %>% filter(did == i) %>% filter(altid == this_a)
```

### Step 26 – Run the Code Block

Reassign the value to be the benefit.

``` r
    b[[j,i]] <- values$benefit
```

### Step 27 – Run the Code Block

Reassign the value to be the costs.

``` r
    c[[j,i]] <- values$cost  
  }  
}
```

### Step 28 – Practice the Pipe

A data.frame of benefits per decision (column) per architecture (row).

``` r
b %>% mutate(benefit = d1+d2+d3+d4+d5+d6+d7+d8+d9+d10) 
# A data.frame of costs per decision (column) per architecture (row)
c %>% mutate(cost = d1+d2+d3+d4+d5+d6+d7+d8+d9+d10) 
# Our original clean data.frame
a
```

### Step 29 – Clear Objects

Clear. Remove objects from the environment to prevent name clashes.

``` r
rm(list = ls())
```

### Step 30 – Create `a`

RECODING \############################################## Let’s
enumerate!s.

``` r
a = enumerate_binary(n = 10)
```

### Step 31 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
data("d_donuts", package = "archr")
```

### Step 32 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
d_donuts
```

### Step 33 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
a %>%
  # Recode every single value
  mutate(
    d1 = case_when( d1 == 0 ~ 0,   d1 == 1 ~ 3),  
    d2 = case_when( d2 == 0 ~ 0, d2 == 1 ~ 6)
    ) %>%
  # Get total benefit
  mutate(benefit = d1+d2) %>%
  # Let's look at just our d1 and d2 columsn...
  select(d1,d2, benefit) %>%
  # Look at bottom of the data.frame
  tail()
```

### Step 34 – Clear Objects

Clear. Remove objects from the environment to prevent name clashes.

``` r
rm(list = ls())
```

### Step 35 – Define `get_plusone()`

EXAMPLE FUNCTION. Create the helper function `get_plusone()` so you can
reuse it throughout the workshop.

``` r
get_plusone = function(a = 1){
  # Testing values
  # a = 1
  # a = c(1,2)
```

### Step 36 – Create `output`

Process. Create the object `output` so you can reuse it in later steps.

``` r
  output = a + 1
```

### Step 37 – Run the Code Block

Output. Execute the block and pay attention to the output it produces.

``` r
  return(output)
}
```

### Step 38 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
get_plusone() # get_plusone(a = 1)
```

### Step 39 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
get_plusone(a = 2)
```

### Step 40 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
get_plusone(a = c(1,2,3,4,5))
```

### Step 41 – Create `a`

Enumerate just 3 DECISIONS.

``` r
a = enumerate_binary(n = 3)
# Get benefit/cost data
data("d_donuts", package = "archr")
# Let's say we're just looking at the FIRST 3 DECISIONS
d_donuts %>% filter(did %in% 1:3)
```

### Step 42 – Define `get_cost()`

Create the helper function `get_cost()` so you can reuse it throughout
the workshop.

``` r
get_cost = function(d1,d2,d3){
  # Testing values
  # d1 = 1; d2 = 1; d3 = 1
```

### Step 43 – Create `m1`

Get the cost statistics Recode decision 1 so that when decision 1
equals, it costs \$1.

``` r
  m1 = case_when(d1 == 1 ~ 1, d1 == 0 ~ 0)
  # Recode decision 2
  m2 = case_when(d2 == 1 ~ 5, d2 == 0 ~ 0)
  # Recode decision 3
  m3 = case_when(d3 == 1 ~ 70, d3 == 0 ~ 0)
```

### Step 44 – Create `metric`

Compute our overall metric.

``` r
  metric = m1 + m2 + m3
  return(metric)
}
```

### Step 45 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
a %>% mutate(cost = get_cost(d1,d2,d3))
```

### Step 46 – Define `get_benefit()`

Create the helper function `get_benefit()` so you can reuse it
throughout the workshop.

``` r
get_benefit = function(d1, d2, d3){
  # Let's make some objects JUST for testing - be sure to comment them out when done
  # d1 = 1; d2 = 1; d3 = 1
```

### Step 47 – Create `m1`

When d1 is 1, make m1 3; When d1 is 0, make m1 0 and repeat for other
problem Or, try using case when.

``` r
  m1 = case_when(d1 == 1 ~ 3, d1 == 0 ~ 0)
  m2 = case_when(d2 == 1 ~ 6, d2 == 0 ~ 0)
  m3 = case_when(d3 == 1 ~ 9, d3 == 0 ~ 0)
```

### Step 48 – Create `metric`

Compute overall metric. Create the object `metric` so you can reuse it
in later steps.

``` r
  metric = m1+m2+m3
  return(metric)
}
```

### Step 49 – Practice the Pipe

Let’s try it. Use the `%>%` operator to pass each result to the next
tidyverse verb.

``` r
a %>%
  mutate(benefit = get_benefit(d1,d2,d3))
```

### Step 50 – Practice the Pipe

Use both. Use the `%>%` operator to pass each result to the next
tidyverse verb.

``` r
data = a %>%
  mutate(benefit = get_benefit(d1,d2,d3)) %>%
  mutate(cost = get_cost(d1,d2,d3))
```

### Step 51 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.

``` r
ggplot() +
  geom_point(data = data, mapping = aes(x = benefit, y = cost))
```

### Step 52 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.

``` r
ggplot() +
  geom_point(data = data, mapping = aes(x = d1, y = benefit))
```

### Step 53 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
data %>%
  group_by(d1) %>%
  summarize(benefit = mean(benefit))
```

### Step 54 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
data %>%
  group_by(d1,d2) %>%
  summarize(benefit = mean(benefit))
```

### Step 55 – Try Arithmetic

The interaction effect of choosing BOTH d1 = 1 and d2 = 1 is +9
tastiness points.

``` r
13.5 - 4.5
```

### Step 56 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
data("donuts", package = "archr")
donuts
# Make a table m we'll build
# Enumerate architectures, including an .id
m = enumerate_binary(n = nrow(donuts), .id = TRUE)
```

### Step 57 – Practice the Pipe

Record the architectures as a matrix.

``` r
a = m %>% select(-id) %>% as.matrix()
```

### Step 58 – Practice the Pipe

Add in columns for total metrics.

``` r
m = m %>% 
  mutate(
    # Matrix multiple the matrix by the vector of benefits
    benefit = a %*% donuts$benefit,
    # Matrix multiple the matrix by the vector of costs
    cost =   a %*% donuts$cost)
```

### Step 59 – Practice the Pipe

View last five. Use the `%>%` operator to pass each result to the next
tidyverse verb.

``` r
m %>% select(id, benefit, cost) %>% tail(5)
```

### Step 60 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.

``` r
ggplot() +
  geom_point(data = m, mapping = aes(x = benefit, y = cost))
```

### Step 61 – Practice the Pipe

Get the ids of the pareto front with pareto().

``` r
m = m %>%
  mutate(front = pareto(x = cost, y = -benefit))
```

### Step 62 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
m %>% select(id, cost, benefit, front)
# ?archr::pareto()
```

### Step 63 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.

``` r
ggplot() +
  geom_point(data = m, mapping = aes(x = benefit, y = cost),
             color = "grey") +
  geom_line(data = m %>% filter(front == TRUE),
            mapping = aes(x = benefit, y = cost),
            color = "red")
```

### Step 64 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
m %>% 
  filter(front == TRUE & benefit > 20 & cost < 100)
```

### Step 65 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.

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

### Step 66 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
m
```

## Learning Checks

**Learning Check 1.** What role does the helper `get_plusone()` defined
in Step 35 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 2.** What role does the helper `get_cost()` defined in
Step 42 play in this workflow?

<details>
<summary>
Show answer
</summary>

It encapsulates the conditional cost schedule so you can reuse it
whenever you mutate architecture rows.

</details>

**Learning Check 3.** What role does the helper `get_benefit()` defined
in Step 46 play in this workflow?

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

It attaches dplyr, readr, tidyr and archr, ensuring their functions are
available before you execute the downstream code.

</details>
