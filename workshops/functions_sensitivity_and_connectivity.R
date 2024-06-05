# functions_sensitivity_and_connectivity.R

# FUNCTIONS ###############################
# Calculate main effect
me = function(data, decision = "d2", value = 1, metric = "m1"){
  # Testing values
  # decision = "d2"; value = 1; metric = "m1"
  data2 = data %>%
    # Grab any columns with these character strings as their column names
    select(any_of(c(alt = decision, metric = metric))) %>%
    # Add a decision column
    mutate(decision = decision) %>%
    # Reorder them
    select(decision, alt, metric)
  # Calculate effect
  data3 = data2 %>%
    summarize(
      xhat = mean(metric[alt == value], na.rm = TRUE),
      x = mean(metric[alt != value], na.rm = TRUE),
      dbar = xhat - x  
    )
  output = data3$dbar  
  
  return(output)
}

# Let's build a sensitivity function you can use to get 1 sensitivity score.

# Beginning attempt at a sensitivity
sensitivity = function(data, decision_i = "d2", metric = "m1"){
  # Testing Values
  # decision = "d2"; metric = "m1"
  # Get values for your ith decision
  values = unlist(unique(data[, decision_i]))
  
  
  # Create a table to hold my results
  holder = tibble(values = values, me = NA_real_)
  for(i in 1:length(values)){
    holder$me[i] = me(data, decision = decision_i, value = values[i], metric = metric)
  }
  
  s = holder %>%
    summarize(stat = mean(abs(me)))
  
  output = s$stat
  return(output)    
}

me_ij = function(data, decision_i, value_i, decision_j, value_j, metric = "m1", notj = FALSE){
  #Testing values
  # decision_i = "d3"; value_i = 1
  # decision_j = "d2"; value_j = 1
  # metric = "m1"; notj = TRUE
  
  data1 = data %>%
    select(any_of(c(di = decision_i, dj = decision_j, m = metric)))
  
  if(notj == TRUE){ 
    # given that dj != j
    data1 = data1 %>% filter(dj != value_j)   
  }else if(notj == FALSE){
    # given that dj == j
    data1 = data1 %>% filter(dj == value_j)  
  }
  
  output = data1 %>%
    # Reclassify decision i as does it equal value i or not
    mutate(di = di == value_i) %>% 
    # Get mean when di == i vs. when di != i
    summarize(xhat = mean(m[di == TRUE]),
              x = mean(m[di == FALSE]),
              diff = xhat - x) %>%
    # Return the difference
    with(diff)
  
  return(output)
}


sensitivity_ij = function(data, decision_i, decision_j, value_j, metric, notj = FALSE){
  #decision_i = "d3"; decision_j = "d2"; value_j = 1; metric = "m1"; notj = FALSE
  
  # Get all values of decision i
  data %>%
    select(any_of(c(di = decision_i))) %>%
    distinct() %>%
    # For each unique value of decision i
    group_by(di) %>% 
    # Get the interaction effect with the constant same value j of decision j
    summarize(
      stat = me_ij(data = data, decision_i = decision_i, value_i = di, 
                   decision_j = decision_j, value_j = value_j, 
                   metric = metric, notj = notj),
      .groups = "drop"
    ) %>%
    # Get absolute value
    mutate(stat = abs(stat)) %>%
    # Take mean
    summarize(stat = mean(stat, na.rm = TRUE)) %>%
    # return statistic
    with(stat)
}


connectivity_ij = function(data, decision_i, decision_j = "d2", metric = "m1"){
  # decision_i = "d3"; decision_j = "d2"; metric = "m1"
  data1 = data %>%
    select(any_of(c(dj = decision_j))) %>%
    distinct()  %>%
    # Get every combo of these with TRUE and FALSE
    expand_grid(notj = c(TRUE, FALSE)) %>%
    # For each set
    group_by(dj, notj) %>%
    # Get the sensitivity of decision i given decision j == or != value j
    summarize(
      stat = sensitivity_ij(data, decision_i = decision_i, decision_j = decision_j, value_j = dj, metric = metric, notj = notj),
      .groups = "drop") %>%
    ungroup()
  
  output = data1 %>%
    # For each...
    group_by(dj) %>%
    # Get the absolute difference
    summarize(stat = abs(diff(stat)),.groups = "drop") %>%
    # Now get the mean absolute difference
    summarize(stat = mean(stat)) %>%
    # Return the statistic
    with(stat)
  
  return(output)
}


# Get total connectivity of decision i
connectivity = function(data, decision_i = "d3", decisions = c("d1", "d2", "d3"), metric = "m1"){
  
  #decision_i = "d3"; decisions = c("d1","d2","d3"); metric = "m1"
  
  # Get the other decisions
  other_decisions = decisions[!decisions %in% decision_i]
  # Get a grid of all di-dj pairs
  output = expand_grid(
    di = decision_i,
    dj = other_decisions
  ) %>%
    # For each di-dj pair (specifically, for each dj)
    group_by(di,dj) %>%
    # Get the connectivity between decisions di and dj
    summarize(
      stat = connectivity_ij(data = data, decision_i = di, decision_j = dj, metric = metric),
      .groups = "drop"
    ) %>%
    ungroup() %>%
    # Now, take the mean of these statistics
    # You have one for each decision j,
    # as in each decision that is not i
    summarize(stat = sum(stat) / n()) %>% 
    with(stat)
  
  return(output)
}