This tutorial complements `47_optimization_green_space_case.R` and
unpacks the workshop on green space optimization case. You will see how
it advances the Optimization sequence while building confidence with
base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working
  directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines
  interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from
  earlier workshops.

## Skills

- Navigate the script `47_optimization_green_space_case.R` within the
  Optimization module.
- Connect the topic “Green space optimization case” to systems
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
    A[Load Packages] --> B[Run the Code Block]
    B[Run the Code Block] --> C[Run the Code Block (Step 21)]
    C[Run the Code Block (Step 21)] --> D[Run the Code Block (Step 31)]
```

## Application

### Step 1 – Load Packages

Load packages \####. Attach dplyr to make its functions available.

``` r
library(dplyr)
library(tidyr)
library(archr)
library(ggplot2)
```

### Step 2 – Create `e`

enumerate \###############. Create the object `e` so you can reuse it in
later steps.

``` r
e = expand_grid(
  #decision on location
  #options:
  # Section 0: closer to monuments and parks (angled parking)
  # Section 1: Restaurants/Businesses (angled parking)
  # Section 2: cultural trail and games (parallel parking)
  enumerate_sf(n=3, .did = 1),
  #Location: SF : 3 options
  #Moving Function
  # Options:
  # d1_0 = Walking
  # d1_1 = Biking
  # d1_2 = Running
  #create constraint, if we select biking lane, we cannot have a running lane as well
  enumerate_ds (n = 3, k = 2, .did = 2)
) %>%
  # CONSTRAINTS
  filter(!(d2_1 == 1 & d2_2 == 1)) %>%
  expand_grid(
    #Space function
    #options:
    # 0 = shelters
    # 1 = green space
    enumerate_sf(n = 2, .did = 3),
    #decision on space allocation
    #options:
    # 0 = 60% movingF ,40% spaceF
    # 1 = 40% movingF ,60% spaceF
    enumerate_sf (n = 2, .did = 4), #Space Allocation: SF: 2 options
    #decision on Street traffic
    #options:
    # 0 = One-way;
    # 1 = Two-way;
    # 2 = Alternating (lane that changes direction based on traffic need)
    enumerate_sf(n = 3, .did = 5),
    #decision
    #Placement of <a1 = Crosswalks, a2 = Benches, a3 = Street Lights>:
    # b1 = At intersection
    # b2 = At middle of block
    #create constraint, we cannot have bench without a street light (for safety)
    enumerate_assignment(n = 3, m = 2, k = 2, n_alts = 2, .did = 6)
  )  %>%
  # CONSTRAINTS
  filter(! (((d6_a2_b1)&!(d6_a3_b1))
            | ((d6_a2_b2)&!(d6_a3_b2))))  %>%
  expand_grid(
    #decision on speed limit
    #options: 0 = 10 mph; 1 = 15 mph; 2 = 20 mph; 3 = 25 mph
    #add constraint, if traffic is one way, limit has to be below 15mph
    #d5$d1 == 0 d7$d1 >= 2
    enumerate_sf(n = 4, .did = 7)
  ) %>%
  # CONSTRAINTS
  filter(!(d5 == 0 & d7 >= 2 )) %>%
  expand_grid(
    #Median Design:
    #options:  0 = 0 ft; 1 = 5 ft, with bushes; 2 = 5 ft, with trees
    enumerate_sf(n = 3, .did = 8),
    #Barrier Design:
    #options: 0 = Outer; 1 = Inner
    enumerate_sf (n = 2, .did = 9)
  )
```

### Step 3 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
e %>% glimpse()
```

### Step 4 – Practice the Pipe

To take a stratified sample stratifying by d2, We’ll need to concatenate
its multiple columns into one column, like this.

``` r
e = e %>%
  mutate(d2 = paste0(d2_1, d2_2, d2_3)) 
# Stratified sample of 100 architectures per strata!
sample = e %>%
  group_by(d1, d2, d3, d5) %>%
  sample_n(size = 100) %>%
  ungroup()
# View it!
sample %>% glimpse()
```

### Step 5 – Define `get_duration()`

Create the helper function `get_duration()` so you can reuse it
throughout the workshop.

