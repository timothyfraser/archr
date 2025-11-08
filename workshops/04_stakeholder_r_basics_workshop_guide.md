This tutorial complements `04_stakeholder_r_basics_workshop.R` and
unpacks the workshop on workshop 1 r fundamentals. You will see how it
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

- Navigate the script `04_stakeholder_r_basics_workshop.R` within the
  Stakeholder Analysis module.
- Connect the topic “Workshop 1 R fundamentals” to systems architecting
  decisions.
- Install any required packages highlighted with `install.packages()`.
- Load packages with `library()` and verify they attach without
  warnings.
- Import data files with `readr` helpers and inspect the resulting
  objects.
- Export results to disk so you can reuse them across workshops.
- Chain tidyverse verbs with `%>%` to explore stakeholder or
  architecture tables.
- Define custom functions to package repeatable logic.

## Process Overview

``` mermaid
flowchart LR
    A[Try Arithmetic] --> B[Clear Objects]
    B[Clear Objects] --> C[Practice the Pipe]
    C[Practice the Pipe] --> D[Clear Objects (Step 84)]
```

## Application

### Step 1 – Try Arithmetic

addition. Evaluate a quick arithmetic expression to observe R’s console
output.

``` r
1 + 1
```

### Step 2 – Create `x`

make object ‘x’. Create the object `x` so you can reuse it in later
steps.

``` r
x = 2
```

### Step 3 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
x + 2
```

### Step 4 – Create `y`

make new objects. Create the object `y` so you can reuse it in later
steps.

``` r
y = x + 2
y
```

### Step 5 – Remove Objects

Remove specific objects. Delete specific objects so you can redefine
them cleanly.

``` r
remove(x,y)
# Clear everything all at once
rm(list = ls())
```

### Step 6 – Install Packages

Install. Install dplyr, readr, ggplot2 so the rest of the workshop can
run.

``` r
install.packages(c("dplyr", "readr", "ggplot2"))
```

### Step 7 – Load Packages

Load packages. Attach dplyr to make its functions available.

``` r
library(dplyr)
library(readr)
library(ggplot2)
```

### Step 8 – Create `myvec`

Create the object `myvec` so you can reuse it in later steps.

``` r
myvec = c(1,2,3,4)
```

### Step 9 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
myvec
```

### Step 10 – Create `myrow`

Create the object `myrow` so you can reuse it in later steps.

``` r
myrow = matrix( c(1,2,3,4), nrow = 1)
```

### Step 11 – Create `mycol`

Create the object `mycol` so you can reuse it in later steps.

``` r
mycol = matrix( c(1,2,3,4), ncol = 1)
```

### Step 12 – Create a Matrix

Create a matrix to practice element-wise and matrix operations.

``` r
matrix(c(myrow, myrow, myrow), byrow = TRUE, ncol = 4)
```

### Step 13 – Create a Matrix

Create a matrix to practice element-wise and matrix operations.

``` r
matrix(c(mycol, mycol, mycol), byrow = FALSE, ncol = 3)
```

### Step 14 – Build a Data Frame

Construct a small data frame that you can manipulate later.

``` r
data.frame(
  x = c(1,2,3),
  y = c("corgi", "dalmatian", "goldendoodle"),
  z = c(1, 2, "3")
)
```

### Step 15 – Create a Matrix

Create a matrix to practice element-wise and matrix operations.

``` r
matrix(c(1,2,3, 4,5,6, 7,8,9), byrow = TRUE, nrow = 3, ncol = 3)
```

### Step 16 – Create `mymat3`

Create the object `mymat3` so you can reuse it in later steps.

``` r
mymat3 = matrix(
  # put comments inside of these chunks
  c(1,2,3, 
    4,5,6, 
    7,8,9), 
  # settings
  byrow = TRUE, nrow = 3, ncol = 3)
```

### Step 17 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
mymat3^2
```

### Step 18 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
mymat3*2
```

### Step 19 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
mymat3 + mymat3
```

### Step 20 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
mymat3 %*% mymat3
```

### Step 21 – Create `day`

Create the object `day` so you can reuse it in later steps.

