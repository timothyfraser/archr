---
title: "[00] Information theory helpers Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `00_entropy_utilities.R` and unpacks the workshop on information theory helpers. You will see how it advances the Evaluation sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `00_entropy_utilities.R` within the Evaluation module.
- Connect the topic "Information theory helpers" to systems architecting decisions.
- Chain tidyverse verbs with `%>%` to explore stakeholder or architecture tables.
- Define custom functions to package repeatable logic.

## Application

### Step 1 – Define `h()`

Create the helper function `h()` so you can reuse it throughout the workshop.


``` r
h = function(x){  -1*sum( x*log(x, base = 2) )  }
```

### Step 2 – Define `j()`

Create the helper function `j()` so you can reuse it throughout the workshop.


``` r
j = function(xy){ -1*sum(  sum( (xy) * log(xy, base = 2) ) ) }
```

### Step 3 – Define `i()`

Create the helper function `i()` so you can reuse it throughout the workshop.


``` r
i = function(x,y, xy){
  sum( sum( xy * log( ( xy / (x * y) ),  base = 2) ) )
}
```

### Step 4 – Define `ig()`

Create the helper function `ig()` so you can reuse it throughout the workshop.


``` r
ig = function(good, feature = NULL, .all = FALSE){
  # Testing values
  # feature = a$f
  # good = a$good
  data = data.frame(good)
  # Make a list container for the output
  output = list()
```

### Step 5 – Practice the Pipe

Tally up frequency of good vs. bad architectures.


``` r
  tally_good = data %>%
    group_by(good) %>%
    summarize(n = n(), .groups = "drop") %>%
    mutate(p = n / nrow(data))
```

### Step 6 – Practice the Pipe

Calculate entropy. Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
  stat = tally_good %>% 
    summarize(h = h(p))
```

### Step 7 – Run the Code Block

Add quantities to output.


``` r
  output$prob = tally_good
  output$stat = stat
```

### Step 8 – Run the Code Block

If feature is supplied...


``` r
  if(!is.null(feature)){
    data$feature = feature
```

### Step 9 – Practice the Pipe

Tally up frequency of good vs. bad given feature vs. not feature.


``` r
    tally_feature = data %>%
      group_by(good, feature) %>%
      # Count the architectures
      summarize(n = n(), .groups = "drop") %>%
      group_by(feature) %>%
      mutate(total = sum(n),
             p = n / total)
```

### Step 10 – Practice the Pipe

Get entropy by feature.


``` r
    h_by_feature = tally_feature %>%
      summarize(h = h(p),
                n = sum(n),
                fraction = n / nrow(data))
```

### Step 11 – Practice the Pipe

Get average weighted entropy.


``` r
    stat1 = h_by_feature %>%
      summarize(h_split = sum(fraction * h) )
```

### Step 12 – Practice the Pipe

Get the information gain.


``` r
    stat = bind_cols(stat, stat1) %>%
      mutate(ig = h - h_split)
```

### Step 13 – Run the Code Block

Add quantities to output.


``` r
    output$prob_split = tally_feature
    output$stat = stat
  }
```

### Step 14 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
  if(.all == FALSE){
    output = output$stat
  }
```

### Step 15 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
  return(output)
}
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "00_entropy_utilities.R"))` from the Console or press the Source button while the script is active.

</details>

**Learning Check 2.** How does the `%>%` pipeline help you reason about multi-step transformations in this script?

<details>
<summary>Show answer</summary>

It keeps each operation in sequence without creating temporary variables, so you can narrate the data story line by line.

</details>

**Learning Check 3.** How can you build confidence that a newly defined function behaves as intended?

<details>
<summary>Show answer</summary>

Call it with the sample input from the script, examine the output, then try a new input to see how the behaviour changes.

</details>
