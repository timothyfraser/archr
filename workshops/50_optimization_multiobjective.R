# Script: 50_optimization_multiobjective.R
# Original: tutorial_optimization_2.R
# Topic: Multiobjective optimization tutorial
# Section: Optimization
# Developed by: Timothy Fraser, PhD
#' @name tutorial_optimization_2.R
#' @author Tim Fraser
#' @description 
#' In this tutorial, we're going to make bin2int() and revise_bit() functions,
#' using on of your classmates' project as an example.
#' (We'll only do one constraint - that group will have to figure out the rest - but I hope this helps!)

bit2int = function(x){
  
  d1 = binary2decimal(x[1:2])
  d2 = x[3:4] %>% binary2decimal()
  d3 = x[5] %>% binary2decimal()
  d4 = x[6:7] %>% binary2decimal()
  d5 = x[8:9] %>% binary2decimal()
  d6 = x[10:11] %>% binary2decimal()
  d7 = x[12:13] %>% binary2decimal()
  d8 = x[14] %>% binary2decimal()
  d9 = x[15] %>% binary2decimal()
  output = c(d1,d2,d3,d4,d5,d6,d7,d8,d9)
  return(output)
}

bit2int(c(0,0,1,0,1,1,1,0,0,0,1,1,1,1,1))


revise_bit = function(x){
  # Testing value
  x = c(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)
  
  # 1. Transform bits into integer alternatives
  xhat = bit2int(x)
  
  # Get decisions
  d1 = xhat[1]
  d2 = xhat[2]
  d3 = xhat[3]
  d4 = xhat[4]
  d5 = xhat[5]
  d6 = xhat[6]
  d7 = xhat[7]
  d8 = xhat[8]
  d9 = xhat[9]
  
  # 2. Check for any violated constraints
  
  # Structural Constraints
  # Constraint 1: d1 != 3
  constraint1 = d1 == 3

  # 3. Resample selected alternatives for impossible values
  
  # Structural Constraints
  # Resample from available options for d1 if so: [0,1,2]
  if(constraint1 == TRUE){  d1 = sample(x = c(0,1,2), size = 1) }

  # *** THIS TEAM SHOULD FINISH ADDING THEIR CONSTRAINS HERE *********
  
  # 4. convert new integer vector back into binary vector.
  xnew1 = decimal2binary(x = d1, length = 2)
  xnew2 = decimal2binary(x = d2, length = 2)
  xnew3 = decimal2binary(x = d3, length = 1)
  xnew4 = decimal2binary(x = d4, length = 2)
  xnew5 = decimal2binary(x = d5, length = 2)
  xnew6 = decimal2binary(x = d6, length = 2)
  xnew7 = decimal2binary(x = d7, length = 2)
  xnew8 = decimal2binary(x = d8, length = 1)
  xnew9 = decimal2binary(x = d9, length = 1)
  
  # Bundle as a vector
  xnew = c(xnew1, xnew2, xnew3, xnew4, xnew5, xnew6, xnew7, xnew8, xnew9)
  
  # Return output
  return(xnew)
}

bit2int()
c(0,0,1,0,1,1,1,0,0,0,1,1,1,1,1) %>%
  revise_bit()
