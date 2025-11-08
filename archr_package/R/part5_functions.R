#' PART 5 FUNCTIONS
#' This script contains a series of functions that support the genetic algorithm for optimization of enumerated architectures.
#' Still under development. You are welcome to suggest new functions.
#' 
#' Some of these are internal functions, while others are functions intended to be used by actual R users.
#' If you encounter an issue with any of these functions, please tag it in a Github Issue.

#' @name as_bit
#' @title Convert Integers to Bits as vectors.
#' @author Tim Fraser
#' @description
#' Vectorized version of `decimal2binary()` from `GA` package.
#' @param x vector of integer(s) to be transformed
#' @param n length of bitstring to represent them as.
#' @param simplify (logical) should the bitstrings, if multiple, be concatenated into a matrix, or returned as a list?
#' @importFrom GA decimal2binary
#' @importFrom purrr map
#' @examples
#' as_bit(x = c(0,2,3), n = c(1,2,3), simplify = FALSE)
#' @export
as_bit = function(x, n, simplify = TRUE){

  result = purrr::map2(.x = x, .y = n, .f = ~GA::decimal2binary(x = .x, length = .y))
  if(simplify == TRUE){ result = do.call(rbind, result) }
  return(result)
}

#as_bit(x = 0, n = 1)
