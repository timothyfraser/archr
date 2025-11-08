# Script: 11_architecting_simple_counting_function.R
# Original: recitation_3.R
# Topic: Counting function recitation
# Section: Architecting Systems
# Developed by: Timothy Fraser, PhD
#' @name count_n_m 
#' @title Count N and M independent choices
#' @author Tim Fraser
#' 
#' @param n (integer) number of independent choices of the first type
#' @param m (integer) number of independent choices of the second type
#' 
#' @export
count_n_m = function(n, m){  n + m }


archr::
#' @name count_n_m 
#' @title Count N and M independent choices
#' @author Tim Fraser
#' @description 
#' This is a function for adding n and m choices together. Yay!
#' 
#' @param n (integer) number of independent choices of the first type
#' @param m (integer) number of independent choices of the second type
#' 
#' @importFrom dplyr `%>%` tibble mutate
#' 
#' @note Here's a note
#' 
#' @source Evelyn came up with this, and I coded it.
#' 
#' @export
count_n_m = function(n, m){  
  # testing values
  # library(dplyr)
  # n = 3
  # m = 2

  data = tibble(n = n, 
         m = m) %>%
    mutate(count = n + m)
  output = data$count
  return(output)
}


