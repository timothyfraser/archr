# Script: 43_optimization_bit_integer_conversion.R
# Original: example_bit2int.R
# Topic: Bit-integer conversion utilities
# Section: Optimization
# Developed by: Timothy Fraser, PhD
# example_bit2int.R

# Let's create a bit2int() function for a team case study

# Load GA package.
library(GA)

# Test out our binary2decimal() function from GA
binary2decimal(x = c(1,1))

# First, let's map out the decision space for our case study today,
# which focuses on a team trying to develop a new app.


# App Development Team
# Decision Space / Alternatives
# D1 = DS{0,1}{0,1}{0,1}{0,1}
# D2 = SF{0,1,2, 3}
# D3 = SF{0,1,2, 3}
# 
# Constraints:
# D1 cannot be [0000]
# If D1_1 & D1_2 & D1_3 == 0 and D1_4 = 1, then D2 = 3
# If D1_1 & D1_2 & D1_3 == 0 and D1_4 = 1, then D3 = 3
# Suppose reference architecture xhat = [0001][3][3]

# Example Reference Architecture
# [0001][3][3]
# [[X][X][X][X]][XX][XX]

# Pseudo-Code for algorithm:
# Is d1 a valid architecture?
#   if 0000, resample from [0/1][0/1][0/1][0/1] until not 0000
# Convert d1 to bitstring x1
# 
# Is d2 a valid architecture?
#   If D1_1 & D1_2 & D1_3 == 0 and D1_4 = 1, then D2 must be 3
# So if D1_1 & D1_2 & D1_3 == 0 and D1_4 = 1 AND D2 != 3, resample D2 from 3
# ...
# Convert d2 to bitstring x2
# 
# Is d3 a valid architecture?
#   ...
# Convert d3 to bitstring x3
# 
# Bundle x1,x2,x3 into bitstring x
# Return x

# Let's try to code this up!
bit2int = function(x){
  # Testing value
  # x = c(0,0,0,1, 1,1, 1,1)
  
  # Decision 1
  # Converted to xhat
  d1_1 = binary2decimal(x = x[1])
  d1_2 = binary2decimal(x = x[2])
  d1_3 = binary2decimal(x = x[3])
  d1_4 = binary2decimal(x = x[4])
  
  # If all of decision 1 options are 0, then FAIL
  # Reject if...
  if(d1_1 == 0 & d1_2 == 0 & d1_3 == 0 & d1_4 == 0){  return(NA)   }
  
  
  # Decision 2  
  d2 = binary2decimal(x[5:6])
  # Reject if...
  if( (d1_1 == 1 | d1_2 == 1 | d1_3 == 1) & d2 == 3){ return(NA)  }
  if( (d1_1 == 0 & d1_2 == 0 & d1_3 == 0 & d1_4 == 1) & d2 != 3){ return(NA)  }

  
  # Decision 3
  d3 = binary2decimal(x[7:8])
  # Reject if...
  if( (d1_1 == 1 | d1_2 == 1 | d1_3 == 1) & d3 == 3){ return(NA)  }
  if( (d1_1 == 0 & d1_2 == 0 & d1_3 == 0 & d1_4 == 1) & d3 != 3){ return(NA)  }
  
  # Bundle!
  xhat = c(d1_1, d1_2, d1_3, d1_4, d2, d3)
  return(xhat)
}

# An invalid option returns NA
bit2int(x = c(0,0,0,0, 1,1, 1,1))
# A valid option returns the integer string
bit2int(x = c(0,0,0,1, 1,1, 1,1))
