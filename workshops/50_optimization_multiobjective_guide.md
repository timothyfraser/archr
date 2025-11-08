This tutorial complements `50_optimization_multiobjective.R` and unpacks
the workshop on multiobjective optimization tutorial. You will see how
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

- Navigate the script `50_optimization_multiobjective.R` within the
  Optimization module.
- Connect the topic “Multiobjective optimization tutorial” to systems
  architecting decisions.
- Chain tidyverse verbs with `%>%` to explore stakeholder or
  architecture tables.
- Define custom functions to package repeatable logic.

## Process Overview

``` mermaid
flowchart LR
    A[Define bit2int()] --> B[Create xhat]
    B[Create xhat] --> C[Create xnew1]
    C[Create xnew1] --> D[Run the Code Block]
```

## Application

### Step 1 – Define `bit2int()`

Create the helper function `bit2int()` so you can reuse it throughout
the workshop.

``` r
bit2int = function(x){
```

### Step 2 – Create `d1`

Create the object `d1` so you can reuse it in later steps.

``` r
  d1 = binary2decimal(x[1:2])
  d2 = x[3:4] %>% binary2decimal()
  d3 = x[5] %>% binary2decimal()
  d4 = x[6:7] %>% binary2decimal()
  d5 = x[8:9] %>% binary2decimal()
  d6 = x[10:11] %>% binary2decimal()
  d7 = x[12:13] %>% binary2decimal()
  d8 = x[14] %>% binary2decimal()
  d9 = x[15] %>% binary2decimal()
  output = c(d1,d2,d3,d4,d5,d6,d7,d8,d9)
  return(output)
}
```

### Step 3 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
bit2int(c(0,0,1,0,1,1,1,0,0,0,1,1,1,1,1))
```

### Step 4 – Define `revise_bit()`

Create the helper function `revise_bit()` so you can reuse it throughout
the workshop.

``` r
revise_bit = function(x){
  # Testing value
  x = c(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)
```

### Step 5 – Create `xhat`

1.  Transform bits into integer alternatives.

``` r
  xhat = bit2int(x)
```

### Step 6 – Create `d1`

Get decisions. Create the object `d1` so you can reuse it in later
steps.

``` r
  d1 = xhat[1]
  d2 = xhat[2]
  d3 = xhat[3]
  d4 = xhat[4]
  d5 = xhat[5]
  d6 = xhat[6]
  d7 = xhat[7]
  d8 = xhat[8]
  d9 = xhat[9]
```

### Step 7 – Create `constraint1`

Structural Constraints Constraint 1: d1 != 3.

``` r
  constraint1 = d1 == 3
```

### Step 8 – Run the Code Block

Structural Constraints Resample from available options for d1 if so:
\[0,1,2\].

``` r
  if(constraint1 == TRUE){  d1 = sample(x = c(0,1,2), size = 1) }
```

### Step 9 – Create `xnew1`

4.  convert new integer vector back into binary vector.

``` r
  xnew1 = decimal2binary(x = d1, length = 2)
  xnew2 = decimal2binary(x = d2, length = 2)
  xnew3 = decimal2binary(x = d3, length = 1)
  xnew4 = decimal2binary(x = d4, length = 2)
  xnew5 = decimal2binary(x = d5, length = 2)
  xnew6 = decimal2binary(x = d6, length = 2)
  xnew7 = decimal2binary(x = d7, length = 2)
  xnew8 = decimal2binary(x = d8, length = 1)
  xnew9 = decimal2binary(x = d9, length = 1)
```

### Step 10 – Create `xnew`

Bundle as a vector.

``` r
  xnew = c(xnew1, xnew2, xnew3, xnew4, xnew5, xnew6, xnew7, xnew8, xnew9)
```

### Step 11 – Run the Code Block

Return output. Execute the block and pay attention to the output it
produces.

``` r
  return(xnew)
}
```

### Step 12 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
bit2int()
c(0,0,1,0,1,1,1,0,0,0,1,1,1,1,1) %>%
  revise_bit()
```

## Learning Checks

**Learning Check 1.** What role does the helper `bit2int()` defined in
Step 1 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 2.** What role does the helper `revise_bit()` defined
in Step 4 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 3.** After Step 2, what does `d1` capture?

<details>
<summary>
Show answer
</summary>

It creates `d1` that returns the assembled object, and threads the
result through a dplyr pipeline. Create the object `d1` so you can reuse
it in later steps.

</details>

**Learning Check 4.** After Step 5, what does `xhat` capture?

<details>
<summary>
Show answer
</summary>

It creates `xhat`. 1. Transform bits into integer alternatives.

</details>
