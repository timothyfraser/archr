#' @name tutorial_evaluation_5.R
#' @author Tim Fraser

# Load required libraries
library(dplyr)
library(ggplot2)


# 1. Net Present Value ########################################

# Let's practice calculating net present value!

# Suppose our donut-delivery system is expected
# to cost us $5000 each year to produce,
# but deliver us $30000 in revenue.
# We operate this system for 10 years. 

# However, suppose we face a high inflation rate of 5%, 
# so our money now will be worth less in the future. 
# Let's calculate the Net Present Value for each year.

# Create a data frame,
t = tibble(
  time = 1:5,      # Time periods
  # supposing a fixed annual cost and return...
  benefit = 30000, # Annual benefits
  cost = 5000,     # Annual costs
  # Where the funds lose 5% in value each year...
  discount = 0.05  # Discount rate
)

t

# Calculate net revenue
t = t %>% 
  mutate(netrev = benefit - cost)
t


# Calculate net present value for each time
t = t %>% 
  mutate(npv = netrev / (1 + discount)^time)


t



# View the results
t

# Plotting NPV over time
ggplot(t, aes(x = time, y = npv)) +       
  geom_point() +
  labs(x = "Time", y = "Net Present Value") +
  ggtitle("Net Present Value Over Time")


# 2. Estimating Cost Functions #################################

# smartboards
data = tribble(
  ~unit, ~cost,
   1,     2000,
   10,    16000,
   50,    90000,
   100,   140000,
)

# NY 
# 3 schools per town * 10 town * 1 county * 50 smartboards
# 150

ggplot() +
  geom_point(data = data, mapping = aes(x = unit, y = cost))


m = data %>% lm(formula = cost ~ unit)
# Cost = $4,920 + $1,418 * unit

get_cost = function(unit){ 4920 + 1418 * unit }

data2 = tibble(
  unit = 150,
  # pred = get_cost(unit), # this is equivalent
  pred = predict(m, newdata = tibble(unit))
)






data3 = tibble(
  unit = 1:150,
  pred = predict(m, newdata = tibble(unit))
)

data3

ggplot() +
  geom_point(data = data, mapping = aes(x = unit, y = cost)) +
  geom_line(data = data3, mapping = aes(x = unit, y = pred)) +
  geom_point(data = data2, mapping = aes(x = unit, y = pred), color = "red")


m2 = data %>% lm(formula = log(cost) ~ unit)
m2

# log = natural log
# log(x, 10)

# ln(cost) = 8.63484 ln$ + 0.03726 ln$ * unit 
data4 = tibble(
  unit = 1:150,
  pred = predict(m2, newdata = tibble(unit))
) %>%
  mutate(pred = exp(pred))


ggplot() +
  geom_point(data = data, mapping = aes(x = unit, y = cost)) +
  geom_line(data = data3, mapping = aes(x = unit, y = pred), color = "blue") +
  geom_line(data = data4, mapping = aes(x = unit, y = pred), color = "red") +
  geom_point(data = data2, mapping = aes(x = unit, y = pred), color = "blue")




# 3. Utility Functions ########################################

# As discussed in Lecture Evaluation III, 
# utility functions are functions that tell us 
# the utility (value-added) of a technology, called u(x), 
# given one or more predictors (called x). 

# These functions tend to be models (best fitting lines) 
# that approximate the relationship between x and u(x), 
# observed and recorded for a technology dozens and dozens of times.

# Utility functions can help us make decisions in our architecture 
# when it is not immediately clear which alternative(s) we should select.
# When multiple attributes (x-es) contribute to
# the utility of a decision/technology,
# we can form **multi-attribute** or **multi-linear** utility functions
# to combine them. 

# The key requirement is, 
# the attributes you are combining need to be independent; 
# otherwise, you'll be overweighting or doublecounting 
# some attributes more than others.

# Here are several ways to build utility functions to multiple attributes.


## EXAMPLE: DRONE UTILITY ###############################

