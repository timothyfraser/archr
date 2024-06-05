#' @name tutorial_tradespace_5.R
#' @author 
#' @description 
#' Intro to Entropy - may help with your final homework.
#' 

# 0. SETUP ################################
# Load functions_entropy.R for h(), j(), i(), and ig()
source("workshops/functions_entropy.R")

# 1. FUNCTIONS ##################################

## h(x) = entropy ########################

# Compute the entropy of a random variable
# that takes values 1,2, or 3 with equal probability
h(x = c(0.33333, 0.33333, 0.33333))
h(x = c(0.5, 0.4, 0.1))




#' Say we have feature two features `f1` and `f2`, 
#' each with 2 possible values (`"A"` or `"B"`)
#' Their probability distributions `p` might look like this.
features = tibble(
  # Here's feature 1 and its probabilities
  f1 = c("A", "B"),
  p1 = c(0.50, 0.50),
  # Here's feature 2 and its probabilities
  f2 = c("A", "B"),
  p2 = c(0.99, 0.01)
)  

features


# Which feature has more information? 
# The one that is harder to guess.
# This 'information' can be measured with entropy 
# using our h(x) function.

# as expected, f1 has higher entropy that f2
h(x = features$p1) 
h(x = features$p2)

## h(x,y) Joint Entropy ################################

# If X and Y are **independent** random variables
# and they usually should be if you're comparing two features
# then p(x,y) = p(x) * p(y)

# This means that you can just multiply together 
# the probabilities as your input
j(xy = features$p1 * features$p2)

## i(x,y) Mutual Information ###############################
# How much can I learn about X if I only have Y?

# Mutual Information
i(x = features$p1, y = features$p2, xy = features$p1 * features$p2)


## ig Information Gain #############################
# Weighted average reduction in entropy across subgroups
# Weighted by fraction of architectures in given subgroup

# We can use the ig() function


# Suppose we have a sample of architectures
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



# Calculate baseline entropy given no feature split
ig(good = a$good)

# Calculate entropy after feature split, and information gain from it
ig(good = a$good, feature = a$f)

# Get list of components to check your work
ig(good = a$good, feature = a$f, .all = TRUE)

# 2. APPLICATIONS #################################

# Compare decisions!
# Run these scripts
# getting a data.frame of architectures `archs`
# with `cost`, `benefit`, and `risk` metrics
source("workshops/example_metrics.R")
# Load pareto_rank() function
source("workshops/functions_pareto_rank.R")

# Entropy is useful when we take architectures 
# and threshold them by their metrics.
# It requires 2 binary varibles:
#   - is that architecture good (TRUE/FALSE)
#   - does that architecture have a certain feature (TRUE/FALSE)

# Is that architecture good?
archs = archs %>%
  # Get pareto rank
  mutate(rank = pareto_rank(cost, -benefit)) %>%
  # Mark architectures as 'good' if their pareto rank is less than 5
  # Make sure you justify what rank you choose as your threshold
  mutate(good = rank < 5)


# Does that architecture have a certain feature?
archs = archs %>%
  mutate(feature = case_when(d4 == 1 & d5 == 1 ~ TRUE, TRUE ~ FALSE)) 

archs %>% glimpse()

# Check information gain from this feature
ig(good = archs$good, feature = archs$feature)


# Check information gain from lots of features
# in this case we'll count each decision as a feature, as an example
archs %>%
  select(d1:d5, good) %>%
  pivot_longer(cols = c(d1:d5), names_to = "type", values_to = "feature") %>%
  group_by(type) %>%
  summarize(ig(good = good, feature = feature))

# Which feature reduces entropy the most (ig)?
# Which feature produces smallest average entropy (h_split)?
# This is an important feature!



