#' @name Module tutorial_enumeration_1.R

# Load packages
library(dplyr) # data wrangling
library(readr) # read_csv etc.
library(tidyr) # expand_grid(), etc.
library(archr) # enumerate_binary(), etc.

# enumerate_binary()
# enumerate_sf()
# enumerate_ds()
# enumerate_permutation()
# enumerate_partition()
# enumerate_assignment()
# enumerate_adjacency()

# Let's try out some of our enumeration functions from archr!

# How would we make binary decisions?
enumerate_binary(n = 2)
enumerate_binary(n = 2, .id = TRUE)
enumerate_binary(n = 4)
enumerate_binary(n = 16)

# How many rows (architectures) in a 16-binary-decision architectural space?
enumerate_binary(n = 16) %>% nrow()

# What about standard form decisions?
enumerate_sf(n = c(2, 3))
enumerate_sf(n = c(2, 3, 4))
enumerate_sf(n = c(2, 3, 4), .id = TRUE)

# How about downselecting? 
# n is the number of choices, k is the MAX number of items you can select.
enumerate_ds(n = 2, k = 1)
enumerate_ds(n = 2, k = 1)
enumerate_ds(n = 5, k = 3)

# Want to check the documentation? Use ?function_name or ?package_name::function_name
# It will show up in the 'Help' menu
# Works for ANY package. Most of archr's functions have at least some documentation.
?enumerate_ds
# Try it for mutate!
?dplyr::mutate

# Can we replicate enumerate_binary() using dplyr and tidyr functions?
# Yes! expand_grid() is a magical function that builds a grid of every possible combination of the items you supply it.
expand_grid(
  tibble(d1 = c(0, 1)),
  tibble(d2 = c(0, 1))
)
# Compare with enumerate_binary() - it's the same!
enumerate_binary(n = 2)

# Can work for standard form too.
expand_grid(
  tibble(d1 = c(0, 1)),
  tibble(d2 = c(0, 1, 2))
)
# Check it!
enumerate_sf(n = c(2,3))

# Can also do creative combinations like this,
# which replicates the d2-d3 data.frame for each item in the d1 data.frame
expand_grid(
  tibble(d1 = c(0, 1)),
  tibble(d2 = c(0, 0, 0),
         d3 = c(0, 2, 3))
)


# More flexible usage!
expand_grid(
  enumerate_binary(n = 2),
  # You'll need to 'rename' your columns to avoid errors
  enumerate_sf(n = c(2,3)) %>% select(d3 = 1, d4 = 2)
)

# More next week!