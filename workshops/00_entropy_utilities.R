# Script: 00_entropy_utilities.R
# Original: functions_entropy.R
# Topic: Information theory helpers
# Section: Evaluation
# Developed by: Timothy Fraser, PhD
#' @name h
#' @title h(x) 
#' @description Entropy `H(x)` of a random variable
#' @param x probabilities P(x) of event x occuring
h = function(x){  -1*sum( x*log(x, base = 2) )  }

#' @name j
#' @title j(x,y) 
#' @description Joint Entropy
#' @param xy probability P(x,y) = probability of event x and y occuring at the same time
j = function(xy){ -1*sum(  sum( (xy) * log(xy, base = 2) ) ) }


#' @name i
#' @title i(x,y) 
#' @description Mutual Information 
#' @param x probability P(x)
#' @param y probability P(y)
#' @param xy probability P(x,y) = probability of event x and y occurring at the same time
i = function(x,y, xy){
  sum( sum( xy * log( ( xy / (x * y) ),  base = 2) ) )
}

#' @name ig
#' @title Information Gain for Feature
#' @author Tim Fraser
#' @param .feature a binary TRUE/FALSE vector indicating whether that architecture displays a specific feature.
#' @param .good a binary TRUE/FALSE vector indicating whether that architecture is considered 'good'
#' @param .all binary TRUE/FALSE value, indicating whether to return a list of results, or just the stat data.frame
ig = function(good, feature = NULL, .all = FALSE){
  # Testing values
  # feature = a$f
  # good = a$good
  data = data.frame(good)
  # Make a list container for the output
  output = list()
  
  # Tally up frequency of good vs. bad architectures
  tally_good = data %>%
    group_by(good) %>%
    summarize(n = n(), .groups = "drop") %>%
    mutate(p = n / nrow(data))
  
  # Calculate entropy
  stat = tally_good %>% 
    summarize(h = h(p))
  
  # Add quantities to output
  output$prob = tally_good
  output$stat = stat
  
  # If feature is supplied...
  if(!is.null(feature)){
    data$feature = feature
    
    # Tally up frequency of good vs. bad given feature vs. not feature
    tally_feature = data %>%
      group_by(good, feature) %>%
      # Count the architectures
      summarize(n = n(), .groups = "drop") %>%
      group_by(feature) %>%
      mutate(total = sum(n),
             p = n / total)
    
    # Get entropy by feature
    h_by_feature = tally_feature %>%
      summarize(h = h(p),
                n = sum(n),
                fraction = n / nrow(data))
    
    # Get average weighted entropy
    stat1 = h_by_feature %>%
      summarize(h_split = sum(fraction * h) )
    
    # Get the information gain  
    stat = bind_cols(stat, stat1) %>%
      mutate(ig = h - h_split)
    
    # Add quantities to output
    output$prob_split = tally_feature
    output$stat = stat
  }
  
  if(.all == FALSE){
    output = output$stat
  }
  
  return(output)
}
