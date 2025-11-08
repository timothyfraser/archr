---
title: "[18] Visualization of enumeration results Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `18_enumeration_visualization.R` and unpacks the workshop on visualization of enumeration results. You will see how it advances the Enumeration sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `18_enumeration_visualization.R` within the Enumeration module.
- Connect the topic "Visualization of enumeration results" to systems architecting decisions.
- Install any required packages highlighted with `install.packages()`.
- Load packages with `library()` and verify they attach without warnings.
- Export results to disk so you can reuse them across workshops.
- Chain tidyverse verbs with `%>%` to explore stakeholder or architecture tables.
- Define custom functions to package repeatable logic.
- Iterate on visualisations built with `ggplot2`.

## Application

### Step 1 – Load Packages

Load packages. Attach dplyr to make its functions available.


``` r
library(dplyr)
library(tidyr)
library(ggplot2)
library(archr)
```

### Step 2 – Practice the Pipe

Suppose you have a decision, but you can only **sample 2 out of 4 alternatives.** You can use sample_n() from dplyr for that.


``` r
enumerate_sf(n = c(4)) %>%
  sample_n(size = 2)
```

### Step 3 – Create `arch`

Get your full architectural space.


``` r
arch = expand_grid(
  enumerate_sf(n = c(2,4,3), .did = 1),
  enumerate_ds(n = 3, k = 2, .did = 4),
  enumerate_permutation(n = 8, k = 4, .did = 5)
)
```

### Step 4 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
arch %>% glimpse()
```

### Step 5 – Practice the Pipe

You can take a random sample directly, but it may cause issues - always important to check representativeness.


``` r
mini = arch %>%
  sample_n(size = 10000)
```

### Step 6 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
mini
```

### Step 7 – Create `part1`

Create the object `part1` so you can reuse it in later steps.


``` r
part1 = expand_grid(
  enumerate_sf(n = 2, .did = 1),
  enumerate_sf(n = 4, .did = 2) 
) %>%
  # For each alternative in d1, 
  # sample 2 alternatives from d2
  group_by(d1) %>%
  sample_n(size = 2)  %>%
  ungroup()
```

### Step 8 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
part2 = part1 %>%
  # Get the full grid of those options and
  # ALL options from d3
  expand_grid(enumerate_sf(n = 3, .did = 3)) %>%
  # for each alternative in d1 and d2,
  # sample 2 alternatives from d3
  group_by(d1,d2) %>%
  sample_n(size = 2) %>%
  ungroup()
```

### Step 9 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
part3 = part2 %>%
  # Expand out for d4...
  expand_grid(enumerate_ds(n = 3, k = 2, .did = 4)) %>%
  # For each set of d1,d2, and d3,
  # sample 5 possible outcomes from d4
  group_by(d1,d2,d3) %>%
  sample_n(size = 5)
```

### Step 10 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
part4 = part3 %>%
  # Expand out for d5...
  expand_grid(enumerate_permutation(n = 8, k = 4, .did = 5)) %>%
  # For each set of d1,d2,d3,and d4_1,d4_2,d4_3,
  # sample 25 possible outcomes from d5
  # You can write it easily using 'across(start:end)'
  #group_by(d1,d2,d3,d4_1,d4_2,d4_3) %>%
  group_by(across(d1:d4_3)) %>%
  sample_n(size = 25) %>%
  ungroup()
```

### Step 11 – Practice the Pipe

BY STRATA ################### For each strata (a set of unique d1-d2-d3-d4_1-d4_2-d4_3 values) sample 25 rows (akin to grabbing 25 paths).


``` r
arch %>%
  group_by(across(d1:d4_3)) %>%
  sample_n(size = 25)
```

### Step 12 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
arch %>%
  mutate(s1 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s2 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s3 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s4_1 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s4_2 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s4_3 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s5_1 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s5_2 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s5_3 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s5_4 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  # Grab just the paths that were selected...
  filter( s1 == TRUE & s2 == TRUE & s3 == TRUE,
          s4_1 == TRUE & s4_2 == TRUE & s4_3 == TRUE,
          s5_1 == TRUE &  s5_2 == TRUE & s5_3 == TRUE & s5_4 == TRUE)
```

### Step 13 – Load Packages

Attach dplyr to make its functions available.


``` r
library(dplyr)
library(archr)
```

### Step 14 – Create `data`

Create the object `data` so you can reuse it in later steps.


``` r
data = enumerate_sf(n = c(2, 4, 3))
```

### Step 15 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
a = data %>%
  sample_n(size = 3)
```

### Step 16 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
a # view it
```

### Step 17 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
b = data %>%
  group_by(d1) %>%
  sample_n(size = 3)
```

### Step 18 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
b # view it
```

### Step 19 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
c = data %>%
  group_by(d1, d2) %>%
  sample_n(size = 3)
```

### Step 20 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
c # view it
```

