# tutorial_enumeration_8.R


# Activity 1 ##########################################

library(dplyr)
library(tidyr)

# Get full factorial grid of combinations
grid = expand_grid(
  # Catalyst K
  k = c("A", "B"),
  # Concentration C
  c = c(20, 40),
  # Temperature t
  t = c(160, 180),
) %>%
  # order columns as shown in the example...
  mutate(run = 1:n()) %>%
  select(run, t, c, k)

# We run the experiment once and get these results
data = grid %>% mutate(y = c(60,72,54,68,52,83,45, 80))

# Calculate the direct (one-way) treatment effects
data %>%
  summarize(
    dbar_c = mean( y[c==40] - y[c==20] ),
    dbar_t = mean( y[t== 180] - y[t==160] ),
    dbar_k = mean( y[k== "B"] - y[k=="A"] )
  )



# Activity 2 ######################################

# Calculate the two-way treatment effects
data %>%
  reframe(
    xbar1 = y[ (t==180 & k=="B") | (t==160& k=="A") ] %>% mean(),
    xbar0 = y[ (t==160 & k=="B") | (t==180& k=="A")] %>% mean(),
    dbar = xbar1 - xbar0
  )


# Activity 3 ###################################



#' @name get_minsize
#' @title Get Minimum Number of Architectures to test Main Effects
#' @param data data.frame of enumerated architectures, where columns are decisions and values are alternatives
#' @param decisions:[str] string vector of decisions you want to test main effects for. Defaults to 1.
#' @importFrom dplyr `%>%` select any_of summarize everything across
#' @importFrom tidyr pivot_longer
get_minsize = function(data, decisions = c("d1")){
  library(dplyr)
  library(tidyr)
  
  data %>%
    select(any_of(decisions)) %>%
    # Count up k, the number of unique alternatives per decision
    summarize(across(everything(), .fns = ~length(unique(.x)))) %>%
    # Pivot it longer
    tidyr::pivot_longer(
      cols = everything(), 
      names_to = "k", values_to = "value") %>%
    # Count up the minimum number of architectures necessary to test
    # that number of main effects
    summarize(minsize = 1 + sum(value - 1)) %>%
    # Return it as a vector
    with(minsize)        
}



library(dplyr)
library(tidyr)
library(archr)

a = enumerate_sf(n = c(2,5,4))

# to count sample size needed...
get_minsize(a, decisions = c("d1"))
get_minsize(a, decisions = c("d1", "d2"))
get_minsize(a, decisions = c("d1", "d2", "d3"))


rm(list = ls())