# Let's do a quick example.
# Let's say you're deploying your donut-delivery system, 
# and you're deciding whether to develope a drone-delivery system or not.

# Let's say it's not entirely certain that 
# your drone-delivery subsystem will work.
# Maybe it has a chance of failure of 5%, 
# so the chance it works reliably is 95%. 
# The payoff of this drone delivery system working is $10,000. 
# In contrast, if the drone delivery system fails, you will owe $5000! 

# Let's calculate the expected utility from this uncertain choice.

# Define probabilities
p_fail = 0.05
p_works = 1 - p_fail

# Define utility function for pay
# Choose what means min utility (0) for you
pay_min = 0
# Choose what means max utility (1) for you
pay_max = 10000


# Calculate utility of drone working (by rescaling)
pay_works = 10000
u_pay_works = (pay_works - pay_min) / (pay_max - pay_min)




# Calculate utility if drone fails
pay_fail = -5000
u_pay_fail = (pay_fail - pay_min) / (pay_max - pay_min)



# Calculate expected utility that you would earn
# Expected utility here is ~0.93
u_pay = p_works * u_pay_works + p_fail * u_pay_fail
u_pay # View




# Suppose there are extra forms of utility here, 
# not just utility in terms of pay. 

# Maybe your drone system will generate 
# 10 kilotons of carbon emissions if it works, 
# while if it fails, 
# you will still have produced 3 kilotons of emissions in production. 

# Suppose that society views 20 kilotons of emissions 
# as the worst possible emissions for a delivery system of your size.


# Define utility function for emissions
e_min = 0
e_max = 20

e_works = 10

u_e_works = (e_works - e_min) / (e_max - e_min)

e_fail = 3
u_e_fail = (e_fail - e_min) / (e_max - e_min)


# So the expected utility here is ~0.52 on a scale from 0 to 20.
# Calculate expected utility for emissions
u_e = p_works * u_e_works + p_fail * u_e_fail
u_e # View
1 - u_e


# We now need to combine these forms of utility. 
# Conveniently they are measured on the same 0 to 1 scale, 
# but we have to decide 
# (either theoretically, analytically, or based on empirical data) 
# how to weight pay versus emissions when combining them.

# Suppose that our mission statement agreed to let us 
# weight **emissions** at an importance level of 30% 
# versus **profitability** at an importance level of 70%.

# Define weights
w_e = 0.30
w_pay = 0.70

# Combine utilities
t = tibble(
  type = c("emissions", "pay"),           # Types of utilities
  # remember to make high emissions BAD
  # remember direction matters!
  u = c(1 - u_e, u_pay),                      # Utility values
  w = c(w_e, w_pay)                       # Weights
)

t

# We can combine them several different ways.

# Calculate combined utility additively
combined_additive = sum(t$u * t$w)
combined_additive

# Calculate combined utility multiplicatively
combined_multiplicative = prod(t$u * t$w)
combined_multiplicative



# Or if we know that high profitability 
# and low emissions together have an interaction effect on utility, 
# by attracting more users, prestige, etc., 
# we could add that interaction effect as a weight called w_e_pay too. 
# (This one is a little harder, 
# because you should have some rationale for it.)


# MONTE CARLO SIMULATION 1 #############################################

r = tibble(
  mu = 500 # miles
)
# mean time to failure! = mean miles travelled
# failure rate = 1 / mean time to failure
# use it in an exponential distribution
# take 1000 random samples from that distribution

r2 = r %>%
  reframe(sim = rexp(n = 1000, rate = 1 / mu))

r3 = r2 %>%
  summarize(
    p50 = quantile(sim, probs = 0.50),
    p75 = quantile(sim, probs = 0.75),
    sd = sd(sim),
    mean = mean(sim),
    max = max(sim),
    min = min(sim),
    p99 = quantile(sim, prob = 0.99),
    p01 = quantile(sim, prob = 0.01)
  )

