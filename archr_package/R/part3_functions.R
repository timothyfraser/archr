#' PART 3 FUNCTIONS
#' This script contains a series of functions that allow for enumeration. 
#' Some of these are internal functions, while others are functions intended to be used by actual R users.
#' If you encounter an issue with any of these functions, please tag it in a Github Issue.





#' @name enum
#' @author Tim Fraser
#' 
#' @param i ...
#' @param d data.frame of decision-alternative-ids
#' @param c data.frame of constraints
#' 
#' @importFrom dplyr `%>%` filter select
#' @importFrom tidyr expand_grid
enum = function(i = 1, d, c){
  #i = 1
  j = i+1

  di = paste0("d",i)
  dj = paste0("d", j)

  # Get the alternative values for decision i
  datai = d %>% dplyr::filter(did == i) %>% select(altid) %>% setNames(nm = di)
  # Get the alternative values for decision j (where j = i + 1)
  dataj = d %>% dplyr::filter(did == j) %>% dplyr::select(altid) %>% setNames(nm = dj)
  # Get the grid of all combinations
  grid = tidyr::expand_grid(datai, dataj)

  return(grid)
}



#' @name enumerate
#' @title Enumerate Your Decision Tree
#' @author Tim Fraser
#' @description
#' A function to enumerate a simple decision tree, under very specific formatting. Soon to be deprecated. 
#' Encouraged to use new functions like `enumerate_binary()`, `enumerate_ds()`, etc. 
#' 
#' @param d data.frame of decision-alternative items
#' @param c data.frame of constraints
#' 
#' @importFrom dplyr `%>%` inner_join mutate n filter select contains if_any any_of
#' 
#' @export
enumerate = function(d = NULL, c = NULL, .id = FALSE){
  no_d = is.null(d)
  got_c = !is.null(c)
  # If d is not present
  if(no_d){ stop("Need an input dataframe of decision-alternatives 'd'...") }
  # If c is present...
  if(got_c){
    # Here's the decision/alternative values of those to be cut
    c_cut = c %>%
      inner_join(by = c("id_prior"),
                 y = d %>% select(id_prior = id, did_prior = did, altid_prior = altid)) %>%
      inner_join(by = c("id_cut"),
                 y = d %>% select(id_cut = id, did_cut = did, altid_cut = altid)) %>%
      mutate(did_prior = paste0("d", did_prior),
             did_cut = paste0("d", did_cut))

    # For as many constrains as supplied, let's constrain this table of architectures.
    cut_rows = function(data, c_cut){
      for(k in 1:nrow(c_cut)){
        # k = 1
        data = data %>%
          filter(
            # Give me any rows where the prior alternative did NOT occur for the prior decision
            #!!sym(c_cut$did_prior[k]) != c_cut$altid_prior[k] ) |
            if_any(.cols = any_of(c_cut$did_prior[k]), ~.x != c_cut$altid_prior[k] )
            | # OR
              # where the cut alternative did NOT occur for the cut decision
              if_any(.cols = any_of(c_cut$did_cut[k]), ~.x !=  c_cut$altid_cut[k])
            #(  !!sym(c_cut$did_cut[k]) != c_cut$altid_cut[k])
            # Both must happen in order to get cut.
          )
      }
      return(data)
    }

  }



  if(!no_d){
    # Get vector of sorted, unique decision ids (eg. 1, 2, 3, 4)
    dids = sort(unique(d$did))
    # Get total number of decisions
    n_dids = length(dids)
    # If there is just 1 decision, do this...
    if(n_dids == 1){
      gridi = d %>% filter(did == dids[1]) %>% select(d1 = altid)
      # If constraints are supplied, cut rows!
      if(got_c){ gridi = cut_rows(data = gridi, c_cut = c_cut)  }

    # If there are 2 decisions
    }else if(n_dids == 2){
      gridi = enum(i = 1, d = d, c = c)
      # If constraints are supplied, cut rows!
      if(got_c){ gridi = cut_rows(data = gridi, c_cut = c_cut)  }
    }else if(n_dids >= 3){


      # excise the last 2 values,
      # because if i = n, we can't run enum(i = n,...)
      # and if j = n, we can't run enum(i = j = n, ...)
      dids = dids[-c(n_dids, n_dids -1) ]


      # Testing value only
      # i = 1
      for(i in dids){
        # testing values only
        # i = 3
        j = i+1
        di = paste0("d", i)
        dj = paste0("d", j)
        # If i is the first decision, enumerate it
        if(i == 1){ gridi = enum(i = i, d = d, c = c) }
        # Then enumerate the jth decision
        gridj = enum(i = j, d = d, c = c)
        # Now join the ith decision table (including all prior) to the jth
        gridi = inner_join(by = dj, x = gridi, y = gridj, multiple = "all")

        # If constraints are supplied
        # If constraints are supplied, cut rows!
        if(got_c){ gridi = cut_rows(data = gridi, c_cut = c_cut)  }
      }
    }

    # If .id == TRUE,
    if(.id == TRUE){
      # Add architecture ids, and reorganize columns
    gridi = gridi %>%
      mutate(id = 1:n()) %>%
      select(id, contains("d"))
    # Otherwise...
    }else{
      # Keep just the decision variables
      gridi = gridi %>% select(contains("d"), -any_of("id"))
    }
    return(gridi)
  }


}




