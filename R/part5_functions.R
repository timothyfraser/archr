# Helper Functions ##############################

#' @name as_bit
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
