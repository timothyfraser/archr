# Script: 12_enumeration_scenarios.R
# Original: example_enumeration.R
# Topic: Enumeration scenario examples
# Section: Enumeration
# Developed by: Timothy Fraser, PhD
library(dplyr)
library(tidyr)
library(archr)

# D1 = Service Provider = Google Cloud, AWS, or Digital Ocean {0,1,2}
# D2 = Dashboard Type =  ShinyApp or Dash App {0,1}
# D3.1 = Plot or Not {0, 1}
# D3.2 = Table or Not {0, 1}

enumerate_sf(n = 3)
enumerate_sf(n = 2)
enumerate_ds(n = 2, k = 2)

a = expand_grid(
  enumerate_sf(n = 3, .did = 1),
  enumerate_sf(n = 2, .did = 2),
  enumerate_ds(n = 2, k = 2, .did = 3)
)

a


# What if we add 1 constraint

# k = what's the max number of options you can choose simulataneously
# minimum number??
enumerate_ds(n = 2, k = 2, .did = 3) %>%
  mutate(count =  d3_1 + d3_2 ) %>%
  filter(count >= 1)

a = expand_grid(
  enumerate_sf(n = 3, .did = 1),
  enumerate_sf(n = 2, .did = 2),
  enumerate_ds(n = 2, k = 2, .did = 3) %>%
    mutate(count =  d3_1 + d3_2 ) %>%
    filter(count >= 1) %>%
    select(-count)
)

a






library(dplyr)
library(tidyr)
library(archr)
library(ggplot2)

# D1 = types of transport we can provide users = car, scooter, bike {0,1}
# D2 = outside companies we work with = uber, lyft, citibike
# D3 = How we process payment =  In our app or redirect to company/provider {0,1}

enumerate_ds(n = 5, k = 5, .did = 1) %>%
  filter((d1_1 + d1_2 + d1_3 + d1_4 + d1_5) > 0)
enumerate_sf(n = 3)
enumerate_ds(n = 2)

a = expand_grid(
  enumerate_ds(n = 5, k = 5, .did = 1) %>%
    filter((d1_1 + d1_2 + d1_3 + d1_4 + d1_5) > 0),
  enumerate_sf(n = 3, .did = 2),
  enumerate_ds(n = 2, k = 2, .did = 3)
)

a