#' @name count_ds
#' @title Count N for Downselecting
#' @description Function to count total number of ways you can select `k` items from `n` items.
#' @author Tim Fraser
#' @param n total number of items available to choose from
#' @param k number of items to choose
#' @note
#' count_ds(n = 10, k = 2)
#' @export

count_ds = function(n, k){
  f_n = factorial(n)
  f_k = factorial(k)
  f_n_minus_k = factorial((n - k))
  result = f_n / (f_k * f_n_minus_k)
  return(result)
}
# tribble(
#   ~id, ~did, ~altid,
#   1,   1,    0,
#   2,   1,    1
# )

#' @name enumerate_ds
#' @title Enumerate Downselected Decision
#' @author Tim Fraser, PhD
#' 
#' @param n total number of items available to choose from
#' @param k number of items to choose
#' @param .id (logical, optional) add a unique ID column to the end?
#' @param .did (integer, optional) Decision id. For example, if .did = 1, then columns will be `d1_1`, `d1_2`, `d1_[n]`...
#' 
#' @importFrom dplyr `%>%` filter select mutate n any_of
#' 
#' @export
enumerate_ds = function(n, k, .id = FALSE, .did = 1){
  # Testing Values
  # n = 4
  # k = 2

  a = enumerate_binary(n = n)

  mynames = paste0("d", .did, "_", 1:n)
  names(a) <- mynames

  # If k = n, then all values are fair game.

  # If k is greater than n, that makes no sense.
  if(any(k > n)){ stop("'k' (number of items selected) must be less than or equal to 'n', number of items to choose from.") }
  if(any(k < 0)){ stop("'k' (number of items selected) must be non-negative.")}

  # If k does NOT equal n, then we need constraints.
  if(any(k != n)){

    # We're going to enumerate all 4 decisions,
    # then remove any rows where more than k decisions are made
    a$count = rowSums(a)

    # How many values were supplied to k?
    n_k = length(k)

    # If just 1 k value was supplied, interpret this as the max.
    if(n_k == 1){
      # Filter so that only rows with less than k
      a = a %>% filter(count <= k) %>% select(-count)
    }

    # If 2 or more k values were supplied,
    if(n_k >= 2){
      # Filter so that
      # say if k is c(1, 3, 5)
      # We will only keep rows were 1 item, 3 items, or 5 items were selected.
      a = a %>% filter(count %in% k) %>% select(-count)
    }

  }

  if(.id == TRUE){  a = a %>% mutate(id = as.integer(1:n())) }
  # Rearrange columns
  a = a %>% select(any_of(c("id", mynames)))

  # Return output
  return(a)

}