``` r
day = c("M", "T", "W", "R", "F")
temp = c(30, 20, 25, 27, 29)
t = data.frame(day, temp)
```

### Step 22 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
t$day
t$temp + 2
```

### Step 23 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
t$temp
```

### Step 24 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
t$temp = t$temp + 2
```

### Step 25 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
t$snow = c("yes", "no", "yes", "no", "no")
```

### Step 26 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
t$rain = c("yes", "no", "no", "no", NA)
```

### Step 27 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
t[1:3, 2]
```

### Step 28 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
mymat3[1, 2:3]
```

### Step 29 – Clear Objects

Remove objects from the environment to prevent name clashes.

``` r
rm(list = ls())
```

### Step 30 – Import CSV Data

Load workshops/04_stakeholder_test_data.csv into a tibble you can
explore in R.

``` r
t = readr::read_csv("workshops/04_stakeholder_test_data.csv")
```

### Step 31 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
t$id
t$coffees
t$sale
```

### Step 32 – Import RDS Data

.rds - r data storage.

``` r
m = readr::read_rds("workshops/04_stakeholder_test_data.rds")
```

### Step 33 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
m
```

### Step 34 – Save Data to CSV

Export a tibble to workshops/04_stakeholder_test_data2.csv for later
use.

``` r
readr::write_csv(t, file = "workshops/04_stakeholder_test_data2.csv")
```

### Step 35 – Save Data to CSV

Export a tibble to workshops/04_stakeholder_test_data2.csv for later
use.

``` r
write_csv(t, file = "workshops/04_stakeholder_test_data2.csv")
```

### Step 36 – Save Data to RDS

Store an object as workshops/04_stakeholder_test_data2.rds to preserve
its structure.

``` r
write_rds(as.matrix(t), file = "workshops/04_stakeholder_test_data2.rds")
```

### Step 37 – Clear Objects

Remove objects from the environment to prevent name clashes.

``` r
rm(list = ls())
```

### Step 38 – Define `plusone()`

Create the helper function `plusone()` so you can reuse it throughout
the workshop.

``` r
plusone = function(inputs){ output = inputs; output }
plusone = function(inputs){ output = inputs; return(output) }
plusone = function(inputs){ 
  output = inputs;
  output 
}
```

### Step 39 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
plusone(inputs = 2)
```

### Step 40 – Remove Objects

Delete specific objects so you can redefine them cleanly.

``` r
remove(plusone)
```

### Step 41 – Define `plusone()`

Create the helper function `plusone()` so you can reuse it throughout
the workshop.

``` r
plusone = function(x){  y = x + 1; return(y)   }
plusone(x = 2)
plusone(x = c(2,3))
```

### Step 42 – Define `plustwo()`

Create the helper function `plustwo()` so you can reuse it throughout
the workshop.

``` r
plustwo = function(x){  y = x + 2; return(y)  } 
plustwo(x = c(2,3))
```

### Step 43 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
plustwo(plusone(x = 1))
library(dplyr)
```

### Step 44 – Practice the Pipe

pipeline. Use the `%>%` operator to pass each result to the next
tidyverse verb.

``` r
%>%
%>%
```

### Step 45 – Practice the Pipe

shortcut: ctl shift m.

``` r
%>% %>% %>% %>% %>% %>% %>% %>% %>% %>% %>% %>% %>% %>%
```

### Step 46 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
1 %>% plusone()
```

### Step 47 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
1 %>% plusone(x = .)
```

### Step 48 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
1 %>% plusone() %>% plustwo()
```

### Step 49 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
1 %>% 
  plusone() %>%
  plustwo()
```

### Step 50 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
1 %>% 
  # Take 1 and use plusone() on it
  plusone() %>%
  # Now take the output and use plustwo() on it
  plustwo()
```

### Step 51 – Create `sh`

Let’s make a table including…

``` r
sh = tibble(
  # name of stakeholder
  name = c("Project", "Company", 
           "Regulator", "Government", "Residents"),
  # type of stakeholder
  type = c("Beneficiary", "Beneficiary", "Problem", "Beneficiary", "Charitable"),
  # number of value cycles they are a part of
  cycles = c(3, 4, 2, 2, 2)
)
```

