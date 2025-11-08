# Script: 49_optimization_genetic_algorithms_intro.R
# Original: tutorial_optimization_1.R
# Topic: Genetic algorithm introduction
# Section: Optimization
# Developed by: Timothy Fraser, PhD
#' @name tutorial_optimization_1.R
#' @author Tim Fraser, PhD
#' @description 
#' This script enacts portions of our Workshop 2 Skill 3 guide on Optimization.

# Load packages
library(dplyr)
library(readr)
library(tidyr)
library(archr)
library(GA)
library(rmoo)

# 3.2.1 Data ####################################
# HW3
a = tidyr::expand_grid(d1 = c(0,1), d2 = c(0,1), d3 = c(0, 1, 2, 4)) %>% as.matrix()
# or
a = archr::enumerate_sf(n = c(2,2,4))


# Calculate total length of your bitstring
meta = tibble(
  # List your decisions
  did = c(1,2,3),
  # An example architecture
  ref = c(0, 1, 3),
  # List the lowest range of integer alternatives
  lower = c(0,0,0),
  # List the upper range of integer alternatives
  upper = c(1,1,3),
  # Write out total number of alternatives available,
  n_alts = c(2, 2, 4),
  # Calculate the total number of bits needed to represent each.
  n_bits = n_alts %>% log2() %>% ceiling()
)
# View it!
meta

# Encoding an integer as a 2-bit string
c(0,1) # 1
c(0,0) # 0
c(1,0) # 2
c(1,1) # 3

# Encoding 0 to 1 as a bit string
c(0) # 0
c(1) # 1

# enumerate --> evaluate --> 
# convert integers to bits --> run optimization

# architecture
c(0,1,3,2,5) %>% log2() %>% ceiling() %>% max()



# 3.2.2 Requirements for Fitness Function f1() ###############

# 3.2.3 Converting from Binary to Integer with bit2int() #########

# Get a reference architecture [D1 = 1, D2 = 0, D3 = 2]
xhat = c(1, 0, 2)

xhat[1]
xhat[2]
xhat[3]

# Convert the first integer [0,1] to binary [0,1]
x1 = decimal2binary(x = xhat[1], length = 1)
# Convert the second integer [0,1] to binary [0,1]
x2 = decimal2binary(x = xhat[2], length = 1)
# Convert the third integer [0,1,2,3] to binary [00,01,10,11]
x3 = decimal2binary(x = xhat[3], length = 1)
# Bind them together!
x = c(x1,x2,x3)
x # View it! (This will 



xhat1 = binary2decimal(x = x[1]) # convert first integer's set of bits
xhat2 = binary2decimal(x = x[2]) # convert next integer's set of bits
xhat3 = binary2decimal(x = x[3:4]) # convert next integer's set of bits
xhat = c(xhat1, xhat2, xhat3) # bind together
xhat # View it


bit2int = function(x){
  xhat1 = binary2decimal(x = x[1]) # convert first integer's set of bits
  xhat2 = binary2decimal(x = x[2]) # convert next integer's set of bits
  xhat3 = binary2decimal(x = x[3:4]) # convert next integer's set of bits
  xhat = c(xhat1, xhat2, xhat3) # bind together
  return(xhat) # View it!
}

# Try it!
bit2int(c(1,0,1,1))
bit2int(c(1,0,1,1))
bit2int(c(1,1,1,0))
bit2int(c(0,0,1,1))



# 3.2.4 Writing an evaluate() function #######################

# Evaluate this integer string
evaluate = function(xhat){
  #xhat = c(1,0,1)
  # Make metrics
  m1 = sum(xhat)
  m2 = prod(cos(xhat)^2)
  m3 = sum(xhat * c(0.25, 0.5, pi^-2))
  # Bundle metrics
  metrics = c(m1,m2,m3)
  
  #metrics = c("m1" = m1, "m2" = m2, "m3" = m3)

  m = matrix(data = metrics, ncol = length(metrics))
  
  #m = matrix(data = metrics, ncol = length(metrics), dimnames = list(c(), names(metrics)))
  return(m)
}

# Let's try evaluating a reference architecture!
evaluate(xhat = c(1,0,3))



a
# a %>% slice(5) %>% evaluate()
# a %>% slice(6) %>% evaluate()
# a %>% slice(7) %>% evaluate()


evaluate(xhat = c(0,0,0))
evaluate(xhat = c(0,0,1))
evaluate(xhat = c(0,1,1))
evaluate(xhat = c(0,1,0))
evaluate(xhat = c(0,1,0))


evaluate(xhat = c(1,0,1))




# 3.2.5 Writing a fitness function ##########################
f1 = function(x, nobj = 3, ...){
  # x = c(1,0,0,1)
  # First, let's convert from binary to our integer-formatted architecture
  xhat = bit2int(x)
  # Seconds, let's get metrics 
  metrics = evaluate(xhat)
  # Third, let's return metrics
  return(metrics)
}
# Let's try it!
f1(x = c(0,0,0,1))
f1(x = c(0,0,1,0))
f1(x = c(0,1,0,1))
f1(x = c(1,1,0,1))
f1(x = c(1,1,0,0))



# 3.2.6 Running the Genetic Algorithm #######################
# Calculate the total number of bits in your bitstring
total_bits = meta %>% summarize(total = sum(n_bits)) %>% with(total)


ref = generate_reference_points(m = 3, h = 10)
# Take a peek!
head(ref)


# Full binary search
o = rmoo(
  fitness = f1, type = "binary", algorithm = "NSGA-III",
  # Upper and Lower bounds on the bitstrings
  lower = c(0,0,0,0), upper = c(1,1,1,1),
  # Settings
  monitor = TRUE, summary = TRUE,
  nObj = 3, nBits = total_bits, popSize = 50, maxiter = 100
)
 # Extras
#  reference_dirs = ref)

# 3.2.7 Reviewing Results #################33
o

summary(o)
o@solution
bit2int(o@solution)

