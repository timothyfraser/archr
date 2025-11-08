---
title: "[52] Feature experimentation sandbox Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `52_optimization_feature_experiments.R` and unpacks the workshop on feature experimentation sandbox. You will see how it advances the Optimization sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `52_optimization_feature_experiments.R` within the Optimization module.
- Connect the topic "Feature experimentation sandbox" to systems architecting decisions.
- Load packages with `library()` and verify they attach without warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or architecture tables.
- Define custom functions to package repeatable logic.

## Application

### Step 1 – Practice the Pipe

Enumerate Architectures This perfectly replicates the example from Slides in Class.


``` r
data = enumerate_sf(n = c(2, 3, 2)) %>%
  # Add metrics
  mutate(m1 = c(33,73, 40, 80, 30, 70, 66, 146, 80, 160, 60, 140),
         m2 = c(0.8910, 0.9801, 0.8991, 0.9890, 0.4500, 0.4950, 0.9899, 0.9998, 0.9900, 0.9999, 0.7425, 0.7499)) %>%
  mutate(d1 = d1 + 1, d2 = d2 + 1, d3 = d3+1) %>%
  select(d1 = d3, d2 = d2, d3 = d1, m1, m2)
```

### Step 2 – Define `me()`

Calculate main effect. Create the helper function `me()` so you can reuse it throughout the workshop.


``` r
me = function(data, decision = "d2", value = 1, metric = "m1"){
  # Testing values
  # decision = "d2"; value = 1; metric = "m1"
  data2 = data %>%
    # Grab any columns with these character strings as their column names
    select(any_of(c(alt = decision, metric = metric))) %>%
    # Add a decision column
    mutate(decision = decision) %>%
    # Reorder them
    select(decision, alt, metric)
  # Calculate effect
  data3 = data2 %>%
    summarize(
      xhat = mean(metric[alt == value], na.rm = TRUE),
      x = mean(metric[alt != value], na.rm = TRUE),
      dbar = xhat - x  
    )
  output = data3$dbar
```