#' @name enumerate_assignment
#' @title Enumerate Assignment Matrix into Architectures
#' @author Tim Fraser, PhD
#' 
#' @param n (integer) total number of groups in part a of the assignment matrix
#' @param m (integer) total number of groups in part b of the assignment matrix
#' @param k (integer) total number of items (a-b pairs) that can be selected per assignment matrix. If n_alts = 2, k is be length 1. If n_alts > 2, k must be length n_alts+1. By default `k` is `1`.
#' @param n_alts (integer, optional) total number of values that can be assigned to each item (eg. 2= c(0,1)). Default is `2`. (Experimental; don't change unless you've thought deeply about what you're doing!)
#' @param .did unique decision id.
#' @param .id (logical) Include a unique ID for each row? Defaults to FALSE.
#' 
#' @description
#'
#' If n_alts = 2, k can have 1 value.
#'    k[1] corresponds to when alternative = [1]
#' If n_alts = 3, k can have 2 values.
#'    k[1] corresponds to when alternative = [1]
#'    k[2] corresponds to when alternative = [2]
#'
#' @importFrom dplyr `%>%` select mutate filter n tibble any_of
#' @importFrom tidyr expand_grid
#' @importFrom purrr map2
#'
#' @examples
#' enumerate_assignment(n = 3, m = 2, k = 5, n_alts = 2)
#' enumerate_assignment(n = 3, m = 2, k = c(3,2), n_alts = 3)
#'
#' @export
enumerate_assignment = function(n,m, k = 1, n_alts = 2, .did = 1, .id = FALSE){

  # Testing Values
  # n = 3; m = 2; k = c(3,2); j = 3; .did = 1; .id = FALSE

  a_names = paste0("a", 1:n)
  b_names = paste0("b", 1:m)
  j_values = 0:(n_alts-1)

  # Get length of j and k
  length_j = length(n_alts)
  length_k = length(k)

  # If k is shorter than j, we have a problem!
  if(length_k < length_j){ stop("'k' must be the same length as the value of 'j', or 1 more than the value of 'j'.") }
  # If k is the same length as the number of alternatives, we have a problem!
  if(length_k  == n_alts){ stop("'k' must be of length n_alt - 1.") }


  # Make a bipartite edgelist of every unique combination of a and b
  mynames = expand_grid(a = a_names,b = b_names)  %>%
    mutate(did = paste0("d", .did, "_", a, "_", b)) %>%
    with(did)

  # Make a list of tibbles, each with one column
  a = purrr::map(
    .x = mynames,
    .f = ~tibble(!!sym(.x) := j_values)
  )
  # Get the full grid of all possible combinations
  a = expand_grid(!!!a)

  q = 1

  # Then, for each possible value (j) that can be assigned
  index = 1:(n_alts-1)

  for(i in index){
    #i = index[1]
    # i = index[2]
    # Count up the total number of ties that were assigned that i+qth j value
    # Eg. if j = c(0,1) and we look at the ith cell, then check j = '1+q'
    # where q is an extra 1 added if the length of k and length of j are unequal.
    a$count = rowSums(a == j_values[i+q])
    # Then filter to just rows where count is less than or equal to k
    a = a %>% filter(count <= k[i]) %>% select(-count)
  }

  if(.id == TRUE){ a = a %>% mutate(id = as.integer(1:n())) }
  # Rearrange columns
  a = a %>% select(any_of(c("id", mynames)))

  return(a)

}

# rowSums(enumerate_assignment(n = 3, m = 2, k = c(3,2), n_alts =3)==1)
# rowSums(enumerate_assignment(n = 3, m = 2, k = c(3,2), n_alts =3)==2)
# rowSums(enumerate_assignment(n = 3, m = 2, k = c(3,3), n_alts =3)==2)
# rowSums(enumerate_assignment(n = 3, m = 2, k = c(1), n_alts =2)==1)
# rowSums(enumerate_assignment(n = 3, m = 2, k = c(5), n_alts =2)==1)