### Step 21 – Practice the Pipe

For the moment though, let's just take 10000 samples, just as a demonstration.


``` r
mini = arch %>%
  sample_n(size = 10000)
```

### Step 22 – Practice the Pipe

Let's get the count of population traits...


``` r
arch %>%
  group_by(d1) %>%
  summarize(count = n())
```

### Step 23 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
pop = arch %>%
  group_by(did = "d1", altid = d1) %>%
  summarize(count = n())
```

### Step 24 – Practice the Pipe

Let's get the count of the sample traits...


``` r
sample = mini %>%
  group_by(did = "d1", altid = d1) %>%
  summarize(count = n())
```

### Step 25 – Create `stat`

Let's stack them together and label by type...


``` r
stat = bind_rows(
  pop %>% mutate(type = "pop"),
  sample %>% mutate(type = "sample")
)
```

### Step 26 – Practice the Pipe

Finally, let's turn those counts into percentages.


``` r
stat = stat %>%
  # For each type and decision id...
  group_by(type, did) %>%
  mutate(total = sum(count),
         percent = count / total,
         label = round(percent * 100, 1),
         label = paste0(label, "%"))
```

### Step 27 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
stat
```

### Step 28 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_col(data = stat %>% filter(type == "pop"), 
           mapping = aes(x = factor(altid), y = percent))
```

### Step 29 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_col(data = stat %>% filter(type == "pop"), 
           mapping = aes(x = factor(altid), y = percent)) + 
  scale_y_continuous(limits = c(0, 1))
```

### Step 30 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_col(data = stat, 
           mapping = aes(x = factor(altid), y = percent)) + 
  scale_y_continuous(limits = c(0, 1))  +
  facet_wrap(~type)
```

### Step 31 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_col(data = stat,
           mapping = aes(x = factor(altid), y = percent)) + 
  geom_text(data = stat, 
            mapping = aes(x = factor(altid), y = percent + 0.05, label = label)) +
  scale_y_continuous(limits = c(0, 1))  +
  facet_wrap(~type) +
  labs(x = "Alternatives", y = "Percent (%)",
       title = "Decision 1")
```

### Step 32 – Start a ggplot

And let's visualize it!


``` r
ggplot() +
  geom_col(data = stat, mapping = aes(x = altid, y = percent)) +
  geom_text(data = stat, mapping = aes(x = altid, y = percent, label = label), 
            nudge_y = 0.1) +
  facet_wrap(~type) +
  # Let's make this look a lot clearer
  scale_y_continuous(breaks = c(0, 0.25, 0.5, 0.75, 1), limits = c(0,1))
```

### Step 33 – Define `get_percentages()`

Create the helper function `get_percentages()` so you can reuse it throughout the workshop.


``` r
get_percentages = function(x){ 
  # x = mini$d1 
  tally = tibble(altid = x) %>%
    group_by(altid) %>%
    summarize(count = n())
  return(tally) 
}
```

### Step 34 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
get_percentages(x = mini$d1)
```

### Step 35 – Define `get_percentages()`

Create the helper function `get_percentages()` so you can reuse it throughout the workshop.


``` r
get_percentages = function(x, did = "d1"){ 
  # x = mini$d1 
  tally = tibble(altid = x) %>%
    group_by(altid) %>%
    summarize(count = n())
```

### Step 36 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
  tally = tally %>% 
    mutate(did = did)
```

### Step 37 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
  return(tally) 
}
```

### Step 38 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
get_percentages(x = mini$d2, did = "d2")
```

### Step 39 – Define `get_percentages()`

Create the helper function `get_percentages()` so you can reuse it throughout the workshop.


``` r
get_percentages = function(x, did = "d1"){ 
  # x = mini$d1 
  tally = tibble(altid = x) %>%
    group_by(altid) %>%
    summarize(count = n())
```

### Step 40 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
  tally = tally %>% 
    mutate(did = did)
```

### Step 41 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
  percentages = tally %>% 
    mutate(total = sum(count)) %>%
    mutate(percent = count / total)
```

### Step 42 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
  return(percentages) 
}
```

### Step 43 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
get_percentages(x = mini$d2, did = "d2")
```

### Step 44 – Define `get_percentages()`

Create the helper function `get_percentages()` so you can reuse it throughout the workshop.


``` r
get_percentages = function(x, did = "d2"){
  # Testing values
  #x = mini$d2
```

### Step 45 – Practice the Pipe

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

### Step 46 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
  return(percentages)
}
```

### Step 47 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
get_percentages(x = mini$d2, did = "d2")
# You can also do it like this...
mini %>% with(d1) %>% get_percentages(did = "d1")
```

### Step 48 – Create `stat2`

We even do a bunch, and bind them atop each other. For example, here's the sample.


