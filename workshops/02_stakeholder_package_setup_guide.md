This tutorial complements `02_stakeholder_package_setup.R` and unpacks
the workshop on r package installation checklist. You will see how it
advances the Stakeholder Analysis sequence while building confidence
with base R and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working
  directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines
  interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from
  earlier workshops.

## Skills

- Navigate the script `02_stakeholder_package_setup.R` within the
  Stakeholder Analysis module.
- Connect the topic “R package installation checklist” to systems
  architecting decisions.
- Install any required packages highlighted with `install.packages()`.

## Process Overview

``` mermaid
flowchart LR
    A[Install Packages]
```

## Application

### Step 1 – Install Packages

List of packages installed.

``` r
install.packages(c(
  # data wrangling packages
  "dplyr", "readr", "tidyr", "stringr", "purrr", 
  # networks packages
  "igraph", "tidygraph", "ggraph", 
  # Visualization packages
  "ggplot2", "viridis", "ggpubr",
  # Optimization support packages
  "GA", "rmoo",
  # Modeling support packages
  "texreg", "broom",
  # Extra helper packages
  "gtools"))
```

## Learning Checks

**Learning Check 1.** Which packages do you install in Step 1, and what
must you verify before moving on?

<details>
<summary>
Show answer
</summary>

Step 1 installs dplyr, readr, tidyr, stringr, purrr, igraph, tidygraph,
ggraph, ggplot2, viridis, ggpubr, GA, rmoo, texreg, broom and gtools, so
make sure each package finishes installing without errors before
continuing.

</details>

**Learning Check 2.** Which script should you keep open while running
this guide?

<details>
<summary>
Show answer
</summary>

Navigate the script `02_stakeholder_package_setup.R` within the
Stakeholder Analysis module.

</details>

**Learning Check 3.** How does the guide ask you to connect the
highlighted topic back to systems architecting?

<details>
<summary>
Show answer
</summary>

Connect the topic “R package installation checklist” to systems
architecting decisions.

</details>
