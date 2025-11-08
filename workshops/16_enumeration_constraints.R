# Script: 16_enumeration_constraints.R
# Original: tutorial_enumeration_3.R
# Topic: Enumeration with constraints
# Section: Enumeration
# Developed by: Timothy Fraser, PhD
#' @name tutorial_enumeration_3.R
#' @author Tim Fraser


library(dplyr)
library(readr)
library(tidyr)
library(archr)



# D1: Get a donut (Binary: 0, 1)?
decision1 = enumerate_binary(n = 1, .did = 1)
# D2a: Features on Donut (DS) (0,1, 0,1)
decision2a = enumerate_ds(n = 2, k = 2, .did = 2) %>%
  select(d2a_1 = d2_1, d2a_2 = d2_2) %>%
  mutate(d2b = 3)
# D2b: If not Donut, what other breakfast? (0,1,2,3)
decision2b = enumerate_sf(n = c(4), .did = 2) %>%
  select(d2b = d2) %>%
  mutate(d2a_1 = 0, d2a_2 = 0)

# NOT THIS!
# expand_grid(
#   decision1, decision2a, decision2b
# )

part1 = expand_grid(
  decision1 %>% filter(d1 == 0),
  decision2a
)

part2 = expand_grid(
  decision1 %>% filter(d1 == 1),
  decision2b
)


arch = bind_rows(
  part1, part2
)


# Full Factorial Enumeration with Dependent Decisions!








