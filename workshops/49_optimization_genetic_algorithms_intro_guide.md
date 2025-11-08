---
title: "[49] Genetic algorithm introduction Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `49_optimization_genetic_algorithms_intro.R` and unpacks the workshop on genetic algorithm introduction. You will see how it advances the Optimization sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `49_optimization_genetic_algorithms_intro.R` within the Optimization module.
- Connect the topic "Genetic algorithm introduction" to systems architecting decisions.
- Load packages with `library()` and verify they attach without warnings.
- Chain tidyverse verbs with `%>%` to explore stakeholder or architecture tables.
- Define custom functions to package repeatable logic.
- Experiment with optimisation searches powered by the `GA` package.

## Application

### Step 1 – Load Packages

Load packages. Attach dplyr to make its functions available.


``` r
library(dplyr)
library(readr)
library(tidyr)
library(archr)
library(GA)
library(rmoo)
```

### Step 2 – Practice the Pipe

3.2.1 Data #################################### HW3.


``` r
a = tidyr::expand_grid(d1 = c(0,1), d2 = c(0,1), d3 = c(0, 1, 2, 4)) %>% as.matrix()
# or
a = archr::enumerate_sf(n = c(2,2,4))
```

### Step 3 – Create `meta`

Calculate total length of your bitstring.


``` r
meta = tibble(
  # List your decisions
  did = c(1,2,3),
  # An example architecture
  ref = c(0, 1, 3),
  # List the lowest range of integer alternatives
  lower = c(0,0,0),
  # List the upper range of integer alternatives
  upper = c(1,1,3),
  # Write out total number of alternatives available,
  n_alts = c(2, 2, 4),
  # Calculate the total number of bits needed to represent each.
  n_bits = n_alts %>% log2() %>% ceiling()
)
# View it!
meta
```

### Step 4 – Run the Code Block

Encoding an integer as a 2-bit string.


``` r
c(0,1) # 1
c(0,0) # 0
c(1,0) # 2
c(1,1) # 3
```

### Step 5 – Run the Code Block

Encoding 0 to 1 as a bit string.


``` r
c(0) # 0
c(1) # 1
```

### Step 6 – Practice the Pipe

architecture. Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
c(0,1,3,2,5) %>% log2() %>% ceiling() %>% max()
```

### Step 7 – Create `xhat`

Get a reference architecture [D1 = 1, D2 = 0, D3 = 2].


``` r
xhat = c(1, 0, 2)
```

### Step 8 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
xhat[1]
xhat[2]
xhat[3]
```

### Step 9 – Create `x1`

Convert the first integer [0,1] to binary [0,1].


``` r
x1 = decimal2binary(x = xhat[1], length = 1)
# Convert the second integer [0,1] to binary [0,1]
x2 = decimal2binary(x = xhat[2], length = 1)
# Convert the third integer [0,1,2,3] to binary [00,01,10,11]
x3 = decimal2binary(x = xhat[3], length = 1)
# Bind them together!
x = c(x1,x2,x3)
x # View it! (This will
```

### Step 10 – Create `xhat1`

Create the object `xhat1` so you can reuse it in later steps.


``` r
xhat1 = binary2decimal(x = x[1]) # convert first integer's set of bits
xhat2 = binary2decimal(x = x[2]) # convert next integer's set of bits
xhat3 = binary2decimal(x = x[3:4]) # convert next integer's set of bits
xhat = c(xhat1, xhat2, xhat3) # bind together
xhat # View it
```

### Step 11 – Define `bit2int()`

Create the helper function `bit2int()` so you can reuse it throughout the workshop.


``` r
bit2int = function(x){
  xhat1 = binary2decimal(x = x[1]) # convert first integer's set of bits
  xhat2 = binary2decimal(x = x[2]) # convert next integer's set of bits
  xhat3 = binary2decimal(x = x[3:4]) # convert next integer's set of bits
  xhat = c(xhat1, xhat2, xhat3) # bind together
  return(xhat) # View it!
}
```

### Step 12 – Run the Code Block

Try it! Execute the block and pay attention to the output it produces.


``` r
bit2int(c(1,0,1,1))
bit2int(c(1,0,1,1))
bit2int(c(1,1,1,0))
bit2int(c(0,0,1,1))
```

### Step 13 – Define `evaluate()`

Evaluate this integer string.


``` r
evaluate = function(xhat){
  #xhat = c(1,0,1)
  # Make metrics
  m1 = sum(xhat)
  m2 = prod(cos(xhat)^2)
  m3 = sum(xhat * c(0.25, 0.5, pi^-2))
  # Bundle metrics
  metrics = c(m1,m2,m3)
```

### Step 14 – Create `m`

Create the object `m` so you can reuse it in later steps.


``` r
  m = matrix(data = metrics, ncol = length(metrics))
```

### Step 15 – Run the Code Block

m = matrix(data = metrics, ncol = length(metrics), dimnames = list(c(), names(metrics))).


``` r
  return(m)
}
```

### Step 16 – Run the Code Block

Let's try evaluating a reference architecture!


``` r
evaluate(xhat = c(1,0,3))
```

### Step 17 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
a
# a %>% slice(5) %>% evaluate()
# a %>% slice(6) %>% evaluate()
# a %>% slice(7) %>% evaluate()
```

### Step 18 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
evaluate(xhat = c(0,0,0))
evaluate(xhat = c(0,0,1))
evaluate(xhat = c(0,1,1))
evaluate(xhat = c(0,1,0))
evaluate(xhat = c(0,1,0))
```

### Step 19 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
evaluate(xhat = c(1,0,1))
```

### Step 20 – Define `f1()`

3.2.5 Writing a fitness function ##########################.


``` r
f1 = function(x, nobj = 3, ...){
  # x = c(1,0,0,1)
  # First, let's convert from binary to our integer-formatted architecture
  xhat = bit2int(x)
  # Seconds, let's get metrics 
  metrics = evaluate(xhat)
  # Third, let's return metrics
  return(metrics)
}
# Let's try it!
f1(x = c(0,0,0,1))
f1(x = c(0,0,1,0))
f1(x = c(0,1,0,1))
f1(x = c(1,1,0,1))
f1(x = c(1,1,0,0))
```

### Step 21 – Practice the Pipe

3.2.6 Running the Genetic Algorithm ####################### Calculate the total number of bits in your bitstring.


``` r
total_bits = meta %>% summarize(total = sum(n_bits)) %>% with(total)
```

### Step 22 – Create `ref`

Create the object `ref` so you can reuse it in later steps.


``` r
ref = generate_reference_points(m = 3, h = 10)
# Take a peek!
head(ref)
```

### Step 23 – Create `o`

Full binary search. Create the object `o` so you can reuse it in later steps.


``` r
o = rmoo(
  fitness = f1, type = "binary", algorithm = "NSGA-III",
  # Upper and Lower bounds on the bitstrings
  lower = c(0,0,0,0), upper = c(1,1,1,1),
  # Settings
  monitor = TRUE, summary = TRUE,
  nObj = 3, nBits = total_bits, popSize = 50, maxiter = 100
)
 # Extras
#  reference_dirs = ref)
```

### Step 24 – Run the Code Block

3.2.7 Reviewing Results #################33.


``` r
o
```

### Step 25 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
summary(o)
o@solution
bit2int(o@solution)
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "49_optimization_genetic_algorithms_intro.R"))` from the Console or press the Source button while the script is active.

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

**Learning Check 5.** Which GA configuration elements should you review after running the optimisation example?

<details>
<summary>Show answer</summary>

Check the population size, mutation probability, and fitness function definition to understand how the search explores designs.

</details>
