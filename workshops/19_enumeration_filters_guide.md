This tutorial complements `19_enumeration_filters.R` and unpacks the
workshop on filtering enumerated architectures. You will see how it
advances the Enumeration sequence while building confidence with base R
and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working
  directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines
  interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from
  earlier workshops.

## Skills

- Navigate the script `19_enumeration_filters.R` within the Enumeration
  module.
- Connect the topic “Filtering enumerated architectures” to systems
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
    B[Practice the Pipe] --> C[Define get_percentages()]
    C[Define get_percentages()] --> D[Clear Objects]
```

## Application

### Step 1 – Load Packages

Load packages. Attach dplyr to make its functions available.

``` r
library(dplyr) # for data wrangling
library(ggplot2) # for plotting
library(ggpubr) # for combining plots
```

### Step 2 – Run the Code Block

random sample from a uniform distribution – 2 parameters min (a) and max
(b).

``` r
runif(n = 5, min = 0, max = 10)
```

### Step 3 – Create `data`

Suppose we have 10000 architectures, each with an x, y, and z metrics.

``` r
data = tibble(
  x = runif(n = 10000, min = 0, max = 1),
  y = runif(n = 10000, min = 0, max = 1),
  z = sample(x = c("a", "b", "c"), size = 10000, replace = TRUE)) %>%
  # Also, we'll just create some stratifying variables for later.
  mutate(x_quarters = ntile(x, 4),
       y_quarters = ntile(y, 4))
```

### Step 4 – Create `g1`

Population. Create the object `g1` so you can reuse it in later steps.

``` r
g1 = ggplot() +
  geom_point(data = data, mapping = aes(x = x, y = y, color = z),
             alpha = 0.5)
```

### Step 5 – Run the Code Block

The whole population would look like this…

``` r
g1
```

### Step 6 – Practice the Pipe

Pure Random Sample Use sample_n() to sample 100 architectures.

``` r
sample1 = data %>%
  sample_n(size = 1000)
```

### Step 7 – Create `g2`

A purely random sample would look like this…

``` r
g2 = ggplot() +
  geom_point(data = sample1, mapping = aes(x = x, y = y, color = z), 
             alpha = 0.5)
```

### Step 8 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
g2
```

### Step 9 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sample2 = data %>%
  group_by(x_quarters, y_quarters, z) %>%
  sample_n(size = round(1000/(4*4*3)))
```

### Step 10 – Create `g3`

Create the object `g3` so you can reuse it in later steps.

``` r
g3 = ggplot() +
  geom_point(data = sample2, mapping = aes(x = x, y = y, color = z), 
             alpha = 0.5)
library(ggpubr)
```

### Step 11 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
ggarrange(g2,g3, nrow = 1)
```

### Step 12 – Define `get_percentages()`

Can be hard to compare visually, but let’s check them numerically…

``` r
get_percentages = function(x, did = "d2"){
  # Testing values
  #x = mini$d2
```

### Step 13 – Practice the Pipe

Get the tally per alternative.

``` r
  tally = tibble(altid = x) %>%
    group_by(altid) %>%
    summarize(count = n())
  # Calculate percentages
  percentages = tally %>% 
    mutate(total = sum(count)) %>%
    mutate(percent = count / total) %>%
    mutate(label = round(percent * 100, 1)) %>%
    mutate(label = paste0(label, "%"))
  # Add a decision id and format
  percentages = percentages %>% 
    mutate(did = did) %>%
    select(did, altid, count, total, percent, label)
```

### Step 14 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
  return(percentages)
}
```

### Step 15 – Run the Code Block

What’s the breakdown by our 3 stratifying variables?

``` r
get_percentages(x = sample2$x_quarters)
get_percentages(x = sample2$y_quarters)
get_percentages(x = sample2$z)
```

### Step 16 – Run the Code Block

Compare that to the pure random sample.

``` r
get_percentages(x = sample1$x_quarters)
get_percentages(x = sample1$y_quarters)
get_percentages(x = sample1$z)
```

### Step 17 – Clear Objects

Clean up! Remove objects from the environment to prevent name clashes.

``` r
rm(list = ls())
```

## Learning Checks

**Learning Check 1.** What role does the helper `get_percentages()`
defined in Step 12 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 2.** Which libraries does Step 1 attach, and why do you
run that chunk before others?

<details>
<summary>
Show answer
</summary>

It attaches dplyr, ggplot2 and ggpubr, ensuring their functions are
available before you execute the downstream code.

</details>

**Learning Check 3.** After Step 3, what does `data` capture?

<details>
<summary>
Show answer
</summary>

It creates `data` that adds derived columns, and builds a tibble of
scenario data. Suppose we have 10000 architectures, each with an x, y,
and z metrics.

</details>

**Learning Check 4.** After Step 4, what does `g1` capture?

<details>
<summary>
Show answer
</summary>

It creates `g1` that initialises a ggplot visualisation, and layers
geoms onto the plot. Population. Create the object `g1` so you can reuse
it in later steps.

</details>