### Step 3 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
  return(output)
}
```

### Step 4 – Define `sensitivity()`

Beginning attempt at a sensitivity.


``` r
sensitivity = function(data, decision = "d2", metric = "m1"){
  # Testing Values
  # decision = "d2"; metric = "m1"
  # Get values for your ith decision
  values = unlist(unique(data[, decision]))
```

### Step 5 – Create `holder`

Create a table to hold my results.


``` r
  holder = tibble(values = values, me = NA_real_)
  for(i in 1:length(values)){
    holder$me[i] = me(data, decision = decision, value = values[i], metric = metric)
  }
```

### Step 6 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
  s = holder %>%
    summarize(stat = mean(abs(me)))
```

### Step 7 – Create `output`

Create the object `output` so you can reuse it in later steps.


``` r
  output = s$stat
  return(output)    
}
```

### Step 8 – Define `me_ij()`

Create the helper function `me_ij()` so you can reuse it throughout the workshop.


``` r
me_ij = function(data, decision_i, value_i, decision_j, value_j, metric = "m1", notj = FALSE){
  #Testing values
  # decision_i = "d3"; value_i = 1
  # decision_j = "d2"; value_j = 1
  # metric = "m1"; notj = TRUE
```

### Step 9 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
  data1 = data %>%
    select(any_of(c(di = decision_i, dj = decision_j, m = metric)))
```

### Step 10 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
  if(notj == TRUE){ 
    # given that dj != j
    data1 = data1 %>% filter(dj != value_j)   
  }else if(notj == FALSE){
    # given that dj == j
    data1 = data1 %>% filter(dj == value_j)  
  }
```

### Step 11 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
  output = data1 %>%
    # Reclassify decision i as does it equal value i or not
    mutate(di = di == value_i) %>% 
    # Get mean when di == i vs. when di != i
    summarize(xhat = mean(m[di == TRUE]),
              x = mean(m[di == FALSE]),
              diff = xhat - x) %>%
    # Return the difference
    with(diff)
```

### Step 12 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
  return(output)
}
```

### Step 13 – Define `sensitivity_ij()`

Create the helper function `sensitivity_ij()` so you can reuse it throughout the workshop.


``` r
sensitivity_ij = function(data, decision_i, decision_j, value_j, metric, notj = FALSE){
  #decision_i = "d3"; decision_j = "d2"; value_j = 1; metric = "m1"; notj = FALSE
```

### Step 14 – Practice the Pipe

Get all values of decision i.


``` r
  data %>%
    select(any_of(c(di = decision_i))) %>%
    distinct() %>%
    # For each unique value of decision i
    group_by(di) %>% 
    # Get the interaction effect with the constant same value j of decision j
    summarize(
      stat = me_ij(data = data, decision_i = decision_i, value_i = di, 
                   decision_j = decision_j, value_j = value_j, 
                   metric = metric, notj = notj),
      .groups = "drop"
    ) %>%
    # Get absolute value
    mutate(stat = abs(stat)) %>%
    # Take mean
    summarize(stat = mean(stat, na.rm = TRUE)) %>%
    # return statistic
    with(stat)
}
```

### Step 15 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
me_ij(data, decision_i = "d3", value_i = 1, decision_j = "d2", value_j = 1, notj = FALSE, metric = "m1")
```

### Step 16 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
sensitivity_ij(data, decision_i = "d3", decision_j = "d2", value_j = 1, metric = "m1", notj = FALSE)
sensitivity_ij(data, decision_i = "d3", decision_j = "d2", value_j = 2, metric = "m1", notj = FALSE)
sensitivity_ij(data, decision_i = "d3", decision_j = "d2", value_j = 1, metric = "m1", notj = TRUE)
sensitivity_ij(data, decision_i = "d3", decision_j = "d2", value_j = 2, metric = "m1", notj = TRUE)
```

### Step 17 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
sensitivity_ij(data, decision_i = "d3", decision_j = "d2", 
               value_j = 1, metric = "m1", notj = FALSE)
sensitivity_ij(data, decision_i = "d3", decision_j = "d2", 
               value_j = 1, metric = "m1", notj = TRUE)
sensitivity_ij(data, decision_i = "d3", decision_j = "d2", 
               value_j = 2, metric = "m1", notj = FALSE)
sensitivity_ij(data, decision_i = "d3", decision_j = "d2", 
               value_j = 2, metric = "m1", notj = TRUE)
sensitivity_ij(data, decision_i = "d3", decision_j = "d2", 
               value_j = 3, metric = "m1", notj = FALSE)
sensitivity_ij(data, decision_i = "d3", decision_j = "d2", 
               value_j = 3, metric = "m1", notj = TRUE)
```

### Step 18 – Define `connectivity_ij()`

Create the helper function `connectivity_ij()` so you can reuse it throughout the workshop.


``` r
connectivity_ij = function(data, decision_i, decision_j = "d2", metric = "m1"){
  # decision_i = "d3"; decision_j = "d2"; metric = "m1"
  data1 = data %>%
    select(any_of(c(dj = decision_j))) %>%
    distinct()  %>%
    # Get every combo of these with TRUE and FALSE
    expand_grid(notj = c(TRUE, FALSE)) %>%
    # For each set
    group_by(dj, notj) %>%
    # Get the sensitivity of decision i given decision j == or != value j
    summarize(
      stat = sensitivity_ij(data, decision_i = decision_i, decision_j = decision_j, value_j = dj, metric = metric, notj = notj),
      .groups = "drop") %>%
    ungroup()
```

### Step 19 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
  output = data1 %>%
    # For each...
    group_by(dj) %>%
    # Get the absolute difference
    summarize(stat = abs(diff(stat)),.groups = "drop") %>%
    # Now get the mean absolute difference
    summarize(stat = mean(stat)) %>%
    # Return the statistic
    with(stat)
```

### Step 20 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
  return(output)
}
```

### Step 21 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
connectivity_ij(data, decision_i = "d3", decision_j = "d2", metric = "m1" )
```

### Step 22 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
connectivity_ij(data, decision_i = "d3", decision_j = "d1", metric = "m1" )
```

### Step 23 – Define `connectivity()`

Get total connectivity of decision i.


``` r
connectivity = function(data, decision_i = "d3", decisions = c("d1", "d2", "d3"), metric = "m1"){
```

### Step 24 – Create `other_decisions`

Get the other decisions.


``` r
  other_decisions = decisions[!decisions %in% decision_i]
  # Get a grid of all di-dj pairs
  output = expand_grid(
    di = decision_i,
    dj = other_decisions
  ) %>%
    # For each di-dj pair (specifically, for each dj)
    group_by(di,dj) %>%
    # Get the connectivity between decisions di and dj
    summarize(
      stat = connectivity_ij(data = data, decision_i = di, decision_j = dj, metric = metric),
      .groups = "drop"
    ) %>%
    # Now, take the mean of these statistics
    # You have one for each decision j,
    # as in each decision that is not i
    summarize(stat = sum(stat) / (n() - 1) ) %>%
    # So, this is equivalent to calculating 1 / (n_decisions - 1 ) * sum(connectivity)
    # Because the number of decisions - 1 = number of decisions that are not decision i
    with(stat)
```

### Step 25 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
  return(output)
}
```

### Step 26 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
expand_grid(
  decision = c("d1","d2","d3"),
  metric = c("m1","m2")
) %>%
  mutate(
    c = connectivity(data = data, decision_i = decision, decisions = c("d1","d2","d3"), metric = metric)
   # s = sensitivity(data = data, decision = decision, metric = metric)
  )
```

### Step 27 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
connectivity(data, decision_i = "d3", decisions = c("d1","d2","d3"), metric = "m1")
connectivity(data, decision_i = "d2", decisions = c("d1","d2","d3"), metric = "m1")
connectivity(data, decision_i = "d1", decisions = c("d1","d2","d3"), metric = "m1")
```

### Step 28 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
connectivity(data, decision_i = "d3", decisions = c("d1","d2","d3"), metric = "m2")
connectivity(data, decision_i = "d2", decisions = c("d1","d2","d3"), metric = "m2")
connectivity(data, decision_i = "d1", decisions = c("d1","d2","d3"), metric = "m2")
```

### Step 29 – Clear Objects

Remove objects from the environment to prevent name clashes.


``` r
rm(list = ls())
```

### Step 30 – Define `ie_ij()`

We need a new sensitivity function that will get a sensitivity score matching this formulation: S(D_i, M|D_j = k) (see slides) Get interaction effect.


``` r
ie_ij = function(data, decision_i,  value_i, decision_j, value_j){
  # Testing values
  #decision_i = "d3"; decision_j = "d1"; value_i = 0; value_j = 0; metric = "m1"
```

### Step 31 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
  data2 = data %>%
    # Grab any columns with these character strings as their column names
    select(any_of(c(alt_i = decision_i, alt_j = decision_j, metric = metric))) %>%
    # Add a decision column
    mutate(decision_i = decision_i, decision_j = decision_j)  %>%
    # Reorder them
    select(decision_i, alt_i, decision_j, alt_j, metric)
  # Calculate effect
  data3 = data2 %>%
    summarize(
      xhat = mean(metric[alt_i == value_i & alt_j == value_j], na.rm = TRUE),
      x = mean(metric[alt_i == value_i & alt_j != value_j], na.rm = TRUE),
      dbar = xhat - x  
    )
  output = data3$dbar  
  return(output)  
}
```

### Step 32 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
ie_ij(data, decision_i = "d3",value_i = 0, decision_j = "d2",value_j = 0)
ie_ij(data, decision_i = "d3",value_i = 0, decision_j = "d2",value_j = 0)
```

### Step 33 – Load Packages

0.1 PACKAGES ##########################. Attach dplyr to make its functions available.


``` r
library(dplyr)
library(tidyr)
library(archr)
library(GA)
library(rmoo)
```

### Step 34 – Create `a1`

Make our architectural matrix 3 elements ordered; pick 2.


``` r
a1 = enumerate_permutation(n = 3, k = 2, .did = 1)
```

### Step 35 – Define `evaluate()`

Create the helper function `evaluate()` so you can reuse it throughout the workshop.


``` r
evaluate = function(t = 1000, d1_1, d1_2){
  # Testing values
  #t = 1000
  #d1_1 = a$d1_1; d1_2 = a$d1_2
```

### Step 36 – Create `c1_1`

Get cost. Create the object `c1_1` so you can reuse it in later steps.


``` r
  c1_1 = case_when(d1_1 == 0 ~ 5, d1_1 == 1 ~ 10, d1_1 == 2 ~ 15)
  c1_2 = case_when(d1_2 == 0 ~ 2, d1_2 == 1 ~ 3, d1_2 == 2 ~ 5)
  cost = c1_1 + c1_2
```

### Step 37 – Create `b1_1`

Get benefit. Create the object `b1_1` so you can reuse it in later steps.


``` r
  b1_1 = case_when(d1_1 == 0 ~ 1000, d1_1 == 1 ~ 300, d1_1 == 2 ~ 2000)
  b1_2 = case_when(d1_2 == 0 ~ 4000, d1_2 == 1 ~ 2000, d1_2 == 2 ~ 500)
  benefit = b1_1 + b1_2
```

### Step 38 – Create `lambda1_1`

Get joint reliability. Create the object `lambda1_1` so you can reuse it in later steps.


``` r
  lambda1_1 = case_when(
    d1_1 == 0 ~ 1/200,
    d1_1 == 1 ~ 1/1000,
    d1_1 == 2 ~ 1/1500)
  lambda1_2 = case_when(
    d1_2 == 0 ~ 1/1500,
    d1_2 == 1 ~ 1/2000,
    d1_2 == 2 ~ 1/3000
  )
  reliability1_1 = 1 - pexp(t, rate = lambda1_1)
  reliability1_2 = 1 - pexp(t, rate = lambda1_2)
  reliability = reliability1_1 * reliability1_2
```

### Step 39 – Create `m`

Create the object `m` so you can reuse it in later steps.


``` r
  m = matrix(c(cost, benefit, reliability), ncol = 3)
  return(m)
}
```

### Step 40 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
evaluate(t = 1000, d1_1 = 0, d1_2 = 1)
```

### Step 41 – Define `int2bin()`

Optional - convert from int to bin Let's write a int2bin() function for a permutation case.


``` r
int2bin = function(int){
  # Convert each item to a length 2 binary vector 
  bin1 = decimal2binary(x = int[1], length = 2) # max int is 2, so "10" in binary (length 2)
  bin2 = decimal2binary(x = int[2], length = 2) # max int is 2, so "10" in binary (length 2)
  c(bin1, bin2) # return the binary vector
}
a1 %>% slice(1:2)
int2bin(int = c(2,1))
```

### Step 42 – Define `bin2int()`

Let's write a bin2int() function for a permutation case.


``` r
bin2int = function(x){
  # Testing values
  # x = c(1,0,0,1)
  xhat1 = binary2decimal(x = x[1:2])
  xhat2 = binary2decimal(x = x[3:4])
  c(xhat1, xhat2) # return
}
```

### Step 43 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
bin2int(x = c(1,0,0,1))
```

### Step 44 – Define `revise_permutation()`

Let's write a function that will fix improper permutations By identifying pairs have the same rank and randomly replacing one of their values iteratively until the ordering is valid.


``` r
revise_permutation = function(ints = c(1,1), k = 2, vals = c(0,1,2)){
  # As long as there are NOT just k = 2 unique values
  while(length(unique(ints)) != k){
    # Find the impossible values
    ids = c(1:length(ints))
    # Find me the indices of values that are duplicated
    # For the ith value in my decision's architecture...
    for(i in ids){
      # i = 1 # testing value
      # Get the other indices...
      others = ids[!ids %in% i]
      for(j in others){
        # j = 2 # testing value
        # Get the values for those options
        # pick the id i or j at random
        pick = sample(x = c(i,j), size = 1)
        # Give me value picked to be replaced
        value_to_be_replaced = ints[pick]
        # Give me all possible values EXCEPT that one
        replacement_options = vals[ !vals %in% value_to_be_replaced]
        # Randomly sample one to fix it with
        value_replacement = sample(x = replacement_options, size = 1)
        # Overwrite the value for the picked index with the randomly sampled replacement value
        ints[pick] <- value_replacement
      }  
    }
  }
  return(ints)
}
```

### Step 45 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
revise_permutation(ints = c(1,1), k = 2, vals = c(0,1,2))
```

### Step 46 – Define `revise_bit()`

Let's write a revise_bit function.


``` r
revise_bit = function(x){
  # Testing value
  # x = c(1,0,1,0) # here's an impossible permutation - c(2,2), where k = 2 and n = 3
  # x = c(1,0,1,0,0,0) # here's another impossible permutation c(2,2,0), where k = 2 and n = 3
  # Get integer versions
  xhat = bin2int(x)
```

### Step 47 – Create `d1`

Get values for our permutation decisions.


``` r
  d1 = xhat[1:2]
```

### Step 48 – Run the Code Block

REVISE STRUCTURALLY IMPOSSIBLE DECISION VALUES.


``` r
  if(d1[1] == 3){ d1[1] <- sample(x = c(0,1,2), size = 1) }
  if(d1[2] == 3){ d1[2] <- sample(x = c(0,1,2), size = 1) }
```

### Step 49 – Create `d1`

REVISE ORDER Check how many unique values there are. There should only ever be k = 2. eg. (0,1) (1,0), (2,1), etc. k = 2; n = 2; so vals = c(0,1,2) Randomly fix the ordering of pairs of values until it works.


``` r
  d1 = revise_permutation(ints = d1, k = 2, vals = c(0,1,2))
```

### Step 50 – Create `xhat`

Bundle all values back into integer vector.


``` r
  xhat = c(d1)
```

### Step 51 – Create `output`

Convert interger vector BACK into binary ecotr.


``` r
  output = int2bin(xhat)
  return(output)
}
```

### Step 52 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
revise_bit(x = c(1,1,1,0)) # invalid; gets fixed
revise_bit(x = c(1,0,1,0)) # invalid; gets fixed
revise_bit(x = c(1,0,0,1)) # already good; doesn't change
```

### Step 53 – Define `f1()`

Create the helper function `f1()` so you can reuse it throughout the workshop.


``` r
f1 = function(x, nobj = 3, ...){
  # x = c(1,0,0,1)
  # First, let's convert from binary to our integer-formatted architecture
  xhat = bin2int(x)
  # Seconds, let's get metrics 
  metrics = evaluate(t = 1000, d1_1 = xhat[1], d1_2 = xhat[2])
  # Third, let's return metrics
  return(metrics)
}
```

### Step 54 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
f1(x = c(0,0,0,0))
f1(x = c(1,0,0,1))
```

### Step 55 – Define `bin2int()`

Create the helper function `bin2int()` so you can reuse it throughout the workshop.


``` r
bin2int = function(x){
  xhat1 = binary2decimal(x = x[1]) # convert first integer's set of bits
  xhat2 = binary2decimal(x = x[2]) # convert next integer's set of bits
  xhat3 = binary2decimal(x = x[3:4]) # convert next integer's set of bits
  xhat4 = binary2decimal(x = x[5:6]) # convert next integer's set of bits
```

### Step 56 – Create `xhat`

Create the object `xhat` so you can reuse it in later steps.


``` r
  xhat = c(xhat1, xhat2, xhat3,xhat4) # bind together
  return(xhat) # View it!
}
```

### Step 57 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
c(0,1,0,1,1,1) %>% bin2int()
```

### Step 58 – Define `constrain()`

Create the helper function `constrain()` so you can reuse it throughout the workshop.


``` r
constrain = function(xhat){
  # Structural constraints
  # If d4 == 3, then d4 is a problem. 
  constraint1 = xhat[4] == 3
  # constraint1 = !xhat[4] %in% c(0,1,2) # could also write it this way.
```

### Step 59 – Create `constraint2`

Dependence constraints If d1 = 0 and then d2 = 1, then d2 is a problem.


``` r
  constraint2 = xhat[1] == 0 & xhat[2] == 1
  # If d2 = 0 and then d3 = 2, then d3 is a problem.
  constraint3 = xhat[2] == 0 & xhat[3] == 2
```

### Step 60 – Create `flag`

If any of the constraints get flagged, mark as TRUE.


``` r
  flag = constraint1 | constraint2 | constraint3
  return(flag)
}
```

### Step 61 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
c(0,1,0,1,1,1) %>% bin2int() %>% constrain()
```

### Step 62 – Define `evaluate()`

Evaluate this integer string.


``` r
evaluate = function(xhat){
  #xhat = c(1,0,1)
  # Make metrics
  m1 = sum(xhat)
  m2 = prod(cos(xhat)^2)
  m3 = sum(xhat * c(0.25, 0.5, pi^-2, pi^3))
  # Bundle metrics
  metrics = c(m1,m2,m3)
```

### Step 63 – Create `m`

Create the object `m` so you can reuse it in later steps.


``` r
  m = matrix(data = metrics, ncol = length(metrics))
```

### Step 64 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
  return(m)
}
```

### Step 65 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
c(0,1,0,1,1,1) %>% bin2int() %>% evaluate()
```

### Step 66 – Define `f0()`

Create the helper function `f0()` so you can reuse it throughout the workshop.


``` r
f0 = function(x, nobj = 3, ...){
  # First, let's convert from binary to our integer-formatted architecture
  # x = c(0,1,0,0)
  xhat = bin2int(x)
  metrics = evaluate(xhat)
  return(metrics)
}
```

### Step 67 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
f0(x = c(1,1,1,1,1,0))
```

### Step 68 – Define `revise_bit()`

Create the helper function `revise_bit()` so you can reuse it throughout the workshop.


``` r
revise_bit = function(x){
  #x = c(0,1,0,1,1,1)
  # 1. Transform bits into integer alternatives
  xhat = bin2int(x)
```

### Step 69 – Create `d1`

Get decisions. Create the object `d1` so you can reuse it in later steps.


``` r
  d1 = xhat[1]
  d2 = xhat[2]
  d3 = xhat[3]
  d4 = xhat[4]
```

### Step 70 – Create `constraint1`

Structural Constraints Constraint 1: d4 != 3.


``` r
  constraint1 = d4 == 3
  # Dependence Constraints
  # Constraint 2: If d1 is 0, then d2 != 1. 
  constraint2 = d1 == 0 & d2 == 1
  constraint3 = d2 == 0 & d3 == 2
```

### Step 71 – Run the Code Block

Structural Constraints Constraint 1: d4 != 3. Resample from available options for d4 if so: [0,1,2].


``` r
  if(constraint1 == TRUE){  d4 = sample(x = c(0,1,2), size = 1) }
```

### Step 72 – Run the Code Block

Dependence Constraints Constraint 2: If d1 is 0, then d2 != 1. Resample from available options for d2: [0].


``` r
  if(constraint2 == TRUE){  d2 = sample(x = c(0), size = 1)   }
```

### Step 73 – Run the Code Block

Constraint 3: If d2 is 0, then d3 != 2. Resample from available options for d3: [0,1,3].


``` r
  if(constraint3 == TRUE){  d3 = sample(x = c(0,1,3), size = 1)  }
```

### Step 74 – Create `xnew1`

4. convert new integer vector back into binary vector.


``` r
  xnew1 = decimal2binary(x = d1, length = 1)
  xnew2 = decimal2binary(x = d2, length = 1)
  xnew3 = decimal2binary(x = d3, length = 2)
  xnew4 = decimal2binary(x = d4, length = 2)
  # Bundle as a vector
  xnew = c(xnew1, xnew2, xnew3, xnew4)
```

### Step 75 – Run the Code Block

Return output. Execute the block and pay attention to the output it produces.


``` r
  return(xnew)
}
c(0,1,0,1,1,1) %>% revise_bit()
```

### Step 76 – Create `object`

You may have to re-run this a few times to get good values.


``` r
object = nsga3(
  fitness = f0, type = "binary", 
  lower = c(0,0,0,0,0,0), upper = c(1,1,1,1,1,1),
  nBits = 6, monitor = FALSE, n_partitions = 10) # Not totally clear on n_partitions, but it works.
```

### Step 77 – Run the Code Block

Get 2 architectures from the population.


``` r
object@population[c(1,3), ]
# You may have to re-run this a few times to get good values
crossover = rmoo::nsga_spCrossover(object = object, parents = c(1,3))
```

### Step 78 – Run the Code Block

Clear the fitness scores.


``` r
crossover$fitness = matrix(NA, ncol = 3, nrow = nrow(crossover$children))
```

### Step 79 – Loop Through Values

For each crossover child, revise bits and re-evaluate the fitness.


``` r
for(i in 1:nrow(crossover$children)){
  # Check validity and if necessary, revise the bit to be valid
  crossover$children[i, ] = crossover$children[i, ] %>% revise_bit()
  # Convert that child to integer and evaluate it
  # crossover$fitness[i, ] = crossover$children[i, ] %>% bin2int() %>% evaluate()
}
```

### Step 80 – Run the Code Block

Voila! A valid set of new chromosomes and their fitness scores.


``` r
crossover
```

### Step 81 – Run the Code Block

Find the index values where.


``` r
object@population
object@population[1:2,]
object@fitness[1:2,]
```

### Step 82 – Define `custom_crossover()`

Let's formalize it as a custom crossover function.


``` r
custom_crossover = function(object, parents){
```

### Step 83 – Create `crossover`

Perform crossover using rmoo's nsga algorithms.


``` r
  crossover = rmoo:::nsgabin_spCrossover(object = object, parents = parents)
```

### Step 84 – Loop Through Values

For each crossover child, revise bits and re-evaluate the fitness.


``` r
  for(i in 1:nrow(crossover$children)){
    # Check validity and if necessary, revise the bit to be valid
    crossover$children[i, ] = crossover$children[i, ] %>% revise_bit()
    # Convert that child to integer and evaluate it
    # crossover$fitness[i, ] = crossover$children[i, ] %>% bin2int() %>% evaluate()
```

### Step 85 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
  }
```

### Step 86 – Run the Code Block

Voila! A valid set of new chromosomes and their fitness scores.


``` r
  return(crossover)
```

### Step 87 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
}
```

### Step 88 – Create `object`

Create the object `object` so you can reuse it in later steps.


``` r
object = nsga3(
  fitness = f0, type = "binary", crossover = custom_crossover,
  lower = c(0,0,0,0,0,0), upper = c(1,1,1,1,1,1),
  nBits = 6, monitor = FALSE, n_partitions = 10) # Not totally clear on n_partitions, but it works.
```

### Step 89 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
object@fitness[1:3,]
```

### Step 90 – Create `o`

optimize ######################################. Create the object `o` so you can reuse it in later steps.


``` r
o = rmoo(
  fitness = f0, type = "binary", algorithm = "NSGA-III",
  # Settings
  monitor = TRUE, summary = TRUE,
  nObj = 3, nBits = 6, popSize = 50, maxiter = 100, 
  # Add custom functions
  crossover = custom_crossover
)
```

### Step 91 – Create `object`

Create the object `object` so you can reuse it in later steps.


``` r
object = nsga3(
  fitness = f1, type = "binary", 
  lower = c(0,0,0,0), upper = c(1,1,1,1),
  nBits = 4, monitor = FALSE, n_partitions = 1) # Not totally clear on n_partitions, but it works.
```

### Step 92 – Create `parents1`

As an example, let's get these parents - two rows from our population.


``` r
parents1 = object@population[2:3, ]
rmoo::nsga_spCrossover(object = object, parents = parents1)
# Try it a few times - it should work eventually.
```

### Step 93 – Define `custom_crossover()`

Create the helper function `custom_crossover()` so you can reuse it throughout the workshop.


``` r
custom_crossover = function(object, parents){
  # Perform crossover using rmoo's nsga algorithms
  crossover = rmoo:::nsgabin_spCrossover(object = object, parents = parents)
  # 
  crossover = revise_bit(crossover)
```

### Step 94 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
  return(crossover)
}
```

### Step 95 – Define `custom_mutate()`

Create the helper function `custom_mutate()` so you can reuse it throughout the workshop.


``` r
custom_mutate = function(object, parent){
  # Generate a mutation if using rmoo's ngsa algorithms
  mutation = nsgabin_raMutation(object = object, parent = parent)
  # Check if the mutation needs revision.
  mutation = revise_bit(mutation)
  # Return mutation
  return(mutation)
}
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "52_optimization_feature_experiments.R"))` from the Console or press the Source button while the script is active.

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
