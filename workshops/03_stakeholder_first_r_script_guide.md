This tutorial complements `03_stakeholder_first_r_script.R` and unpacks
the workshop on first r script practice. You will see how it advances
the Stakeholder Analysis sequence while building confidence with base R
and tidyverse tooling.

## Setup

- Ensure you have opened the `archr` project root (or set your working
  directory there) before running any code.
- Open the workshop script in RStudio so you can execute lines
  interactively with `Ctrl+Enter` or `Cmd+Enter`.
- Create a fresh R session to avoid conflicts with leftover objects from
  earlier workshops.

## Skills

- Navigate the script `03_stakeholder_first_r_script.R` within the
  Stakeholder Analysis module.
- Connect the topic “First R script practice” to systems architecting
  decisions.
- Document observations from running each code block in your lab
  notebook.

## Process Overview

``` mermaid
flowchart LR
    A[Try Arithmetic] --> B[Create myvec]
```

## Application

### Step 1 – Try Arithmetic

My first script. Evaluate a quick arithmetic expression to observe R’s
console output.

``` r
1 + 2 
x = 2
x
x + 2
c(2,3,4)
```

### Step 2 – Create `myvec`

Create the object `myvec` so you can reuse it in later steps.

``` r
myvec = c(1,2,3,4)
myvec
```

## Learning Checks

**Learning Check 1.** After Step 1, what does `x` capture?

<details>
<summary>
Show answer
</summary>

It creates `x`. My first script. Evaluate a quick arithmetic expression
to observe R’s console output.

</details>

**Learning Check 2.** After Step 2, what does `myvec` capture?

<details>
<summary>
Show answer
</summary>

It creates `myvec`. Create the object `myvec` so you can reuse it in
later steps.

</details>

**Learning Check 3.** Which script should you keep open while running
this guide?

<details>
<summary>
Show answer
</summary>

Navigate the script `03_stakeholder_first_r_script.R` within the
Stakeholder Analysis module.

</details>