``` r
get_duration = function(d3,d4,d8, d9){
  # Testing values
  # d1 = 1; d2 = 1; d3 = 1
  # Get the duration statistics
  # Recode decision 3 so that when decision 1 equals, it costs $1
  m3 = case_when(d3 == 1 ~ 15, d3 == 0 ~ 75)
  # Recode decision 4
  m4 = case_when(d4 == 1 ~ 100, d4 == 0 ~ 70)
  # Recode decision 8
  m8 = case_when(d8 == 2 ~ 35, d8 == 1 ~ 33, d8 == 0 ~ 25)
  # Recode decision 8
  m9 = case_when(d9 == 1 ~ 2, d9 == 0 ~ 5)
  # Compute our overall metric
  metric = m3 + m4 + m8 +m9
  return(metric)
}
```

### Step 6 – Define `get_cost()`

Create the helper function `get_cost()` so you can reuse it throughout
the workshop.

``` r
get_cost = function(d3,d5,d8,d6a1b1,d6a1b2,d6a2b1,d6a2b2,d6a3b1,d6a3b2){
  # Testing values
  # d1 = 1; d2 = 1; d3 = 1
  # Get the cost statistics
  # Recode decision 3 so that when decision 1 equals, it costs $1
  m3 = case_when(d3 == 1 ~ 1245, d3 == 0 ~ 15000)
  # Recode decision 5
  m5 = case_when(d5 == 2 ~ 110000, d5 == 1 ~ 500, d5 == 0 ~ 375)
  # Recode decision 8
  m8 = case_when(d8 == 2 ~ 17880, d8 == 1 ~ 6792, d8 == 0 ~ 237.6)
  # Recode decision 6
  m6a1b1 = case_when(d6a1b1 == 1 ~ 2600, d6a1b1 == 0 ~ 0)
  m6a1b2 = case_when(d6a1b2 == 1 ~ 2600, d6a1b2 == 0 ~ 0)
  m6a2b1 = case_when(d6a2b1 == 1 ~ 1000, d6a2b1 == 0 ~ 0)
  m6a2b2 = case_when(d6a2b2 == 1 ~ 1000, d6a2b2 == 0 ~ 0)
  m6a3b1 = case_when(d6a1b1 == 1 ~ 3000, d6a1b1 == 0 ~ 0)
  m6a3b2 = case_when(d6a1b2 == 1 ~ 3000, d6a1b2 == 0 ~ 0)
  # Compute our overall metric
  metric = m3 + m5 + m8 + m6a1b1+m6a1b2+m6a2b1+m6a2b2+m6a3b1+m6a3b2
  return(metric)
}
```

### Step 7 – Define `get_walkability()`

SubFunction: perf_metric_walkability Inputs: d1 = Location Output:
metric (evaluation of the walkability score per architecture) Define the
performance metric function for Transportation Emissions The larger the
value, the larger the benefit.

``` r
get_walkability <- function(d1){
  # Define the min/max of the utility scale
  w_min = 1;
  w_max = 5;
  # Recode decision #5 for emissions metric
  m1 = case_when(d1 == 0 ~ 4, # Monuments/Parks
                 d1 == 1 ~ 2, # Restaurants
                 d1 == 2 ~ 2, # Cultural Trail
                 TRUE ~ 0) # Else condition
  # Calculate the overall metric
  metric = (m1)
  return(metric)
}
```

### Step 8 – Define `get_traveltimes()`

SubFunction: perf_metric_traveltimes Inputs: d5 = Street Traffic d7 =
Speed Limit Output: metric (evaluation of the travel times score per
architecture) Define the performance metric function for Transportation
Emissions The larger the value, the larger the benefit.

``` r
get_traveltimes <- function(d5, d7){
  # Define the min/max of the utility scale
  w_min = 0;
  w_max = 20;
  # Recode decision #5 for emissions metric
  m5 = case_when(d5 == 0 ~ 0.3, # One-Way; High Travel; Slow
                 d5 == 1 ~ 0.8, # Two-Way; Low Travel; Fast
                 d5 == 2 ~ 0.3, # Alternating Lane; Slow
                 TRUE ~ 0) # Else condition
```

### Step 9 – Create `m7`

