# Script: 15_enumeration_structures.R
# Original: tutorial_enumeration_2.R
# Topic: Enumeration of structures
# Section: Enumeration
# Developed by: Timothy Fraser, PhD
#' @name tutorial_enumeration_2.R
#' @author Tim Fraser

#' Continuing from `14_enumeration_foundations.R`, let's do some exercises with our other functions.


library(archr) # get enumerate_ functions
library(dplyr) # get pipeline
library(tidyr) # expand_grid()


# which instruments
enumerate_ds(n = 3, k = 3, .did = 1)

# packaging
enumerate_sf(n = c(5), .did = 2)

# scheduling
enumerate_sf(n = c(2), .did = 3)


# If no constraints...
expand_grid(
  # which instruments
  enumerate_ds(n = 3, k = 3, .did = 1),
  # packaging
  enumerate_sf(n = c(5), .did = 2),
  # scheduling
  enumerate_sf(n = c(2), .did = 3)
)


# which instruments
parta = expand_grid(
  enumerate_ds(n = 3, k = 3, .did = 1) %>%
    filter(d1_1 == 1),
  enumerate_sf(n = c(5), .did = 2) %>%
    filter(d2 != 4)
)


partb = expand_grid(
  enumerate_ds(n = 3, k = 3, .did = 1) %>%
    filter(d1_1 != 1),
  enumerate_sf(n = c(5), .did = 2)
)

# constrained architecture
constrained = bind_rows(parta, partb)

final = expand_grid(
  constrained,
  # scheduling
  enumerate_sf(n = c(2), .did = 3)
)

final
remove(final)


# 1. TRICKS #################################

# You can make headers using '# header ###'
# You can make subheaders using '## subheader ###'

# Use the menu button on the right hand side of 'Run' and 'Source' 
# to see this the table of contents you've created.

# Helps with long documents.

# header ####

## subheader ####




# 2. COMPLEX ENUMERATION FUNCTIONS ##################

## load packages #############################
# install.packages("workshops/archr_1.0.tar.gz", type = "source")
library(archr) # enumerate_....
library(dplyr) # summarize() filter() select()
library(readr) # read_csv() and write_csv()
library(ggplot2) # visuals
library(tidyr) # expand_grid()
# tidyverse suite of packages
# dplyr, readr, tidyr, purrr, ggplot2


## SIMPLE FUNCTIONS #########################

### binary ######################
# binary tree
enumerate_binary(n = 2)
enumerate_binary(n = 2, .id = TRUE)

### standard form ######################
# trees! 
enumerate_sf(n = c(2,2))
enumerate_binary(n = 2)
# Very helpful with many decisions 
# each with a different number of alternatives
enumerate_sf(n = c(2,3,8))

## COMPLEX FUNCTIONS #################

### downselecting ##################################
# Pick up to 4 out of 8 donuts
enumerate_ds(n = 8, k = 4)


enumerate_ds(n = 8, k = 4) %>%
  filter( !(d1_1 == 0 & d1_2 == 0 & d1_3 == 0 & d1_4 == 0 &
         d1_5 == 0 & d1_6 == 0 & d1_7 == 0 & d1_8 == 0)  )  


enumerate_ds(n = 8, k = 4) %>%
  # Make a 'counter' column
  mutate(count = d1_1 + d1_2 + d1_3 + d1_4 +
           d1_5 + d1_6 + d1_7 + d1_8) %>%
  # Cut any rows where count is 0
  filter(count >= 1) %>%
  # remove the count column
  select(-count)

# make a k-min and a k-max
enumerate_ds(n = 8, k = 8) %>%
  # Make a 'counter' column
  mutate(count = d1_1 + d1_2 + d1_3 + d1_4 +
           d1_5 + d1_6 + d1_7 + d1_8) %>%
  # Cut any rows where count is 0
  filter(count >= 1 & count <= 2) %>%
  # remove the count column
  select(-count)


# Can we do this with group_by?
enumerate_ds(n = 8, k = 8, .id = TRUE)  %>%
  group_by(id) %>%
  mutate(count = sum(c(d1_1, d1_2, d1_3, d1_4, d1_5, d1_6, d1_7, d1_8) ))


### assignment #####################################
?archr::enumerate_assignment
?enumerate_assignment
?dplyr::mutate
?mutate


enumerate_assignment(n = 4, m = 4, k = 1)
enumerate_assignment(n = 4, m = 4, k = 2)
enumerate_assignment(n = 4, m = 4, k = 4)
enumerate_assignment(n = 4, m = 4, k = 5)

arch = enumerate_assignment(n = 4, m = 5, k = 2)

mylist = archr::arch_to_assignment(arch = arch)

mylist$`1`
mylist$`2`
mylist$`3`
mylist$`4`

arch

remove(arch, mylist)

# Tim -- chocolate and vanilla
# Evenlyn --  blueberry
# Leo -- Chocolate

# Change decision number
enumerate_assignment(n = 4, m = 5, k = 2, .did = 3)

### permutation #####################################

enumerate_permutation(n = 4, k = 3)
enumerate_permutation(n = 4, k = 3, .did = 2)


### partitioning #####################################