#' @name enumerate_adjacency
#' @title Enumerate Adjacency Matrix into Architectures
#' @author Tim Fraser, PhD
#' 
#' @param n (integer) total number of nodes of the adjacency matrix
#' @param k (integer) total number of items (i-j pairs) that can be selected per assignment matrix. If n_alts = 2, k is be length 1. If n_alts > 2, k must be length n_alts+1.
#' @param n_alts (integer, optional) total number of values that can be assigned to each item (eg. 2= c(0,1)). Default is `2`. (Experimental; don't change unless you've thought deeply about what you're doing!)
#' @param diag (logical, optional) Allow loops on the diagonal of the adjacency matrix? Eg. can A1 connect to A1? Defaults to FALSE.
#' @param .did unique decision id.
#' @param .id (logical) Include a unique ID for each row? Defaults to FALSE.
#' 
#' @description
#'
#' If n_alts = 2, k can have 1 value.
#'    k[1] corresponds to when alternative = [1]
#' If n_alts = 3, k can have 2 values.
#'    k[1] corresponds to when alternative = [1]
#'    k[2] corresponds to when alternative = [2]
#'
#' @importFrom dplyr `%>%` select mutate filter n tibble any_of
#' @importFrom tidyr expand_grid
#' @importFrom purrr map2
#'
#' @examples
#' enumerate_adjacency(n = 3, m = 2, k = 5, n_alts = 2)
#' enumerate_adjacency(n = 3, m = 2, k = c(3,2), n_alts = 3)
#'
#' @export
enumerate_adjacency = function(n, k = 1, n_alts = 2, diag = FALSE, .did = 1, .id = FALSE){

  # Testing Values
  # n = 3; k = c(3,2); n_alts = 3; diag = TRUE; .did = 1; .id = FALSE

  a_names = paste0("a", 1:n)
  j_values = 0:(n_alts-1)

  # Get length of j and k
  length_j = length(n_alts)
  length_k = length(k)

  # If k is shorter than j, we have a problem!
  if(length_k < length_j){ stop("'k' must be the same length as the value of 'j', or 1 more than the value of 'j'.") }
  # If k is the same length as the number of alternatives, we have a problem!
  if(length_k  == n_alts){ stop("'k' must be of length n_alt - 1.") }


  # Make a bipartite edgelist of every unique combination of a_names
  mynames = expand_grid(i = a_names, j = a_names)  %>%
    mutate(did = paste0("d", .did, "_", i, "_", j))

  # If diag == FALSE, cut the diagonal
  if(diag == FALSE){ mynames = mynames %>% filter(i != j) }

  # Extract the variable name
  mynames = mynames %>% with(did)

  # Make a list of tibbles, each with one column
  a = purrr::map(
    .x = mynames,
    .f = ~tibble(!!sym(.x) := j_values)
  )
  # Get the full grid of all possible combinations
  a = expand_grid(!!!a)

  q = 1

  # Then, for each possible value (j) that can be assigned
  index = 1:(n_alts-1)

  for(i in index){
    #i = index[1]
    # i = index[2]
    # Count up the total number of ties that were assigned that i+qth j value
    # Eg. if j = c(0,1) and we look at the ith cell, then check j = '1+q'
    # where q is an extra 1 added if the length of k and length of j are unequal.
    a$count = rowSums(a == j_values[i+q])
    # Then filter to just rows where count is less than or equal to k
    a = a %>% filter(count <= k[i]) %>% select(-count)
  }

  if(.id == TRUE){ a = a %>% mutate(id = as.integer(1:n())) }
  # Rearrange columns
  a = a %>% select(any_of(c("id", mynames)))

  return(a)

}
#' @name enumerate_permutation
#' @title Enumerate Permuations into Architectures
#'
#' @param n total number of items in the set for permuting
#' @param k number of items to choose. Must be less than or equal to `n`.
#' @param .did unique decision id.
#' @param .id (logical) Include a unique ID for each row? Defaults to FALSE.
#' 
#' @importFrom dplyr `%>%` as_tibble mutate n select any_of
#' @importFrom gtools permutations
#' 
#' @source https://stackoverflow.com/questions/11095992/generating-all-distinct-permutations-of-a-list-in-r
#' 
#' @examples
#' enumerate_permutation(n = 2)
#' enumerate_permutation(n = 3, k = 2, .did = 5)
#' @export
enumerate_permutation = function(n, k = NULL, .did = 1, .id = FALSE){

  # Testing values
  # n = 3; k = 2; .did = 2

  # If k is not specified, make it be n
  if(is.null(k)){ k = n }
  if(k > n){ stop("'k' must be less than or equal to 'n'.")}
  if(n == 0){ stop("'n' must be a non-zero integer.")}

  mynames = paste0("d", .did, "_", 1:k)

  # Generate permutations
  a = gtools::permutations(n = n, r = k, v = 0:(n-1))
  # Add names
  colnames(a) <- mynames
  # Convert to tibble
  a = as_tibble(a)

  if(.id == TRUE){ a = a %>% mutate(id = as.integer(1:n())) }
  # Rearrange columns
  a = a %>% select(any_of(c("id", mynames)))

  return(a)
}