Recode decision \#7 for emissions metric.

``` r
  m7 = case_when(d7 == 0 ~ 0.9, # 10 MPH
                 d7 == 1 ~ 0.7, # 15 MPH
                 d7 == 2 ~ 0.5, # 20 MPH
                 d7 == 3 ~ 0.3, # 25 MPH
                 TRUE ~ 0) # Else condition
  # Calculate the overall metric
  metric = (m5 * m7) * (w_max - w_min) + w_min;
  return(metric)
}
```

### Step 10 – Define `get_emissions()`

SubFunction: perf_metric_emissions Inputs: d4 = Space Allocation d5 =
Street Traffic d7 = Speed Limit Output: metric (evaluation of the
emissions score per architecture) Define the performance metric function
for Transportation Emissions The larger the value, the larger the
benefit.

``` r
get_emissions <- function(d4, d5, d7){
  # Define the min/max of the utility scale
  w_min = 0;
  w_max = 100;
  # Recode decision #4 for emissions metric
  m4 = case_when(d4 == 0 ~ 1.0, # 60% MovingF, 40% SpaceF
                 d4 == 1 ~ 0.5, # 40% MovingF, 60% SpaceF
                 TRUE ~ 0) # Else condition
  # Recode decision #5 for emissions metric
  m5 = case_when(d5 == 0 ~ 0.3, # One-Way; High Travel; Slow
                 d5 == 1 ~ 0.8, # Two-Way; Low Travel; Fast
                 d5 == 2 ~ 0.3, # Alternating Lane; Slow
                 TRUE ~ 0) # Else condition
  # Recode decision #7 for emissions metric
  m7 = case_when(d7 == 0 ~ 0.9, # 10 MPH
                 d7 == 1 ~ 0.7, # 15 MPH
                 d7 == 2 ~ 0.5, # 20 MPH
                 d7 == 3 ~ 0.3, # 25 MPH
```

### Step 11 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
                 TRUE ~ 0) # Else condition
  # Calculate the overall metric
  metric = (m4 * m5 * m7) * (w_max - w_min) + w_min;
  return(metric)
}
```

### Step 12 – Practice the Pipe

mutate() method \####################. Use the `%>%` operator to pass
each result to the next tidyverse verb.

``` r
sample = sample %>%
  mutate(duration = get_duration(d3 = d3, d4 = d4, d8 = d8, d9 = d9)) %>%
  mutate(cost = get_cost(
    d3 = d3, d5 = d5, d8 = d8, 
    d6a1b1 = d6_a1_b1, d6a1b2 = d6_a1_b2, d6a2b1 = d6_a2_b1,
    d6a2b2 = d6_a2_b2, d6a3b1 = d6_a3_b1, d6a3b2 = d6_a3_b2 )) %>%
  mutate(
    walk = get_walkability(d1 = d1),
    travel = get_traveltimes(d5 = d5, d7 = d7),
    emis = get_emissions(d4 = d4, d5 = d5, d7 = d7)
  )
```

### Step 13 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sample = sample %>%
  mutate(d6 = paste0(d6_a1_b1, d6_a1_b2, d6_a2_b1, d6_a2_b2, d6_a3_b1, d6_a3_b2))
```

