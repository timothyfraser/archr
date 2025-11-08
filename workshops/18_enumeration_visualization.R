# Script: 18_enumeration_visualization.R
# Original: tutorial_enumeration_5.R
# Topic: Visualization of enumeration results
# Section: Enumeration
# Developed by: Timothy Fraser, PhD
#' @name tutorial_enumeration_5.R
#' @author Tim Fraser

# Load packages
library(dplyr)
library(tidyr)
library(ggplot2)
library(archr)

# What happens when we CAN'T enumerate the whole architecture space?
# Eg. computational limitations, 
# OR
# we're trying to run tests, but we can't do the whole thing!

# Our random samples need to meet 3 criteria:
# 1. be **big enough** overall (eg. n = 10,000)
# 2. be **big enough** within each group (eg. n = 100 per strata)
# 3. be evenly balanced (eg. no traits are disproportionately represented)
# Let's learn how.

# SAMPLING #########################


# Suppose you have a decision, 
# but you can only **sample 2 out of 4 alternatives.**
# You can use sample_n() from dplyr for that.
enumerate_sf(n = c(4)) %>%
  sample_n(size = 2)

# sample_n(tbl = ., size = 2, replace = FALSE)




# The most common case where you'll run into this is...
# You can easily enumerate the whole architectural space,
# BUT
# you can't run optimization on the whole space,
# so you need to run optimization on a smaller sample.

# Here's what you'd do.


# If you can, always try to enumerate the whole architectural space first.

# eg.

# Get your full architectural space
arch = expand_grid(
  enumerate_sf(n = c(2,4,3), .did = 1),
  enumerate_ds(n = 3, k = 2, .did = 4),
  enumerate_permutation(n = 8, k = 4, .did = 5)
)

arch %>% glimpse()

## BY ROW #####################

# You can take a random sample directly,
# but it may cause issues - always important to check representativeness.
mini = arch %>%
  sample_n(size = 10000)

mini

## BY DECISION #########################

# Or, we could sample after each consecutive decision.
# This has trade-offs too.
# Eg. enumerate your matrix, then after each stage, sample, then continue.

part1 = expand_grid(
  enumerate_sf(n = 2, .did = 1),
  enumerate_sf(n = 4, .did = 2) 
) %>%
  # For each alternative in d1, 
  # sample 2 alternatives from d2
  group_by(d1) %>%
  sample_n(size = 2)  %>%
  ungroup()


part2 = part1 %>%
  # Get the full grid of those options and
  # ALL options from d3
  expand_grid(enumerate_sf(n = 3, .did = 3)) %>%
  # for each alternative in d1 and d2,
  # sample 2 alternatives from d3
  group_by(d1,d2) %>%
  sample_n(size = 2) %>%
  ungroup()

part3 = part2 %>%
  # Expand out for d4...
  expand_grid(enumerate_ds(n = 3, k = 2, .did = 4)) %>%
  # For each set of d1,d2, and d3,
  # sample 5 possible outcomes from d4
  group_by(d1,d2,d3) %>%
  sample_n(size = 5)

part4 = part3 %>%
  # Expand out for d5...
  expand_grid(enumerate_permutation(n = 8, k = 4, .did = 5)) %>%
  # For each set of d1,d2,d3,and d4_1,d4_2,d4_3,
  # sample 25 possible outcomes from d5
  # You can write it easily using 'across(start:end)'
  #group_by(d1,d2,d3,d4_1,d4_2,d4_3) %>%
  group_by(across(d1:d4_3)) %>%
  sample_n(size = 25) %>%
  ungroup()
  

# Not too terrible to code, right?

# What are some downfalls to this method?
# Can you think of a better way to enumerate?
# What would you need to do?





## BY STRATA ###################
# For each strata (a set of unique d1-d2-d3-d4_1-d4_2-d4_3 values)
# sample 25 rows (akin to grabbing 25 paths)
arch %>%
  group_by(across(d1:d4_3)) %>%
  sample_n(size = 25)






## BY PATH #####################

