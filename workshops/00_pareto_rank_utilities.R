# Script: 00_pareto_rank_utilities.R
# Original: functions_pareto_rank.R
# Topic: Pareto ranking helpers
# Section: Evaluation
# Developed by: Timothy Fraser, PhD
#' @name pareto_rank
#' @title Find Pareto Rank using Nondominated Sorting
#' @author Tim Fraser (adapted from Nozomi Hitomi)
#' @param matrix an `n`x`m` matrix with `m` objectives and `n` solutions
#' @description
#' Generates a `n`x1 logical vector of parento ranks.
#' @source Adapted from Matlab implementation by Nozomi Hitomi, 11/17/2015
#' @export
pareto_rank = function(x = NULL, y = NULL, m = NULL){
  
  #function [P]=paretofront2(x)
  #Author Nozomi Hitomi
  #Created 11/17/2015
  #This code implements the first part of the fast nondominated sorting from
  #NSGA-II. Assumes minimization of all objectives
  #Input: X is a nxm matrix with m objectives and n solutions
  #Ouput: P is the nx1 logical vector with true if the solution lies in the
  #Pareto front
  
  # If m is missing but x and y are provided...
  if(is.null(m)){
    if(!is.null(x) & !is.null(y)){
      # Make m a 2-column matrix of x and y
      m = matrix(c(x, y), ncol = 2)
    }else{
      stop("Must provide either ['m'] or ['x' and 'y'].")
    }
  }
  # Example
  
  # Get length of input matrix
  n_arch = nrow(m);
  
  domination_counter = rep(0, n_arch)
  # domination_counter=matrix(0, nrow = n_arch, ncol = 1);
  
  # For each row in the matrix...
  for(i in 1:n_arch){
    #i = 1
    # As long as i is not the last item (can't compare the ith and ith +1 if ith = n)
    if(i != n_arch){
      # For every other remaining row in the matrix...
      for(j in (i+1):n_arch){
        # j = i + 1
        # Check does the previous row dominate the second row
        dom = dominates(s1 = m[i, ], s2 = m[j, ]);
        # If the second (s2) dominates the first (s1)...
        if(dom == -1){
          # Add to the count of times that row was dominant
          domination_counter[j] = domination_counter[j] + 1;
          # If the first (s1) dominates the second (s2)...
        }else if(dom == 1){
          # Add to the count of times that row was dominant
          domination_counter[i] = domination_counter[i] + 1;
        }
        # If neither were dominant, the counter is unaffected.
      }
    }
  }
  
  # If any cases remain **non-dominated**
  p = domination_counter
  #p = domination_counter == 0
  return(p)
}