enumerate_partition(n = 4, k = 2)
enumerate_partition(n = 4, k = 2, 
                    min_times = c(1,1),
                    max_times = c(3, 3))

### adjacency (connection) #####################################

enumerate_adjacency(n = 4, k = 1)
enumerate_adjacency(n = 4, k = 4*4)

enumerate_adjacency(n = 4, k = 4*4) %>% tail(1)

enumerate_adjacency(n = 4, k = 1, diag = FALSE)
enumerate_adjacency(n = 4, k = 1, diag = TRUE)

enumerate_adjacency(n = 4, k = 1, .did = 3)



# 3. CONSTRAINTS ##########################################

## using k ############################################

# function specific ways to constrain our architectures with a k argument
# k-max items you select or k-min items

## using filter() #####################################
enumerate_ds(n = 8, k = 4) %>%
  filter( !(d1_1 == 0 & d1_2 == 0 & d1_3 == 0 & d1_4 == 0 &
              d1_5 == 0 & d1_6 == 0 & d1_7 == 0 & d1_8 == 0)  )  

## using mutate() and filter() ############
# make a k-min and a k-max
enumerate_ds(n = 8, k = 8) %>%
  # Make a 'counter' column
  mutate(count = d1_1 + d1_2 + d1_3 + d1_4 +
           d1_5 + d1_6 + d1_7 + d1_8) %>%
  # Cut any rows where count is 0
  filter(count >= 1 & count <= 2) %>%
  # remove the count column
  select(-count)


## using mutate(), case_when(), and filter() ############

# Buying a Car

# D1: fuel = electric (0) and hybrid (1)
# D2: size = suv (0), sedans (1), trucks (2)
# D3: brand = tesla (0), chevy (1), or vw (2)

# if D1 == hybrid THEN D3 != tesla

enumerate_sf(n = c(2,3,3))  %>%
  # Make a keep variable
  mutate(keep = case_when(
    # If this condition, then FALSE 
    d1 == 1 & d3 == 0 ~ FALSE,
    # if otherwise, then TRUE
    TRUE ~ TRUE
  )) %>%
  # 
  filter(keep == TRUE)  %>%
  select(-keep)

# Suggestion - do it step by step
arch = enumerate_sf(n = c(2,3,3)) 
arch
arch = arch %>%   mutate(keep = case_when(d1 == 1 & d3 == 0 ~ FALSE, TRUE ~ TRUE))
arch
arch = arch %>% filter(keep == TRUE)
arch
arch = arch %>% select(-keep)
arch

  

# 4. YOUR ARCHITECTURES ###################################

# Exercise: Decisions in Your Project

# Take a moment and think about your project.
# 1. Write down **at least 3 decisions** relevant in your system's architecture.
#          At least 1 should be a 'complex enumeration function' we learned above,
#          eg. assignment, permutation, partitioning, adjacency
#          Be sure to list out their alternatives, like so:
#          Keep it simple, because we're about to code it!
#
# For example:
#    Project: Climate Action in Transportation Dashboard
#    D1: (standard form-tree)  # of Dashboard Pages
#       # 1 page
#       # 2 pages
#       # 3 pages
#    D2: (Downselecting) Types of Graphs on each page, must have at least 2
#       # Bar
#       # Map
#       # Line
#    D3: (Permutation) Order of Graphs
#       # Bar = 0, Map = 1, Line = 2
#       # Map = 0, Bar = 1, Line = 2
#       # Line = 0, Map = 1, Bar = 2,
#       # etc.

# 2. Enumerate your architectures! 
#        You probably will need to...
#        Enumerate each decision separately, then expand_grid them.


a1 = enumerate_sf(n = c(3))
# 3 graphs, pick at least 2, max 3
a2 = enumerate_ds(n = 3, k = 3, .did = 2) %>%
  mutate(count = d2_1 + d2_2 + d2_3 ) %>%
  filter(count >= 2 & count <= 3) %>%
  select(-count)
# order of 3 graphs, using up to 3
a3 = enumerate_permutation(n = 3, k = 3, .did = 3)

# Get a grid of all combos of d1 and d2
arch = expand_grid(a1, a2, a3)
# For each architecture, now add on...
  
# gotta constrain here, 
# because if in decision 2 you picked just 1 graph, in d3 max k is 1
# if in decision 2 you picked just 2 graphs, in d3 max k is 2
# if in decision 3 you picked 3 graphs, in d3 max k is 3
arch %>%
  mutate(countd2 = d2_1 + d2_2 + d2_3) %>%
  mutate(keep = case_when(
    countd2 == 1 & d.......
  ))



# 3. Any Constraints?


# D1 standard form - small, medium, large
# D2 adjacency - type of fueltype: electric, jet, hydrogen
#  n = 3 fueltypes, k-max = 2
# D3 partition - n cabins, max k is n cabins


a1 = enumerate_sf(n = c(3), .did = 1)

a2 = enumerate_adjacency(n = 3, k = 2, .did = 2, diag = TRUE) # but constrain later

a3 = enumerate_partition(n = 4, k = 3, .did = 3)

arch = expand_grid(
  a1, a2, a3  
)

# Now to constrain
# arch %>% filter....