``` r
stat2 = bind_rows(
  get_percentages(x = mini$d1, did = "d1"),
  get_percentages(x = mini$d2, did = "d2"),
  get_percentages(x = mini$d3, did = "d3"),
  get_percentages(x = mini$d4_1, did = "d4_1"),
  get_percentages(x = mini$d4_2, did = "d4_2"),
  get_percentages(x = mini$d4_3, did = "d4_3"),
  get_percentages(x = mini$d5_1, did = "d5_1"),
  get_percentages(x = mini$d5_2, did = "d5_2"),
  get_percentages(x = mini$d5_3, did = "d5_3"),
  get_percentages(x = mini$d5_4, did = "d5_4")
)
```

### Step 49 – Run the Code Block

Execute the block and pay attention to the output it produces.


``` r
stat2
```

### Step 50 – Create `stat3`

We could even do the whole thing at once, for both sample and population.


``` r
stat3 = bind_rows(
  bind_rows(
    get_percentages(x = mini$d1, did = "d1"),
    get_percentages(x = mini$d2, did = "d2"),
    get_percentages(x = mini$d3, did = "d3"),
    get_percentages(x = mini$d4_1, did = "d4_1"),
    get_percentages(x = mini$d4_2, did = "d4_2"),
    get_percentages(x = mini$d4_3, did = "d4_3"),
    get_percentages(x = mini$d5_1, did = "d5_1"),
    get_percentages(x = mini$d5_2, did = "d5_2"),
    get_percentages(x = mini$d5_3, did = "d5_3"),
    get_percentages(x = mini$d5_4, did = "d5_4")
  ) %>%
    mutate(type = "sample"),
  bind_rows(
    get_percentages(x = arch$d1, did = "d1"),
    get_percentages(x = arch$d2, did = "d2"),
    get_percentages(x = arch$d3, did = "d3"),
    get_percentages(x = arch$d4_1, did = "d4_1"),
    get_percentages(x = arch$d4_2, did = "d4_2"),
    get_percentages(x = arch$d4_3, did = "d4_3"),
    get_percentages(x = arch$d5_1, did = "d5_1"),
    get_percentages(x = arch$d5_2, did = "d5_2"),
    get_percentages(x = arch$d5_3, did = "d5_3"),
    get_percentages(x = arch$d5_4, did = "d5_4")
  ) %>%
    mutate(type = "pop")
)
```

### Step 51 – Run the Code Block

Check it! Execute the block and pay attention to the output it produces.


``` r
stat3
```

### Step 52 – Start a ggplot

Let's try and visualize that now!


``` r
ggplot() +
  geom_col(data = stat3, mapping = aes(x = factor(altid), y = percent)) +
  facet_wrap(type~did)
```

### Step 53 – Start a ggplot

Initialize a ggplot so you can layer geoms and customise aesthetics.


``` r
ggplot() +
  geom_col(data = stat3 %>% 
             filter(did %in% c("d1","d2","d3")), 
           mapping = aes(x = factor(altid), y = percent)) +
  facet_wrap(type~did)
```

### Step 54 – Load Packages

You can use the ggpubr package and its ggarrange() function for this install.packages("ggpubr").


``` r
library(ggpubr)
```

### Step 55 – Define `get_viz()`

Create the helper function `get_viz()` so you can reuse it throughout the workshop.


``` r
get_viz = function(data){
  gg = ggplot() +
    geom_col(
      data = data, 
      mapping = aes(x = factor(altid), y = percent))  +
    geom_text(
      data = data,
      mapping = aes(x = factor(altid), y = percent, label = label), 
      nudge_y = 0.1) +
    facet_wrap(~type) +
    # Let's make this look a lot clearer
    scale_y_continuous(breaks = c(0, 0.25, 0.5, 0.75, 1), limits = c(0,1)) 
  return(gg)
}
```

### Step 56 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.


``` r
g1 = stat3 %>% filter(did == "d1") %>% get_viz()
g2 = stat3 %>% filter(did == "d2") %>% get_viz()
g3 = stat3 %>% filter(did == "d3") %>% get_viz()
# Then bundle them together
ggmany = ggpubr::ggarrange(g1,g2,g3, nrow = 1)
```

### Step 57 – Run the Code Block

And save to file with ggsave() from ggplot.


``` r
ggsave(
  plot = ggmany,
  filename = "workshops/18_enumeration_visualization.png", 
  # You can optionally add a dots-per-inch (dpi)
  dpi = 200, 
  # as well as a width and height in inches
  width = 12, height = 5)
```

### Step 58 – Clear Objects

Clean up! Remove objects from the environment to prevent name clashes.


``` r
rm(list = ls())
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "18_enumeration_visualization.R"))` from the Console or press the Source button while the script is active.

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

**Learning Check 5.** What experiment can you run on the `ggplot` layers to understand how aesthetics map to data?

<details>
<summary>Show answer</summary>

Switch one aesthetic (for example `color` to `fill` or tweak the geometry) and re-run the chunk to observe the difference.

</details>