#' @name enumerate_partition
#' @title Enumerate Partitions into Architectures
#' @author Tim Fraser
#'
#' @param n total number of items to be partitioned
#' @param k total number of partitions to be made (categories to assign)
#' @param min_times (integer) a k-length vector of minimum number of times each respective category must be assigned.
#' @param max_times (integer) a k-length vector of maximum number of times each respective category must be assigned.
#' @param .did unique decision id.
#' @param .id (logical) Include a unique ID for each row? Defaults to FALSE.
#' 
#' @importFrom dplyr `%>%` mutate n filter select any_of
#' 
#' @examples
#' enumerate_partition(n = 4, k = 2)
#' enumerate_partition(n = 4, k = 2, min_times = c(1,3))
#' enumerate_partition(n = 4, k = 2, min_times = c(2,2))
#' enumerate_partition(n = 4, k = 2, max_times = c(2,2))
#' enumerate_partition(n = 4, k = 2, max_times = c(2,2), .did = 4)
#' @export
enumerate_partition = function(n, k, min_times = NULL, max_times = NULL, .did = 1, .id = FALSE){

  # Take a set of items...
  # And assign to them a finite number of values

  # I have n items...
  # I can assign k values to n items...
  # n = 4; k = 2; min_times = c(2, 1); max_times = c(3,2); .did = 1

  # Error handling

  # If no min times is specified, then each alternative must be assigned at least zero times.
  if(is.null(min_times)){ min_times = rep(0, k) }
  # If no max times is specified, then each alternative must be assigned at max n times.
  if(is.null(max_times)){ max_times = rep(n, k) }

  #if(sum(max_times) > n){ stop("Sum of all max_times cannot exceed n.") }
  if(sum(min_times) > n){ stop("Sum of all min_times cannot exceed n.") }

  if(any(min_times > n) | any(max_times > n)){ stop("can't assign 'min_times' less than 'n'; can't assign 'max_times' greater than 'n'.")}
  n_min_times = length(min_times)
  n_max_times = length(max_times)
  if(n_min_times != k | n_max_times != k){  stop("'min_times' and 'max_times' must each be length 'k'.")}

  # Get n number of micro-decisions with k alternatives in each
  a = enumerate_sf(n = rep(k, n))

  # min_times = c(2,1)
  # max_times = c(2,2)
  # This means that 0 [ k[1] ] must occur at least 2 times
  # This means that 1 [ [k[2]] must occur at least 1 time

  # For each value in 'need'...
  k_values = 0:(k-1)
  index = 1:k
  for(i in index){
    # i = index[2]
    a$count = rowSums(a==k_values[i])
    # Filter to just architectures where...
    # k_values[i] occurs at least min_times[i] per architecture
    # eg. 0 occurs at least 2 times per architecture
    a = a %>% filter(count >= min_times[i])
    # k_values[i] occurs at max max_times[i] per architecture
    # eg. 0 occurs at max 3 time per architecture
    a = a %>% filter(count <= max_times[i])
    # Drop count
    a = a %>% select(-count)
  }

  # Name the columns
  mynames = paste0("d", .did, "_", 1:n)
  colnames(a) = mynames


  if(.id == TRUE){ a = a %>% mutate(id = as.integer(1:n())) }
  # Rearrange columns
  a = a %>% select(any_of(c("id", mynames)))

  return(a)
}



#' @name enumerate_binary
#' @title Enumerate Binary Decisions into Architectures
#' @author Tim Fraser
#' @description
#' Function for enumerating `n` binary decisions into a `data.frame` of encoded architectures.
#' 
#' @param n number of decisions. Must be at least 1.
#' @param forbidden ...
#' @param .did (integer, optional) unique ID of first decision. Used to make column names for sequential decisions. Defaults to 1.
#' @param .id (logical, optional) Whether or not to add a unique ID for each row. Defaults to FALSE.
#' @examples
#' enumerate_binary(n = 2)
#' enumerate_binary(n = 2, forbidden = c(NA, 1))
#' enumerate_binary(n = 4, .did = 3)
#'
#' @importFrom purrr map2
#' @importFrom dplyr `%>%` tibble mutate
#' @importFrom tidyr expand_grid

