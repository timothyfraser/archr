# tutorial_evaluation_4.R

# Load necessary libraries
library(dplyr)
library(ggplot2)

# 1. Reliability
# Let's learn some key terms.

# Lifespan Distribution: distribution (PDF) for a vector of product lifespans.
# Reflects the probability that a product failed after X hours or years
# Eg. Here's a vector of 10 items' lifespans, in hours.
products = c(24, 273, 41, 282, 14, 210, 325, 276, 96, 149)

products %>% hist()

products %>% density() %>% plot()

ggplot() +
  geom_density(data = tibble(products), mapping = aes(x = products))


# Mean Time to Failure: the mean of a lifespan distribution.
# Describes the average hours to failure per unit.
# Eg. let's get the MTTF for our products' life distribution.
mu = mean(products)

mu

# Failure Rate (Lambda): inverse of mean time to failure.
# Describes the average number of times a product fails per time-step (eg. per hour).
# Eg. let's get the Failure Rate for our products' life distribution.
lambda = 1 / mean(products)
lambda


# Exponential Distribution: a common form for lifespan distributions,
# characterized by one parameter, lambda.
# Note: MATLAB wants instead the mean time to failure (MTTF) for its exponential functions,
# but if you have lambda, you can get the MTTF.
# Eg. what's the cumulative probability of a product failing 
# at or before 100 hours, given an Exp. Distr. with MTTF mu?
pexp(100, rate = 1/mu)

# F(t) = 1 - exp(-lambda * t)
# F(t) = 1 - e^(-lambda*t)

# Probability of Failure F(t): cumulative probability of failure by time t.
# expcdf() will give you F(t) in an exponential distribution.
# Probability of Reliability/Survival R(t): cumulative probability it DOESN'T fail by time t.
# For example, R(t = 100) = 1 - expcdf(100, mu).
# Eg. what's the cumulative probability of product survives for 100 hours,
# given an Exp. Distr. with MTTF mu?
1 - pexp(100, rate = 1/mu)


# HOW TO VISUALIZE?

# Take a random sample!
rexp(n = 1000, rate = 1 / mu) %>% hist()

rexp(n = 1000, rate = 1 / mu) %>% density() %>% plot()

data = tibble(t = rexp(n = 1000, rate = 1 / mu))
ggplot() +
  geom_density(data = data, mapping = aes(x = t))

ggplot() +
  geom_density(data = data, mapping = aes(x = t))


# 2. System Reliability
# Series System: a system that requires each successive component to work. (Like a chain of dominos.)
# eg. [ A --> B --> C ]
# Series System Reliability: Chance all components survive. Written: R_s(t) = R_a(t) x R_b(t) x R_c(t).

# Suppose at time t = 100 hours...
r_a = 0.88
r_b = 0.99
r_c = 0.95
# 82% chance that the whole system stays reliable for 100 hours
r_a * r_b * r_c



# My coffee shop's system has 3 serially-connected components:
# A = coffee maker (MTTF = 500 hours)
# B = bean grinder (MTTF = 5000 hours)
# C = dishwasher   (MTTF = 1000 hours) 
# What's the probability the system survives 100 hours?
t <- 100

# Reliability of A (coffee maker) by time t
# R_a(t) = 1 - F_a(t)
r_a <- 1 - pexp(t, rate = 1/500)

# Reliability of B (bean grinder) by time t
r_b <- 1 - pexp(t, rate = 1/5000)

# Reliability of C (dishwasher) by time t
r_c <- 1 - pexp(t, rate = 1/1000)

# Reliability of System by time t = 100
r_s <- r_a * r_b * r_c
r_s

# Parallel System: a system that requires just 1 of multiple components to function. eg. [A1 or A2 or A3]
# Parallel System Reliability: Chance 1 of the components survives = 1 - probability ALL components fail. 
# Written: R_s(t) = 1 - ( F_a1(t) x F_a2(t) x F_a3(t) )

# Suppose we buy 3 coffee makers - as long as one works, we can maintain
# the system.
r_a1 <- r_a
r_a2 <- r_a
r_a3 <- r_a

# Let's find chance at least 1 remains functional.
r_a_parallel <- 1 - prod(1 - c(r_a1, r_a2, r_a3))
r_a_parallel

# If series
r_a1 * r_a2 * r_a3

# System Reliability: Using combinations of parallel and series systems, compute the reliability of the overall system!

# We could compute the reliability of the overall system at time t like so!
overall_reliability <- r_a_parallel * r_b * r_c
overall_reliability

# 3. Learning Curves
# We might also want to estimate the learning curve involved in certain decisions. 
# For example, suppose we have Decision X, 
# the choice to make and use tool A instead of tool B. 
# Decision X is costly to our time at first, 
# but over time, we are expected to get better at making tool A.
# Suppose Tool A has an S = 80% learning curve.

# Learning Curve Formula: Y = aX^b
# suppose a 80% learning curve 
s <- 0.80

# means each time quantity doubles, you gain 20% in efficiency.
gains <- 1 - s

# Calculate the slope of the learning curve
b <- log(s) / log(2.00)

# If it takes 30 hours to make 
# tool A at the beginning...
a <- 30

# What happens if we make tool A many times?
x <- c(1, 2, 5, 10, 20, 50, 100, 150, 200)

# Our slope suggests that the average time to make Tool A becomes...
y <- a * x^b
y

# Let's plot that learning curve!
data = tibble(x, y)



ggplot() +
  geom_line(data = data, mapping = aes(x = x, y = y)) +
  labs(x = "Number of times made (X)", y = "Average time (Y) to make Tool A")


# TWO LEARNING CURVES!!!!!!!! #########################

data2 = bind_rows(
  tibble(
    a = 30,
    x = c(1, 2, 5, 10, 20, 50, 100, 150, 200),
    s = 0.80,
    y = a * x^ (log(s) / log(2.00))
  ),
  tibble(
    a = 30,
    x = c(1, 2, 5, 10, 20, 50, 100, 150, 200),
    s = 0.90,
    y = a * x^ (log(s) / log(2.00))
  )
)


ggplot() +
  geom_line(data = data2, 
            mapping = aes(
              x = x, y = y,
              group = s, color = s)) +
  labs(x = "Number of times made (X)",
       y = "Average time (Y) to make Tool A")

# 3 LEARNING CURVES!! #######################


data3 = tibble(s = c(0.80, 0.85, 0.90, 0.92, 0.97, 0.99)) %>%
  # For each s...
  group_by(s) %>%
  # Make this vector!
  reframe(
    a = 30,
    x = c(1, 2, 5, 10, 20, 50, 100, 150, 200),
    y = a * x^ (log(s) / log(2.00))    
  )

# View it!
data3

# Visualize it!
ggplot() +
  # Let's make color = factor(s)
  # That splits the colors into a discrete color scale
  geom_line(data = data3, 
            mapping = aes(
              x = x, y = y,
              group = s, color = factor(s) )) +
  labs(x = "Number of times made (X)",
       y = "Average time (Y) to make Tool A")


# Z. Done!
# Clear environment
rm(list = ls())




# Demonstrate that Success of the System is much lower than Success of the Components

cpu = 0.99
keys = 0.98
keys2 = 0.999999999999
display = 0.96
mouse = 0.95
# Reliability of your system is just 88%
cpu * keys * display * mouse

# Two keys = 86%
cpu * keys^2 * display * mouse

# All keys = 40% 
cpu * keys^40 * display * mouse

# All keys = 40% 
cpu * keys2^40 * display * mouse