r3


# MONTE CARLO SIMULATION 2 ###################################

library(archr)
library(dplyr)

# Say we've got 3 binary decisions
# d1 = EIRP of transmitter  (option 1 vs. option 0)
# d2 = G/T of receiver  (option 1 vs. option 0)
# d3 = Slant Range (option 1 vs. option 0)
a = archr::enumerate_binary(n = 3)

# Let's write a function that will help us 
# measure performance while incorporating uncertainty!

get_performance = function(d1,d2,d3, n = 1000, benchmark = 0){
  
  # testing values
  # d1 = 1; d2 = 1; d3 = 1; n = 1000; benchmark = 0;
  
  # d1 = EIRP of transmitter  (option 1 vs. option 0)
  sim1 = case_when(d1 == 1 ~ rnorm(n = n, mean = 30, sd = 5),
                 d1 == 0 ~ rnorm(n = n, mean = 0, sd = 0) )
  # d2 = G/T of receiver  (option 1 vs. option 0)
  sim2 = case_when(d2 == 1 ~ rnorm(n = n, mean = 0, sd = 2),
                 d2 == 0 ~ rnorm(n = n, mean = 0, sd = 0))
  # d3 = Slant Range (option 1 vs. option 0)
  sim3 = case_when(d3 == 1 ~ rnorm(n = n, mean = 4, sd = 2),
                   d3 == 0 ~ rnorm(n = n, mean = 0, sd = 0))
    
  # Get total simulated metrics
  sim = sim1 + sim2 + sim3
  
  # Calculate percentage that are less than benchmark!
  metric = sum(sim < benchmark) / length(sim)

  return(metric)
}

get_performance(d1 = 1, d2 = 2, d3 = 3, n = 1000, benchmark = 0)




library(archr)
library(dplyr)

# Say we've got 3 binary decisions
# d1 = EIRP of transmitter  (option 1 vs. option 0)
# d2 = G/T of receiver  (option 1 vs. option 0)
# d3 = Atmospheric Losses (option 1 vs. option 0)
a = archr::enumerate_binary(n = 3)



get_performance = function(d1, d2, d3, n, benchmark){
  # Testing values
  # d1 = 1; d2 = 1; d3 = 1; n = 100; benchmark = 30  
  
  # Performance = Quality of Connectivity (dB)
  
  # transmitter
  # m1 = case_when(d1 == 1 ~ 30,  d1 == 0 ~ 0)
  sim1 = case_when(d1 == 1 ~ rnorm(n = n, mean = 30, sd = 5), 
                   d1 == 0 ~ rnorm(n = n, mean = 0, sd = 0) )
  # receiver
  sim2 = case_when(d2 == 1 ~ rnorm(n = n, mean = 0, sd = 2),
                   d2 == 0 ~ rnorm(n = n, mean = 0, sd = 0) )
  # climate that the tech is deployed in
  sim3 = case_when(d3 == 1 ~ rnorm(n = n, mean = 4, sd = 2),
                   d3 == 0 ~ rnorm(n = n, mean = 0, sd = 0))
  # combine
  sims = sim1 + sim2 + sim3 
  
  # sims %>% hist()
  # Option 1
  # metric = mean(sims)

  # Option 2
  # metric = sd(sims)
  
  # Option 3
  # metric = sd(sims)
  # metric = metric < benchmark
  
  # Option 4
  metric = sum(sims < benchmark) / n
  
  return(metric)
}

get_performance(d1 = 1, d2 = 1, d3 = 1, n = 100, benchmark = 2)
get_performance(d1 = 0, d2 = 0, d3 = 0, n = 100, benchmark = 2)

get_performance(d1 = 1, d2 = 1, d3 = 1, n = 100, benchmark = 30)


a %>% 
  rowwise() %>%
  mutate(m1 = get_performance(d1 = d1, d2 = d2, d3 = d3, n = 1000, benchmark = 30)) %>%
  ungroup()











