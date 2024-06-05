#' @name tutorial_enumeration_4.R
#' @author Tim Fraser

# What if we need to do full factorial enumeration?
library(dplyr)
library(tidyr)
library(archr)
library(purrr)

# Enumeration #########################

## The `tidyr` way ########################
expand_grid(
  eor = c("no" = 0, "yes" = 1),
  earth_launch = c("orbit" = 0, "direct" = 1),
  fuel = c("cryogenic" = 0, "storable" = 1, "N/A" = 2)
)

c("no" = 0, "yes" = 1)
c(0, 1)

## The `archr` way ########################
enumerate_sf(n = c(2,2,3))



## The `base-R for-loop` way ########################

# What if we need to do full factorial enumeration?
# but we don't have our handy tools like archr?
# Well, this is what it would look like!

# Alternatives for each decision
eor = c("no" = 0, "yes" = 1)
earth_launch = c("orbit" = 0, "direct" = 1)
fuel = c("cryogenic" = 0, "storable" = 1, "N/A" = 2)
# total decisions = 3

# List to contain the architectures
archs = list()
# Counter for the number of architectures
n_archs = 0

# For decision 1...
for(i in eor){
  # For decision 2...
  for(j in earth_launch){
    # For decision 3...
    for(k in fuel){
      n_archs = n_archs + 1
      # Add this vector to the list in the n_archs-th spot
      archs[[n_archs]] <- c(i,j,k)
    }
  }
}

# Let's look at this weird list object archs
archs

# Binding Lists #################

# Might be helpful to bind these all together 
# into a matrix or data.frame, right?

## the base-R way... ######################
# Turn each item into a matrix, the bind the rows together
do.call(rbind, lapply(archs, matrix, ncol = 3))

## the purrr way.... ############

library(dplyr)
library(purrr)

# We can use the purrr package for that.
# We could say, for each item in this list archs,
archs %>%
  # map to that item the function, matrix and as_tibble
  purrr::map(~matrix(., ncol = 3) %>% as_tibble()) %>%
  # and then bind those many data.frames into one
  dplyr::bind_rows()

# clear environment
rm(list = ls())


# Parallel ADGs ##############################

# Parallel ADGs is the idea that for SOME decisions,
# the order we make the decisions in does not matter.

# For example...
# say we make 1 standard form decision then 2 binary decisions
arch1 = expand_grid(
  enumerate_sf(n = 3, .did = 1),
  enumerate_binary(n = 2, .did = 2)
)
arch1


# say we make 2 binary decisions then 1 standard form decisions
arch2 = expand_grid(
  enumerate_binary(n = 2, .did = 1),
  enumerate_sf(n = 3, .did = 3)
)

arch2

# Still produces the same number of architectures
nrow(arch1) == nrow(arch2)



# But then suppose that there's a dependency constraint in the next decision...
# where if the standard form decision == 2,
# then decision 4 != 0
arch3 = expand_grid(
  enumerate_sf(n = 3, .did = 1),
  enumerate_binary(n = 2, .did = 2),
  enumerate_sf(n = 2, .did = 4)
) %>%
  # Cut the rows where these conditions are true.
  filter( !(d1 == 2 & d4 == 0) )

arch3



# That matters! Be sure to do THAT in sequence before adding more decisions.
# Eg.
arch4 = expand_grid(arch3, enumerate_binary(n = 4, .did = 5))

# Or in total...
arch5 = arch1 = expand_grid(
  enumerate_sf(n = 3, .did = 1),
  enumerate_binary(n = 2, .did = 2)
) %>%
  # Add some more decisions
  expand_grid(., enumerate_sf(n = 2, .did = 4)) %>%
  # Cut the rows where these conditions are true.
  filter( !(d1 == 2 & d4 == 0) ) %>%
  # Add in one more decision
  expand_grid(., enumerate_binary(n = 4, .did = 5))

arch5
# See, if we change the order of the first sf and binary decisions,
# doesn't change anything
arch6 = arch1 = expand_grid(
  enumerate_binary(n = 2, .did = 2),
  enumerate_sf(n = 3, .did = 1)
) %>%
  # Add some more decisions
  expand_grid(., enumerate_sf(n = 2, .did = 4)) %>%
  # Cut the rows where these conditions are true.
  filter( !(d1 == 2 & d4 == 0) ) %>%
  # Add in one more decision
  expand_grid(., enumerate_binary(n = 4, .did = 5))

# Still makes same number of architectures.
nrow(arch5) == nrow(arch6)

# Clean up!
rm(list = ls())