### Step 52 – Run the Code Block

stakeholders. Execute the block and pay attention to the output it
produces.

``` r
sh
```

### Step 53 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 = sh %>%
  mutate(value = c(NA, 0.3, 0.5, 0.3, 0.8))
```

### Step 54 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  summarize(total_value = sum(value, na.rm = TRUE))
```

### Step 55 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
summarize(sh2, total_value = sum(value, na.rm = TRUE))
```

### Step 56 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2$value %>% sum(na.rm = TRUE)
```

### Step 57 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  summarize(
    total_value = sum(value, na.rm = TRUE),
    count = n())
```

### Step 58 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  group_by(type) %>%
  summarize(total_value = sum(value, na.rm = TRUE))
```

### Step 59 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  group_by(type) %>%
  summarize(total_value = sum(value, na.rm = TRUE),
            count = n())
```

### Step 60 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  group_by(type)
```

### Step 61 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  group_by(type) %>%
  summarize(total_value = sum(value, na.rm = TRUE),
            count = n()) %>%
  ungroup()
```

### Step 62 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  group_by(type) %>%
  summarize(total_value = sum(value, na.rm = TRUE),
            count = n())
```

### Step 63 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
seq(from = min(sh2$value, na.rm = TRUE),
    to = max(sh2$value, na.rm = TRUE),
    by = 0.1)
```

### Step 64 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  reframe(
    range = seq(from = min(value, na.rm = TRUE),
                to = max(value, na.rm = TRUE),
                by = 0.1)
  )
```

### Step 65 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  select(name, value)
```

### Step 66 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  select(group = name)
```

### Step 67 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  slice(2)
```

### Step 68 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  slice(c(1,2))
```

### Step 69 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  slice(-c(1,2))
```

### Step 70 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
sh2[-c(1,2), ]
```

### Step 71 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  filter(value > 0.5)
```

### Step 72 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>% 
  filter(value > 0.5 |  type == "Problem")
```

### Step 73 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>% 
  filter(value >= 0.5)
```

### Step 74 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  filter(is.na(value))
```

### Step 75 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  filter(!is.na(value))
```

### Step 76 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  arrange(value)
```

### Step 77 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  arrange(desc(value))
```

### Step 78 – Create `stats`

Lets make our stats table.

``` r
stats = tibble(
  type = c("Beneficiary", "Charitable", "Problem"),
  total = c(1.4, 1.8, 0.9)
)
```

### Step 79 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
stats
```

### Step 80 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
sh2
```

### Step 81 – Run the Code Block

Execute the block and pay attention to the output it produces.

``` r
left_join(x = sh2, y = stats, by = "type")
```

### Step 82 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  left_join(y = stats, by = "type")
```

### Step 83 – Practice the Pipe

Use the `%>%` operator to pass each result to the next tidyverse verb.

``` r
sh2 %>%
  left_join(by = "type", y = stats) %>%
  mutate(importance = value / total) %>%
  filter(!is.na(importance)) %>%
  group_by(type) %>%
  summarize(avg = mean(importance)) %>%
  arrange(desc(avg))
```

### Step 84 – Clear Objects

Remove objects from the environment to prevent name clashes.

``` r
rm(list = ls())
```

## Learning Checks

**Learning Check 1.** Which packages do you install in Step 6, and what
must you verify before moving on?

<details>
<summary>
Show answer
</summary>

Step 6 installs dplyr, readr and ggplot2, so make sure each package
finishes installing without errors before continuing.

</details>

**Learning Check 2.** What role does the helper `plusone()` defined in
Step 38 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 3.** What role does the helper `plustwo()` defined in
Step 42 play in this workflow?

<details>
<summary>
Show answer
</summary>

It packages reusable logic needed by later steps.

</details>

**Learning Check 4.** Which libraries does Step 7 attach, and why do you
run that chunk before others?

<details>
<summary>
Show answer
</summary>

It attaches dplyr, readr and ggplot2, ensuring their functions are
available before you execute the downstream code.

</details>
