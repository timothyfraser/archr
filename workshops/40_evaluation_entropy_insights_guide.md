This tutorial complements `40_evaluation_entropy_insights.R` and unpacks
the workshop on entropy and tradespace insights. You will see how it
advances the Evaluation sequence while building confidence with base R
and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working
  directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines
  interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from
  earlier workshops.

## Skills

- Navigate the script `40_evaluation_entropy_insights.R` within the
  Evaluation module.
- Connect the topic “Entropy and tradespace insights” to systems
  architecting decisions.
- Chain tidyverse verbs with `%>%` to explore stakeholder or
  architecture tables.

## Process Overview

``` mermaid
flowchart LR
    A[Run the Code Block] --> B[Run the Code Block (Step 6)]
    B[Run the Code Block (Step 6)] --> C[Run the Code Block (Step 12)]
    C[Run the Code Block (Step 12)] --> D[Practice the Pipe]
```

## Application

### Step 1 – Run the Code Block

0.  SETUP \################################ Load 00_entropy_utilities.R
    for h(), j(), i(), and ig().

``` r
source("workshops/00_entropy_utilities.R")
```

### Step 2 – Run the Code Block

Compute the entropy of a random variable that takes values 1,2, or 3
with equal probability.

``` r
h(x = c(0.33333, 0.33333, 0.33333))
h(x = c(0.5, 0.4, 0.1))
```

### Step 3 – Create `features`

Create the object `features` so you can reuse it in later steps.

``` r
features = tibble(
  # Here's feature 1 and its probabilities
  f1 = c("A", "B"),
  p1 = c(0.50, 0.50),
  # Here's feature 2 and its probabilities
  f2 = c("A", "B"),
  p2 = c(0.99, 0.01)
)
```

### Step 4 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
features
```

### Step 5 – Run the Code Block

as expected, f1 has higher entropy that f2.

``` r
h(x = features$p1) 
h(x = features$p2)
```

### Step 6 – Run the Code Block

This means that you can just multiply together the probabilities as your
input.

``` r
j(xy = features$p1 * features$p2)
```

### Step 7 – Run the Code Block

Mutual Information. Execute the block and pay attention to the output it
produces.

``` r
i(x = features$p1, y = features$p2, xy = features$p1 * features$p2)
```

### Step 8 – Create `a`

Suppose we have a sample of architectures.

``` r
a = tibble(
  # 10 architectures (each with a unique id)
  id = 1:10,
  # some architectures have feature f, others don't
  f = c(TRUE, TRUE, TRUE,  TRUE, TRUE, TRUE,
        FALSE, FALSE, FALSE, FALSE),
  # some architectures are 'good' (high quality, eg. pareto front), others are not.
  good = c(TRUE, TRUE, TRUE,  TRUE, TRUE, FALSE,
           FALSE, FALSE, TRUE, TRUE)
)
```

### Step 9 – Run the Code Block

Calculate baseline entropy given no feature split.

``` r
ig(good = a$good)
```

### Step 10 – Run the Code Block

Calculate entropy after feature split, and information gain from it.

``` r
ig(good = a$good, feature = a$f)
```

### Step 11 – Run the Code Block

Get list of components to check your work.

``` r
ig(good = a$good, feature = a$f, .all = TRUE)
```

### Step 12 – Run the Code Block

Compare decisions! Run these scripts getting a data.frame of
architectures `archs` with `cost`, `benefit`, and `risk` metrics.

``` r
source("workshops/08_architecting_metric_design.R")
# Load pareto_rank() function
source("workshops/00_pareto_rank_utilities.R")
```

### Step 13 – Practice the Pipe

Is that architecture good?

``` r
archs = archs %>%
  # Get pareto rank
  mutate(rank = pareto_rank(cost, -benefit)) %>%
  # Mark architectures as 'good' if their pareto rank is less than 5
  # Make sure you justify what rank you choose as your threshold
  mutate(good = rank < 5)
```

### Step 14 – Practice the Pipe

Does that architecture have a certain feature?

``` r
archs = archs %>%
  mutate(feature = case_when(d4 == 1 & d5 == 1 ~ TRUE, TRUE ~ FALSE))
```

### Step 15 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
archs %>% glimpse()
```

### Step 16 – Run the Code Block

Check information gain from this feature.

``` r
ig(good = archs$good, feature = archs$feature)
```

### Step 17 – Practice the Pipe

Check information gain from lots of features in this case we’ll count
each decision as a feature, as an example.

``` r
archs %>%
  select(d1:d5, good) %>%
  pivot_longer(cols = c(d1:d5), names_to = "type", values_to = "feature") %>%
  group_by(type) %>%
  summarize(ig(good = good, feature = feature))
```

## Learning Checks

**Learning Check 1.** After Step 3, what does `features` capture?

<details>
<summary>
Show answer
</summary>

It creates `features` that builds a tibble of scenario data. Create the
object `features` so you can reuse it in later steps.

</details>

**Learning Check 2.** After Step 8, what does `a` capture?

<details>
<summary>
Show answer
</summary>

It creates `a` that builds a tibble of scenario data. Suppose we have a
sample of architectures.

</details>

**Learning Check 3.** After Step 13, what does `archs` capture?

<details>
<summary>
Show answer
</summary>

It creates `archs` that adds derived columns, and threads the result
through a dplyr pipeline. Is that architecture good?

</details>

**Learning Check 4.** What should you verify after chaining the pipeline
in Step 15?

<details>
<summary>
Show answer
</summary>

Verify each transformation in the pipeline behaves as intended so the
final object reflects the described goal, namely to use the `%>%`
operator to pass each result to the next tidyverse verb.

</details>
