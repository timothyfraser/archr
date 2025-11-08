This tutorial complements `51_optimization_advanced_search.R` and
unpacks the workshop on advanced search techniques. You will see how it
advances the Optimization sequence while building confidence with base R
and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working
  directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines
  interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from
  earlier workshops.

## Skills

- Navigate the script `51_optimization_advanced_search.R` within the
  Optimization module.
- Connect the topic “Advanced search techniques” to systems architecting
  decisions.
- Load packages with `library()` and verify they attach without
  warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or
  architecture tables.
- Define custom functions to package repeatable logic.

## Process Overview

``` mermaid
flowchart LR
    A[Load Packages] --> B[Run the Code Block]
    B[Run the Code Block] --> C[Create d1]
    C[Create d1] --> D[Run the Code Block (Step 22)]
```

## Application

### Step 1 – Load Packages

Attach dplyr to make its functions available.

``` r
library(dplyr)
library(tidyr)
library(archr)
library(GA)
library(rmoo)
```

### Step 2 – Create `a1`

Make our architectural matrix 3 elements ordered; pick 2.

``` r
a1 = enumerate_permutation(n = 3, k = 2, .did = 1)
```

### Step 3 – Define `evaluate()`

1.1 METRICS \#################################. Create the helper
function `evaluate()` so you can reuse it throughout the workshop.

``` r
evaluate = function(t = 1000, d1_1, d1_2){
  # Testing values
  #t = 1000
  #d1_1 = a$d1_1; d1_2 = a$d1_2
```

### Step 4 – Create `c1_1`

Get cost. Create the object `c1_1` so you can reuse it in later steps.

``` r
  c1_1 = case_when(d1_1 == 0 ~ 5, d1_1 == 1 ~ 10, d1_1 == 2 ~ 15)
  c1_2 = case_when(d1_2 == 0 ~ 2, d1_2 == 1 ~ 3, d1_2 == 2 ~ 5)
  cost = c1_1 + c1_2
```

### Step 5 – Create `b1_1`

Get benefit. Create the object `b1_1` so you can reuse it in later
steps.

``` r
  b1_1 = case_when(d1_1 == 0 ~ 1000, d1_1 == 1 ~ 300, d1_1 == 2 ~ 2000)
  b1_2 = case_when(d1_2 == 0 ~ 4000, d1_2 == 1 ~ 2000, d1_2 == 2 ~ 500)
  benefit = b1_1 + b1_2
```

### Step 6 – Create `lambda1_1`

Get joint reliability. Create the object `lambda1_1` so you can reuse it
in later steps.

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

### Step 7 – Create `m`

Create the object `m` so you can reuse it in later steps.

``` r
  m = matrix(c(cost, benefit, reliability), ncol = 3)
  return(m)
}
```

### Step 8 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
evaluate(t = 1000, d1_1 = 0, d1_2 = 1)
```

### Step 9 – Define `int2bin()`

Optional - convert from int to bin Let’s write a int2bin() function for
a permutation case.

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

### Step 10 – Define `bin2int()`

Let’s write a bin2int() function for a permutation case.

``` r
bin2int = function(x){
  # Testing values
  # x = c(1,0,0,1)
  xhat1 = binary2decimal(x = x[1:2])
  xhat2 = binary2decimal(x = x[3:4])
  c(xhat1, xhat2) # return
}
```

### Step 11 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
bin2int(x = c(1,0,0,1))
```

### Step 12 – Define `revise_permutation()`

Let’s write a function that will fix improper permutations By
identifying pairs have the same rank and randomly replacing one of their
values iteratively until the ordering is valid.

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

### Step 13 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
enumerate_permutation(n = 3, k = 2)
revise_permutation(ints = c(1,1), k = 2, vals = c(0,1,2))
```

### Step 14 – Define `revise_bit()`

Let’s write a revise_bit function.

``` r
revise_bit = function(x){
  # Testing value
  # x = c(1,0,1,0) # here's an impossible permutation - c(2,2), where k = 2 and n = 3
  # x = c(1,0,1,0,0,0) # here's another impossible permutation c(2,2,0), where k = 2 and n = 3
  # Get integer versions
  xhat = bin2int(x)
```

### Step 15 – Create `d1`

Get values for our permutation decisions.

``` r
  d1 = xhat[1:2]
```

### Step 16 – Run the Code Block

REVISE STRUCTURALLY IMPOSSIBLE DECISION VALUES.

``` r
  if(d1[1] == 3){ d1[1] <- sample(x = c(0,1,2), size = 1) }
  if(d1[2] == 3){ d1[2] <- sample(x = c(0,1,2), size = 1) }
```

### Step 17 – Create `d1`

REVISE ORDER Check how many unique values there are. There should only
ever be k = 2. eg. (0,1) (1,0), (2,1), etc. k = 2; n = 2; so vals =
c(0,1,2) Randomly fix the ordering of pairs of values until it works.

``` r
  d1 = revise_permutation(ints = d1, k = 2, vals = c(0,1,2))
```

### Step 18 – Create `xhat`

Bundle all values back into integer vector.

``` r
  xhat = c(d1)
```

### Step 19 – Create `output`

Convert interger vector BACK into binary ecotr.

``` r
  output = int2bin(xhat)
  return(output)
}
```

### Step 20 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
revise_bit(x = c(1,1,1,0)) # invalid; gets fixed
revise_bit(x = c(1,0,1,0)) # invalid; gets fixed
revise_bit(x = c(1,0,0,1)) # already good; doesn't change
```

### Step 21 – Define `f1()`

4.  FITNESS FUNCTION \######################################.

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

### Step 22 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
f1(x = c(0,0,0,0))
f1(x = c(1,0,0,1))
```

## Learning Checks

**Learning Check 1.** What role does the helper `evaluate()` defined in
Step 3 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 2.** What role does the helper `int2bin()` defined in
Step 9 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 3.** What role does the helper `bin2int()` defined in
Step 10 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 4.** What role does the helper `revise_permutation()`
defined in Step 12 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>
