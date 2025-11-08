---
title: "[01] GitHub onboarding for course Guide"
output:
  md_document:
    variant: gfm
output_dir: ../workshops
knitr:
  opts_knit:
    root.dir: ..
---

This tutorial complements `01_stakeholder_github_setup.R` and unpacks the workshop on github onboarding for course. You will see how it advances the Stakeholder Analysis sequence while building confidence with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.

## Skills

- Navigate the script `01_stakeholder_github_setup.R` within the Stakeholder Analysis module.
- Connect the topic "GitHub onboarding for course" to systems architecting decisions.
- Install any required packages highlighted with `install.packages()`.

## Application

### Step 1 – Install Packages

Install credentials package. Install credentials so the rest of the workshop can run.


``` r
install.packages("credentials")
```

### Step 2 – Register GitHub PAT

Set github personal-access-token (PAT).


``` r
credentials::set_github_pat()
```

## Learning Checks

**Learning Check 1.** How do you run the entire workshop script after you have stepped through each section interactively?

<details>
<summary>Show answer</summary>

Use `source(file.path("workshops", "01_stakeholder_github_setup.R"))` from the Console or press the Source button while the script is active.

</details>

**Learning Check 2.** Why does the script begin by installing or loading packages before exploring the exercises?

<details>
<summary>Show answer</summary>

Those commands make sure the required libraries are available so every subsequent code chunk runs without missing-function errors.

</details>

**Learning Check 3.** In your own words, what key idea does the topic "GitHub onboarding for course" reinforce?

<details>
<summary>Show answer</summary>

It highlights how github onboarding for course supports the overall systems architecting process in this course.

</details>
