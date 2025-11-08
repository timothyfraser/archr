This tutorial complements `42_optimization_binary_encoding.R` and
unpacks the workshop on binary encoding primer. You will see how it
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

- Navigate the script `42_optimization_binary_encoding.R` within the
  Optimization module.
- Connect the topic “Binary encoding primer” to systems architecting
  decisions.
- Install any required packages highlighted with `install.packages()`.
- Load packages with `library()` and verify they attach without
  warnings.
- Define custom functions to package repeatable logic.

## Process Overview

``` mermaid
flowchart LR
    A[Load Packages] --> B[Create d1]
    B[Create d1] --> C[Run the Code Block]
    C[Run the Code Block] --> D[Define bit2int()]
```

## Application

### Step 1 – Load Packages

Attach dplyr to make its functions available.

``` r
library(dplyr)
# install.packages("GA")
# install.packages("rmoo")
library(GA)
library(rmoo)
```

### Step 2 – Run the Code Block

\[XX\]\[X\]\[X\]. Execute the block and pay attention to the output it
produces.

``` r
c(0,1, 0, 0) # binary
```

### Step 3 – Run the Code Block

Convert from binary into decimal.

``` r
binary2decimal(x = c(0, 0) )
binary2decimal(x = c(0, 1) )
binary2decimal(x = c(1, 0) )
binary2decimal(x = c(1, 1) )
```

### Step 4 – Define `int2bit()`

Create the helper function `int2bit()` so you can reuse it throughout
the workshop.

``` r
int2bit = function(xhat){
```

### Step 5 – Create `d1`

Create the object `d1` so you can reuse it in later steps.

``` r
  d1 = xhat[1]
  d2 = xhat[2]
  d3 = xhat[3]
```

### Step 6 – Run the Code Block

D1 Resampler If d1 is NOT in this set of valid values.

``` r
  if(!d1 %in% c(0,1,2)){
    # Randomly resample from valid values
    d1 = sample(size = 1, x = c(0,1,2) ) 
  }
  # D1 Convert to bits
  x1 = case_when(
    d1 == 0 ~ c(0,0),
    d1 == 1 ~ c(0,1),
    d1 == 2 ~ c(1,0)
  )
```

### Step 7 – Run the Code Block

D2 Resampler. Execute the block and pay attention to the output it
produces.

``` r
  if(!d2 %in% c(0,1)){ d2 = sample(size = 1, x = c(0,1)) }
```

### Step 8 – Create `x2`

D2 Convert to Bits.

``` r
  x2 = case_when(
    d2 == 0 ~ c(0),
    d2 == 1 ~ c(1)
  )
```

### Step 9 – Run the Code Block

D3 Resampler. Execute the block and pay attention to the output it
produces.

``` r
  if(!d3 %in% c(0,1)){ d3 = sample(size = 1, x = c(0,1)) }
```

### Step 10 – Create `x3`

D3 Convert to Bits.

``` r
  x3 = case_when(
    d3 == 0 ~ c(0),
    d3 == 1 ~ c(1)
  )
```

### Step 11 – Create `x`

Goal: turn our integer vector into a vector of bits x.

``` r
  x = c(x1, x2, x3)
  return(x)
}
```

### Step 12 – Run the Code Block

Test it. Execute the block and pay attention to the output it produces.

``` r
int2bit(xhat = c(3, 1, 1))
```

### Step 13 – Define `bit2int()`

From binary to integer.

``` r
bit2int = function(x){ }
```

## Learning Checks

**Learning Check 1.** Which packages do you install in Step 1, and what
must you verify before moving on?

<details>
<summary>
Show answer
</summary>

Step 1 installs GA and rmoo, so make sure each package finishes
installing without errors before continuing.

</details>

**Learning Check 2.** What role does the helper `int2bit()` defined in
Step 4 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 3.** What role does the helper `bit2int()` defined in
Step 13 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 4.** After Step 5, what does `d1` capture?

<details>
<summary>
Show answer
</summary>

It creates `d1`. Create the object `d1` so you can reuse it in later
steps.

</details>