#' @export
enumerate_binary = function(n = 2, forbidden = NULL, .did = 1, .id = FALSE){

  # Testing values
  # n = 2
  # forbidden = NULL
  # .id = FALSE

  # OR
  # n = 2
  # forbidden = c(NA, 1)
  # .id = FALSE

  # OR
  # n = 0
  # forbidden = NULL
  # .id = FALSE

  # n must be an integer
  n_error_message = "'n' must be a single non-negative integer."
  # Parse n as an integer
  n = as.integer(n)
  # Get length of integer n
  n_n = length(n)

  # If is NA (eg. not integer), negative, or has multiple values, stop
  if(is.na(n) | n < 0 | n_n > 1){ stop(n_error_message)}


  if(!is.null(forbidden)){
    # write error message
    forbidden_error_message = "'forbidden' must be a vector of non-zero integers of length 'n', or NULL"
    # Parse forbidden as an integer vector
    forbidden = as.integer(forbidden)
    # Get length of forbidden vector
    n_forbidden = length(forbidden)
    # If is not equal to the number of binary decisions
    if(n_forbidden != n){ stop(forbidden_error_message) }

    # If no forbidden values supplied, then...
  }else if(is.null(forbidden)){
    # make forbidden a vector of NAs.
    forbidden = rep(NA_integer_, n)
  }

  # Write a mini enumeration function we'll call repeatedly
  enum_mini = function(n_alt, .forbidden = c()){
    if(n_alt == 1){
      alts = c(0,1)
    }else if(n_alt == 0){
      alts = vector(mode = "integer", length = 0)
    }else{ stop("'n_alt' must be a non-negative integer or zero.") }

    if(length(alts) > 0){
      # Remove any forbidden values
      alts = alts[!alts %in% .forbidden]
    }
    return(alts)
  }



    # Enumerate these decisions
    # Make a list of values
    mylist = purrr::map2(
      # For each number of alternatives in n
      .x = rep(1, n),
      # For each name in colnames
      .y = forbidden,
      # Make a tibble from 0 to the ith - 1 element in n,
      .f = ~tibble(d = enum_mini(n_alt = .x, .forbidden = .y))
    )

    if(n > 0){
      # Get vector of column names
      colnames = paste0("d", .did+(1:n)-1)

      # where the vector is named for the ith element in .y
      mylist =  purrr::map2(
        .x = mylist,
        .y = colnames,
        .f = ~setNames(object = .x, nm = .y)
      )
    }
  # Take that list of tibbles and expand the grid.
  #   Note:  !!! is a special character that lets lists of values
  #          be accepted as multiple separate function argument inputs.
  data = expand_grid(!!!mylist)

  if(.id == TRUE){
    data = data %>% mutate(id = as.integer(1:n()))
  }

  return(data)
}


#' @name enumerate_sf
#' @title Enumerate Standard Form
#' @author Tim Fraser
#' 
#' @param n a vector describing the number of alternatives for each decision, sequentially.
#' @param .did (integer, optional) unique ID of first decision. Used to make column names for sequential decisions. Defaults to 1.
#' @param .id (logical, optional) Whether or not to add a unique ID for each row. Defaults to FALSE.
#' @param forbidden Any forbidden possibilities. Not recommended. Easier to constrain using `dplyr::filter()` after the fact. 
#' 
#' @examples
#' enumerate_sf(n = c(2, 3))
#' enumerate_sf(n = c(2, 3), forbidden = c(NA,2))
#' enumerate_sf(n = c(2, 3), .did = 4)
#' 
#' @importFrom purrr map2
#' @importFrom dplyr `%>%` tibble mutate
#' @importFrom tidyr expand_grid
#' 
#' @export
enumerate_sf = function(n = c(2,3), forbidden = NULL, .did = 1, .id = FALSE){

  # Example values
  # n = c(2,3); forbidden = c(NA, 1); .did = 2; .id = FALSE
  # n = c(2,3); .did = 1; .id = FALSE

  # n must be an integer
  error_message = "'n' must be a non-zero integer vector of 1 or more values."
  # Parse n as an integer
  n = as.integer(n)
  # If is NA (eg. not integer) or 0 or less, stop
  if(any(n <= 0) ){ stop(error_message)}
  # Get length of integer alternatives supplied
  n_n = length(n)
  # Make column names for the output
  colnames = paste0("d", .did+(1:n_n)-1)


  if(!is.null(forbidden)){
    # write error message
    forbidden_error_message = "'forbidden' must be a vector of non-zero integers matching the length of 'n', or NULL"
    # Parse forbidden as an integer vector
    forbidden = as.integer(forbidden)
    # Get length of forbidden vector
    n_forbidden = length(forbidden)
    # If is not equal to the number of decisions
    if(n_forbidden != n_n){ stop(forbidden_error_message) }

    # If no forbidden values supplied, then...
  }else if(is.null(forbidden)){
    # make forbidden a vector of NAs.
    forbidden = rep(NA_integer_, n_n)
  }

  # Write a mini enumeration function we'll call repeatedly
  enum_mini = function(n_alt, .forbidden){
    # Get all alternatives from 0 to the number of alternatives - 1
    alts = seq.int(from = 0, to = n_alt - 1, by = 1)
    # Remove any forbidden values
    alts = alts[!alts %in% .forbidden]
    return(alts)
  }


  # Make a list of values
  mylist = purrr::map2(
    # For each number of alternatives in n
    .x = n,
    # For each name in colnames
    .y = forbidden,
    # Make a tibble from 0 to the ith - 1 element in n,
    .f = ~tibble(d = enum_mini(n_alt = .x, .forbidden = .y))
  )

  # where the vector is named for the ith element in .y
  mylist = purrr::map2(
    .x = mylist,
    .y = colnames,
    .f = ~setNames(object = .x, nm = .y)
  )

  # Take that list of tibbles and expand the grid.
  #   Note:  !!! is a special character that lets lists of values
  #          be accepted as multiple separate function argument inputs.
  data = expand_grid(!!!mylist)

  if(.id == TRUE){
    data = data %>% mutate(id = as.integer(1:n()))
  }

  return(data)
}



