# Script: 42_optimization_binary_encoding.R
# Original: example_binary.R
# Topic: Binary encoding primer
# Section: Optimization
# Developed by: Timothy Fraser, PhD
# example_binary.R

library(dplyr)
# install.packages("GA")
# install.packages("rmoo")
library(GA)
library(rmoo)

# D1 = 3
# D2 = 2
# D3 = 2

# [XX][X][X]
c(0,1, 0, 0) # binary

# Convert from binary into decimal
binary2decimal(x = c(0, 0) )
binary2decimal(x = c(0, 1) )
binary2decimal(x = c(1, 0) )
binary2decimal(x = c(1, 1) )

# x = vector of bits (00010101010101)
# xhat = vector of integers (0,1,2,3)

#' @name int2bit
#' @description 
#' Converts a vector `xhat` of integers to a vector of binary bits `x`
#' Also, if one of the values of `xhat` isn't feasible, it randomly generates a feasible value instead.
int2bit = function(xhat){ 

  # testing integers
  # xhat = c(D1 = 3, D2 = 1, D3 = 0)
  # xhat['D1']

  d1 = xhat[1]
  d2 = xhat[2]
  d3 = xhat[3]

  # D1 Resampler
  # If d1 is NOT in this set of valid values
  if(!d1 %in% c(0,1,2)){
    # Randomly resample from valid values
    d1 = sample(size = 1, x = c(0,1,2) ) 
  }
  # D1 Convert to bits
  x1 = case_when(
    d1 == 0 ~ c(0,0),
    d1 == 1 ~ c(0,1),
    d1 == 2 ~ c(1,0)
  )

  # D2 Resampler  
  if(!d2 %in% c(0,1)){ d2 = sample(size = 1, x = c(0,1)) }
  
  # D2 Convert to Bits
  x2 = case_when(
    d2 == 0 ~ c(0),
    d2 == 1 ~ c(1)
  )
  
  
  # D3 Resampler  
  if(!d3 %in% c(0,1)){ d3 = sample(size = 1, x = c(0,1)) }
  
  # D3 Convert to Bits
  x3 = case_when(
    d3 == 0 ~ c(0),
    d3 == 1 ~ c(1)
  )
  
  # Goal: turn our integer vector into a vector of bits
  # x
  x = c(x1, x2, x3)
  return(x)
}


# Test it
int2bit(xhat = c(3, 1, 1))


# From binary to integer
bit2int = function(x){ }