### Step 14 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sample %>% glimpse()
# OR
```

### Step 15 – Define `evaluate()`

unlist(sample\[1, 1:16\]). Create the helper function `evaluate()` so
you can reuse it throughout the workshop.

``` r
evaluate = function(int){
  # Testing value
  # int = unlist(e[1,1:16])
```

### Step 16 – Create `d1`

Take a vector ‘int’ of integers and get decision values.

``` r
  d1 = int[1]
  d2_1 = int[2]; d2_2 = int[3]; d2_3 = int[4]
  d3 = int[5]; d4 = int[6]; d5 = int[7]
  d6_a1_b1 = int[8]
  d6_a1_b2 = int[9]
  d6_a2_b1 = int[10]
  d6_a2_b2 = int[11]
  d6_a3_b1 = int[12]
  d6_a3_b2 = int[13]
  d7 = int[14]; d8 = int[15]; d9 = int[16]
```

### Step 17 – Create `duration`

Get metrics. Create the object `duration` so you can reuse it in later
steps.

``` r
  duration = get_duration(d3 = d3, d4 = d4, d8 = d8, d9 = d9)
  cost = get_cost(
    d3 = d3, d5 = d5, d8 = d8, 
    d6a1b1 = d6_a1_b1, d6a1b2 = d6_a1_b2, d6a2b1 = d6_a2_b1,
    d6a2b2 = d6_a2_b2, d6a3b1 = d6_a3_b1, d6a3b2 = d6_a3_b2 )
```

### Step 18 – Create `walk`

Create the object `walk` so you can reuse it in later steps.

``` r
  walk = get_walkability(d1 = d1)
  travel = get_traveltimes(d5 = d5, d7 = d7)
  emis = get_emissions(d4 = d4, d5 = d5, d7 = d7)
```

### Step 19 – Create `output`

Turn into a matrix.

``` r
  output = matrix(
    data = c(duration, cost, walk, travel, emis), 
    byrow = TRUE, ncol = 5)
  # Set column names in matrix
  colnames(output) = c("duration", "cost", "walk", "travel", "emis")
```

### Step 20 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
  return(output)
}
```

### Step 21 – Run the Code Block

Let’s try and evaluate a few.

``` r
evaluate(int = e[150,1:16])
```

### Step 22 – Run the Code Block

HELPER FUNCTIONS \########################### Load functions.

``` r
source("workshops/00_entropy_utilities.R")
# Load pareto_rank() function
source("workshops/00_pareto_rank_utilities.R")
# Load sensitivity
source("workshops/00_sensitivity_connectivity_utilities.R")
```

### Step 23 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sample %>%
  glimpse()
```

### Step 24 – Practice the Pipe

Is that architecture good?

``` r
sample = sample %>% 
  mutate(good = cost > median(cost))
```

### Step 25 – Practice the Pipe

Does that architecture have a certain feature?

``` r
sample = sample %>%
  # If location = businesses ^& traffic = 2-way
  mutate(feature = case_when(d1 == 1 & d5 == 1 ~ TRUE, TRUE ~ FALSE))
```

### Step 26 – Run the Code Block

Information gain! Execute the block and pay attention to the output it
produces.

``` r
ig(good = sample$good, feature = sample$feature)
```

### Step 27 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.

``` r
ggplot() +
  geom_density(
    data = sample, 
    mapping = aes(x = cost, fill = feature),
    alpha = 0.5)
```

### Step 28 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.

``` r
ggplot() +
  geom_jitter(
    data = sample, 
    mapping = aes(x = walk, y = cost, 
                  color = feature),
    alpha = 0.5
  ) + facet_wrap(~feature)
```

### Step 29 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.

``` r
ggplot() +
  geom_jitter(
    data = sample, mapping = aes(
      x = duration, y = cost,
      color = feature),
    alpha = 0.5
  ) +
  facet_wrap(~feature)
```

### Step 30 – Practice the Pipe

TRANSFORM DIFFICULT VARIABLES \########################################.

``` r
e = e %>% 
  mutate(d6 = paste0(d6_a1_b1, d6_a1_b2, d6_a2_b1, 
                     d6_a2_b2, d6_a3_b1, d6_a3_b2 ))
# View a few
e %>% select(d6) %>% sample_n(size = 5)
```

### Step 31 – Run the Code Block

Allows you to do sensitivity analysis on tricky metrics, by turning them
into, essentially, a standard form problem with many discrete
categories.

``` r
sensitivity(data = e, decision_i = 'd6', metric = 'cost')
connectivity(data = e, decision_i = 'd6', decisions = c("d1","d3", "d6"), metric = "cost")
```

## Learning Checks

**Learning Check 1.** What role does the helper `get_duration()` defined
in Step 5 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 2.** What role does the helper `get_cost()` defined in
Step 6 play in this workflow?

<details>
<summary>
Show answer
</summary>

It encapsulates the conditional cost schedule so you can reuse it
whenever you mutate architecture rows.

</details>

**Learning Check 3.** What role does the helper `get_walkability()`
defined in Step 7 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 4.** What role does the helper `get_traveltimes()`
defined in Step 8 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>