#' @name one_arch_to_adjacency
#' @title Convert Architecture to Adjacency Matrix
#' @author Tim Fraser, PhD
#' @description Helper function for `arch_to_adjacency()`. Called in a loop.
#' 
#' @param data data.frame of edges, containing the fields `from`, `to`, and `value`, where `from` and `to` are `integers`.
#' 
#' @importFrom dplyr `%>%` mutate select
#' @importFrom tidyr pivot_wider
one_arch_to_adjacency = function(data){
  
  # data = edges %>%
  #  filter(id == 1)
  
  # Get the full range of values
  node_range = data %>% with(c(from, to)) %>% range()
  nodes = seq(from = node_range[1], to = node_range[2], by = 1)
  
  df = data %>%
    # Convert from and to into factors, with these levels,
    # so that pivot_wider can use id_expand and names_expand to fill out all levels.
    mutate(from = factor(from, levels = nodes),
           to = factor(to, levels = nodes)) %>%
    # Expand into wide format
    pivot_wider(
      id_cols = c(from), names_from = to, values_from = value,
      # Expand to include every one of the from id-names
      id_expand = TRUE, names_expand = TRUE,
      # Sort the names numerically
      names_sort = TRUE,
      # Fill in missing cells as 0.
      # Often diagonal is omitted, and should be zero.
      values_fill = list(value = 0))
  
  m = df %>% select(-from) %>% as.matrix()
  # Add the 'a' back in
  mycolnames = paste0("a", colnames(m))
  # Reassign column names
  colnames(m) <- mycolnames
  rownames(m) <- mycolnames
  return(m)
}


#' @name arch_to_adjacency
#' @title Convert Architecture(s) back to Adjacency Matrices
#' @author Tim Fraser
#' @description Intended to be used on data.frames generated by `enumerate_adjacency()`.
#' @param arch data.frame of architecture(s) form
#' @param .id name of architecture unique id column. (Typically is `"id"`.) Default is NULL.
#' @importFrom dplyr `%>%` mutate n select any_of tribble
#' @importFrom tidyr separate pivot_longer pivot_wider
#' @importFrom stringr str_extract
#' @examples
#' a = tribble(
#'  ~id, ~d1_a1_a2,  ~d1_a2_a1,
#'  1, 1,          0,
#'  2, 1,          1
#' )
#' arch_to_adjacency(arch = a, .id = "id")
#' @export
arch_to_adjacency = function(arch, .id = NULL){

  a = arch

  if(!is.null(.id)){
    # Check if id is present in your architecture names
    # If id is NOT present in your architecture names, add it
    if(!.id %in% names(a)){ a = a %>% mutate(id = as.integer(1:n()))  }

  }else{
    # If .id is null, just made an new id column
    a = a %>% mutate(id = as.integer(1:n()))
    .id = "id"
  }
  # Convert your architecture(s) to a tidy edgelist
  edges = a %>%
    # Pivot the architecture longways
    pivot_longer(cols = -c(any_of(.id)), names_to = "cell", values_to = "value", values_ptypes = list(value = integer())) %>%
    # Separate decision variable
    tidyr::separate(col = cell, into = c("did", "from", "to"), remove = TRUE) %>%
    # Convert from and to into integers
    mutate(from = str_extract(from, pattern = "[0-9]+") %>% as.integer(),
           to = str_extract(to, pattern = "[0-9]+") %>% as.integer())

  # For every architecture present,
  matrices = edges %>%
    # For the unique id of that architecture
    split(.$id) %>%
    # Generate the adjacency matrix, and return as a list of matrices.
    map(~one_arch_to_adjacency(.x))

  return(matrices)

}