arch %>%
  mutate(s1 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s2 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s3 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s4_1 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s4_2 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s4_3 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s5_1 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s5_2 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s5_3 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  mutate(s5_4 = sample(x = c(TRUE, FALSE), size = n(), replace = TRUE)) %>%
  # Grab just the paths that were selected...
  filter( s1 == TRUE & s2 == TRUE & s3 == TRUE,
          s4_1 == TRUE & s4_2 == TRUE & s4_3 == TRUE,
          s5_1 == TRUE &  s5_2 == TRUE & s5_3 == TRUE & s5_4 == TRUE)

# The best sampling procedure will use a **nested for loop.**


library(dplyr)
library(archr)

data = enumerate_sf(n = c(2, 4, 3))

a = data %>%
  sample_n(size = 3)

a # view it

b = data %>%
  group_by(d1) %>%
  sample_n(size = 3)

b # view it

c = data %>%
  group_by(d1, d2) %>%
  sample_n(size = 3)

c # view it



# REPRESENTATIVENESS ######################################
# Let's test the representativeness of our sample.

# For the moment though, let's just take 10000 samples,
# just as a demonstration
mini = arch %>%
  sample_n(size = 10000)


## ONE DECISION ################

# Let's look at decision 1

# Let's get the count of population traits...
arch %>%
  group_by(d1) %>%
  summarize(count = n())

pop = arch %>%
  group_by(did = "d1", altid = d1) %>%
  summarize(count = n())

# Let's get the count of the sample traits...
sample = mini %>%
  group_by(did = "d1", altid = d1) %>%
  summarize(count = n())


# Let's stack them together and label by type...
stat = bind_rows(
  pop %>% mutate(type = "pop"),
  sample %>% mutate(type = "sample")
)



# Finally, let's turn those counts into percentages
stat = stat %>%
  # For each type and decision id...
  group_by(type, did) %>%
  mutate(total = sum(count),
         percent = count / total,
         label = round(percent * 100, 1),
         label = paste0(label, "%"))

stat

ggplot() +
  geom_col(data = stat %>% filter(type == "pop"), 
           mapping = aes(x = factor(altid), y = percent))
  
ggplot() +
  geom_col(data = stat %>% filter(type == "pop"), 
           mapping = aes(x = factor(altid), y = percent)) + 
  scale_y_continuous(limits = c(0, 1)) 

ggplot() +
  geom_col(data = stat, 
           mapping = aes(x = factor(altid), y = percent)) + 
  scale_y_continuous(limits = c(0, 1))  +
  facet_wrap(~type)


ggplot() +
  geom_col(data = stat,
           mapping = aes(x = factor(altid), y = percent)) + 
  geom_text(data = stat, 
            mapping = aes(x = factor(altid), y = percent + 0.05, label = label)) +
  scale_y_continuous(limits = c(0, 1))  +
  facet_wrap(~type) +
  labs(x = "Alternatives", y = "Percent (%)",
       title = "Decision 1")








# And let's visualize it!
ggplot() +
  geom_col(data = stat, mapping = aes(x = altid, y = percent)) +
  geom_text(data = stat, mapping = aes(x = altid, y = percent, label = label), 
            nudge_y = 0.1) +
  facet_wrap(~type) +
  # Let's make this look a lot clearer
  scale_y_continuous(breaks = c(0, 0.25, 0.5, 0.75, 1), limits = c(0,1))



## MANY DECISIONS #########################

# But what if we need to compare a LOT of decisions?
# It's going to be easiest for us if we write ourselves a function.

# get_percentages = function(x){ return(percentages) }
# get_percentages(x = mini$d1)

get_percentages = function(x){ 
  # x = mini$d1 
  tally = tibble(altid = x) %>%
    group_by(altid) %>%
    summarize(count = n())
  return(tally) 
}



get_percentages(x = mini$d1)


get_percentages = function(x, did = "d1"){ 
  # x = mini$d1 
  tally = tibble(altid = x) %>%
    group_by(altid) %>%
    summarize(count = n())
  
  tally = tally %>% 
    mutate(did = did)
  
  return(tally) 
}

get_percentages(x = mini$d2, did = "d2")

get_percentages = function(x, did = "d1"){ 
  # x = mini$d1 
  tally = tibble(altid = x) %>%
    group_by(altid) %>%
    summarize(count = n())
  
  tally = tally %>% 
    mutate(did = did)
  
  percentages = tally %>% 
    mutate(total = sum(count)) %>%
    mutate(percent = count / total)
  
  return(percentages) 
}



get_percentages(x = mini$d2, did = "d2")







get_percentages = function(x, did = "d2"){
  # Testing values
  #x = mini$d2

  # Get the tally per alternative  
  tally = tibble(altid = x) %>%
    group_by(altid) %>%
    summarize(count = n())
  # Calculate percentages
  percentages = tally %>% 
    mutate(total = sum(count)) %>%
    mutate(percent = count / total) %>%
    mutate(label = round(percent * 100, 1)) %>%
    mutate(label = paste0(label, "%"))
  # Add a decision id and format
  percentages = percentages %>% 
    mutate(did = did) %>%
    select(did, altid, count, total, percent, label)
  
  return(percentages)
}

get_percentages(x = mini$d2, did = "d2")
# You can also do it like this...
mini %>% with(d1) %>% get_percentages(did = "d1")



# We even do a bunch, and bind them atop each other.
# For example, here's the sample
stat2 = bind_rows(
  get_percentages(x = mini$d1, did = "d1"),
  get_percentages(x = mini$d2, did = "d2"),
  get_percentages(x = mini$d3, did = "d3"),
  get_percentages(x = mini$d4_1, did = "d4_1"),
  get_percentages(x = mini$d4_2, did = "d4_2"),
  get_percentages(x = mini$d4_3, did = "d4_3"),
  get_percentages(x = mini$d5_1, did = "d5_1"),
  get_percentages(x = mini$d5_2, did = "d5_2"),
  get_percentages(x = mini$d5_3, did = "d5_3"),
  get_percentages(x = mini$d5_4, did = "d5_4")
)

stat2


## MANY, MANY DECISIONS ##############################

# We could even do the whole thing at once, 
# for both sample and population
stat3 = bind_rows(
  bind_rows(
    get_percentages(x = mini$d1, did = "d1"),
    get_percentages(x = mini$d2, did = "d2"),
    get_percentages(x = mini$d3, did = "d3"),
    get_percentages(x = mini$d4_1, did = "d4_1"),
    get_percentages(x = mini$d4_2, did = "d4_2"),
    get_percentages(x = mini$d4_3, did = "d4_3"),
    get_percentages(x = mini$d5_1, did = "d5_1"),
    get_percentages(x = mini$d5_2, did = "d5_2"),
    get_percentages(x = mini$d5_3, did = "d5_3"),
    get_percentages(x = mini$d5_4, did = "d5_4")
  ) %>%
    mutate(type = "sample"),
  bind_rows(
    get_percentages(x = arch$d1, did = "d1"),
    get_percentages(x = arch$d2, did = "d2"),
    get_percentages(x = arch$d3, did = "d3"),
    get_percentages(x = arch$d4_1, did = "d4_1"),
    get_percentages(x = arch$d4_2, did = "d4_2"),
    get_percentages(x = arch$d4_3, did = "d4_3"),
    get_percentages(x = arch$d5_1, did = "d5_1"),
    get_percentages(x = arch$d5_2, did = "d5_2"),
    get_percentages(x = arch$d5_3, did = "d5_3"),
    get_percentages(x = arch$d5_4, did = "d5_4")
  ) %>%
    mutate(type = "pop")
)

# Check it!
stat3

# For our first decision, in our sample,
# [Alternative 1] (49.9%) was fairly evenly split 
# with [Alternative 0] (50.1%).


# Let's try and visualize that now!
ggplot() +
  geom_col(data = stat3, mapping = aes(x = factor(altid), y = percent)) +
  facet_wrap(type~did)


ggplot() +
  geom_col(data = stat3 %>% 
             filter(did %in% c("d1","d2","d3")), 
           mapping = aes(x = factor(altid), y = percent)) +
  facet_wrap(type~did)


## COMBINING PLOTS ###########################

# In situations like these, 
# it's going to be hard to make 1 perfect visual of all of them.
# I suggest making individual plots, and then binding them together.

# You can use the ggpubr package and its ggarrange() function for this
# install.packages("ggpubr")
library(ggpubr)


get_viz = function(data){
  gg = ggplot() +
    geom_col(
      data = data, 
      mapping = aes(x = factor(altid), y = percent))  +
    geom_text(
      data = data,
      mapping = aes(x = factor(altid), y = percent, label = label), 
      nudge_y = 0.1) +
    facet_wrap(~type) +
    # Let's make this look a lot clearer
    scale_y_continuous(breaks = c(0, 0.25, 0.5, 0.75, 1), limits = c(0,1)) 
  return(gg)
}

g1 = stat3 %>% filter(did == "d1") %>% get_viz()
g2 = stat3 %>% filter(did == "d2") %>% get_viz()
g3 = stat3 %>% filter(did == "d3") %>% get_viz()
# Then bundle them together
ggmany = ggpubr::ggarrange(g1,g2,g3, nrow = 1)

# And save to file with ggsave() from ggplot
ggsave(
  plot = ggmany,
  filename = "workshops/18_enumeration_visualization.png", 
  # You can optionally add a dots-per-inch (dpi)
  dpi = 200, 
  # as well as a width and height in inches
  width = 12, height = 5)


# Clean up!
rm(list = ls())









