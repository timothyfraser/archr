---
title: "[43] Bit-integer conversion utilities Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `43_optimization_bit_integer_conversion.R` and unpacks the workshop on bit-integer conversion utilities. You will see how it advances the Optimization sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `43_optimization_bit_integer_conversion.R` within the Optimization module.
- Connect the topic "Bit-integer conversion utilities" to systems architecting decisions.
- Load packages with `library()` and verify they attach without warnings.
- Define custom functions to package repeatable logic.

## Application

### Step 1 – Load Packages

Load GA package. Attach GA to make its functions available.


``` r
library(GA)
```

### Step 2 – Run the Code Block

Test out our binary2decimal() function from GA.


``` r
binary2decimal(x = c(1,1))
```

### Step 3 – Define `bit2int()`

Let's try to code this up!


``` r
bit2int = function(x){
  # Testing value
  # x = c(0,0,0,1, 1,1, 1,1)
```

### Step 4 – Create `d1_1`

Decision 1 Converted to xhat.


``` r
  d1_1 = binary2decimal(x = x[1])
  d1_2 = binary2decimal(x = x[2])
  d1_3 = binary2decimal(x = x[3])
  d1_4 = binary2decimal(x = x[4])
```

### Step 5 – Run the Code Block

If all of decision 1 options are 0, then FAIL Reject if...


``` r
  if(d1_1 == 0 & d1_2 == 0 & d1_3 == 0 & d1_4 == 0){  return(NA)   }
```

### Step 6 – Create `d2`

Decision 2. Create the object `d2` so you can reuse it in later steps.


``` r
  d2 = binary2decimal(x[5:6])
  # Reject if...
  if( (d1_1 == 1 | d1_2 == 1 | d1_3 == 1) & d2 == 3){ return(NA)  }
  if( (d1_1 == 0 & d1_2 == 0 & d1_3 == 0 & d1_4 == 1) & d2 != 3){ return(NA)  }
```

### Step 7 – Create `d3`

Decision 3. Create the object `d3` so you can reuse it in later steps.


``` r
  d3 = binary2decimal(x[7:8])
  # Reject if...
  if( (d1_1 == 1 | d1_2 == 1 | d1_3 == 1) & d3 == 3){ return(NA)  }
  if( (d1_1 == 0 & d1_2 == 0 & d1_3 == 0 & d1_4 == 1) & d3 != 3){ return(NA)  }
```

### Step 8 – Create `xhat`

Bundle! Create the object `xhat` so you can reuse it in later steps.


``` r
  xhat = c(d1_1, d1_2, d1_3, d1_4, d2, d3)
  return(xhat)
}
```

### Step 9 – Run the Code Block

An invalid option returns NA.


``` r
bit2int(x = c(0,0,0,0, 1,1, 1,1))
# A valid option returns the integer string
bit2int(x = c(0,0,0,1, 1,1, 1,1))
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "43_optimization_bit_integer_conversion.R"))` from the Console or press the Source button while the script is active.

</details>

**Learning Check 2.** Why does the script begin by installing or loading packages before exploring the exercises?

<details>
<summary>Show answer</summary>

Those commands make sure the required libraries are available so every subsequent code chunk runs without missing-function errors.

</details>

**Learning Check 3.** How can you build confidence that a newly defined function behaves as intended?

<details>
<summary>Show answer</summary>

Call it with the sample input from the script, examine the output, then try a new input to see how the behaviour changes.

</details>