#' @name one_arch_to_assignment
#' @title Convert One Architecture to Assignment Matrix
#' @author Tim Fraser, PhD
#' @description Helper function for `arch_to_assignment()`. Called in a loop.
#' 
#' @param data data.frame of edges, containing the fields `from`, `to`, and `value`, where `from` and `to` are `integers`.
#' 
#' @importFrom dplyr `%>%` mutate select
#' @importFrom tidyr pivot_wider
one_arch_to_assignment = function(data){
  
  # data = edges %>%
  #   filter(id == 1)
   
  # Get the full range of values for a
  a_node_range = data %>% with(a) %>% range()
  a_nodes = seq(from = a_node_range[1], to = a_node_range[2], by = 1)
  
  # Get full range of values for b
  b_node_range = data %>% with(b) %>% range()
  b_nodes = seq(from = b_node_range[1], to = b_node_range[2], by = 1)
  
  
  df = data %>%
    # Convert from and to into factors, with these levels,
    # so that pivot_wider can use id_expand and names_expand to fill out all levels.
    mutate(a = factor(a, levels = a_nodes),
           b = factor(b, levels = b_nodes)) %>%
    # Expand into wide format
    pivot_wider(
      id_cols = c(a), names_from = b, values_from = value,
      # Expand to include every one of the from id-names
      id_expand = TRUE, names_expand = TRUE,
      # Sort the names numerically
      names_sort = TRUE,
      # Fill in missing cells as 0.
      # Often diagonal is omitted, and should be zero.
      values_fill = list(value = 0))
  
  
  m = df %>% select(-a) %>% as.matrix()
  
  mycolnames = paste0("b", colnames(m))
  colnames(m) = mycolnames
  
  myrownames = paste0("a", df$a)
  rownames(m) <- myrownames
  
  return(m)
}

#' @name arch_to_assignment
#' @title Convert Architecture(s) back to Assignment Matrices
#' @author Tim Fraser
#' @description Intended to be used on data.frames generated by `enumerate_assignment()`.
#' @param arch data.frame of architecture(s) form
#' @param .id name of architecture unique id column. (Typically is `"id"`.) Default is NULL.
#' @importFrom dplyr `%>%` mutate n select any_of tribble
#' @importFrom tidyr separate pivot_longer pivot_wider
#' @importFrom stringr str_extract
#' @importFrom purrr map
#' @examples
#' a = tribble(
#'   ~id, ~d1_a1_b1, ~d1_a2_b1, ~d1_a2_b2, ~d1_a2_b3,
#'   1,    1,        0,         1,         0,
#'   2,    1,        0,         0,         1
#' )
#' arch_to_assignment(arch = a, .id = "id")
#' @export
arch_to_assignment = function(arch, .id = NULL){

  a = arch

  # Testing Example Data
  # a = tribble(
  #   ~id, ~d1_a1_b1, ~d1_a2_b1, ~d1_a2_b2, ~d1_a2_b3,
  #   1,    1,        0,         1,         0,
  #   2,    1,        0,         0,         1
  # )
  # .id = "id"

  if(!is.null(.id)){
    # Check if id is present in your architecture names
    # If id is NOT present in your architecture names, add it
    if(!.id %in% names(a)){ a = a %>% mutate(id = as.integer(1:n()))  }

  }else{
    # If .id is null, just made an new id column
    a = a %>% mutate(id = as.integer(1:n()))
    .id = "id"
  }

  # Convert your architecture(s) to a tidy edgelist
  edges = a %>%
    # Pivot the architecture longways
    pivot_longer(cols = -c(any_of(.id)), names_to = "cell", values_to = "value", values_ptypes = list(value = integer())) %>%
    # Separate decision variable
    tidyr::separate(col = cell, into = c("did", "a", "b"), remove = TRUE) %>%
    # Convert from and to into integers
    mutate(a = str_extract(a, pattern = "[0-9]+") %>% as.integer(),
           b = str_extract(b, pattern = "[0-9]+") %>% as.integer())

  
  # See code for `one_arch_to_assignment()`,
  # which gets looped below using purrr's map() function.

  # For every architecture present,
  matrices = edges %>%
    # For the unique id of that architecture
    split(.$id) %>%
    # Generate the assignment matrix, and return as a list of matrices.
    map(~one_arch_to_assignment(.x))

  return(matrices)

}




#' @name get_percentages
#' @title Tally percentages of each alternative for a decision variable in an architecture.
#' @param x vector of alternatives for a specific decision. As long as there are rows in the architectural matrix.
#' @param did string label of decision variable, eg. "d2" for decision 2
#' @importFrom dplyr mutate select group_by n summarize `%>%` tibble
#' @export
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