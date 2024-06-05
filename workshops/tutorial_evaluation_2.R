#' @name tutorial_evaluation_2.R
#' @author Tim Fraser

# Continuing tutorial_evaluation_1.R,
# Let's practice using some of our new R probability functions.

# Load required libraries
library(dplyr)
library(readr)
library(ggplot2)

# Import them, then view them with captions!
# See the spreadsheet here:
# url = "https://docs.google.com/spreadsheets/d/1fAOp-EF-eBYww33F3oYMAwIfgFJOFUtySZtKuih12aw/edit?usp=sharing"
# Download link
link = "https://docs.google.com/spreadsheets/d/1fAOp-EF-eBYww33F3oYMAwIfgFJOFUtySZtKuih12aw/export?format=csv&gid=0"
# Load table
t = link %>% read_csv() 



# EXAMPLE 1: PROBABILISTIC PROJECTIONS ###########################################
# Set parameters
bench <- 520 # suppose 520 hours is our firm deadline from funders

# Suppose we're making our app subsystem, 
# where past studies say it takes an average of 500 hours to make an app, 
# with a standard deviation of 25 hours, for your size of team.

# Eg. What % of cases would should we expect take > 520 hours?
# Assume a normal distribution.
1 - pnorm(bench, mean = 500, sd = 20)




# What if an exponential distribution fit this better?
# The rate (lambda) of an exponential distribution is 1 / mean time
1 - pexp(bench, rate = 1/500)






# What if a poisson distribution fit this better?
# The lambda of a poisson distribution is the **mean** time 
1 - ppois(bench, lambda = 500)


# 100 random draws if normal.......
rnorm(n = 100, mean = 500, sd = 25)


# pnorm - probabilities
# rnorm - actual simulated times


# LEARNING CHECK 1: SIMULATION
# Choose another subsystem and analyze it!
# -- 1A. What % of its possible architectures take OVER 600 hours?

# -- 1B. Take a 100 random draws from that distribution, and view its histogram!




# Quality Control
t %>% filter(type == "time")
# -- mu: 1200 hours
# -- poisson
# -- 1A. What % of its possible architectures take OVER 600 hours?

bench = 600
1 - ppois(bench, lambda = 500)

# -- 1B. Take a 100 random draws from that distribution, and view its histogram!
rpois(n = 100, lambda = 500)


rpois(n = 100, lambda = 500) %>% hist()


# Delivery System
# -- 1A. What % of its possible architectures take OVER 600 hours?
1 - pnorm(600, mean = 1300, sd = 30)

# -- 1B. Take a 100 random draws from that distribution, and view its histogram!
rnorm(n = 100, mean = 1300, sd = 30) %>% hist()





# EXAMPLE 2: SIMULATE OVERALL SYSTEM #################################

# tibble(
#   app = rnorm(n = 1000, mean = 500, sd = 25),
#   mak = rexp(n = 1000, rate = 1 / 1500),
#   dec = rnorm(n = 1000, mean = 400, sd = 25)
# )

o <- tibble(
  app = rnorm(n = 1000, mean = 500, sd = 25),
  mak = rexp(n = 1000, rate = 1 / 1500),
  dec = rnorm(n = 1000, mean = 400, sd = 25),
  qc = rpois(n = 1000, lambda = 1200),
  del = rnorm(n = 1000, mean = 1300, sd = 30)
)

o %>%
  mutate(id = 1:n()) %>%
  group_by(id) %>%
  mutate(max = max(c(app, mak, dec, qc, del)))
  
o %>%
  rowwise() %>%
  mutate(max = max(c(app, mak, dec, qc, del)))


o %>%
  rowwise() %>%
  mutate(sum = sum(c(app, mak, dec, qc, del)))



o = o %>%
  rowwise() %>%
  mutate(max = max(c(app, mak, dec, qc, del))) %>%
  mutate(sum = sum(c(app, mak, dec, qc, del))) 

o

# Get max
o = o %>% 
  rowwise() %>%
  mutate(max = max(c(app, mak, dec, qc, del)))

# Get total
o = o %>% 
  rowwise() %>%
  mutate(sum = sum(c(app, mak, dec, qc, del)))


# 2.3 Compute Quantities of Interest
# View the histogram / approximate the PDF!
ggplot(o, aes(x = sum)) +
  geom_histogram(binwidth = 100, fill = "green", color = "black") +
  labs(x = "System Completion Time (hours)", y = "Frequency")

ggplot(o, aes(x = max)) +
  geom_histogram(binwidth = 100, fill = "purple", color = "black") +
  labs(x = "Max Subsystem Completion Time (hours)", y = "Frequency")

# Compute the median, mean, and standard deviation of this distribution!
# If simultaneously...
median(o$max)
mean(o$max)
sd(o$max)

# "If sequentially...
median(o$sum)
mean(o$sum)
sd(o$sum)

# Suppose we have an 1800-hour deadline.
# What's the chance it takes >1800 hours if done **simultaneously**?
1 - ppois(1800, lambda = mean(o$max))

# TASK 2: SIMULATE OVERALL SYSTEM
# Try your best to repeat this process, but this time,
# simulate the **TOTAL COST** of the system overall,
# using our table t above!
t %>% filter(type == "cost")


k = tibble(
  app = rnorm(n = 1000, mean = 40, sd = 2),
  mak = rexp(n = 1000, rate = 1 / 30),
  dec = rnorm(n = 1000, mean = 60, sd = 4),
  qc = rpois(n = 1000, lambda = 20),
  del = rnorm(n = 1000, mean = 80, sd = 5)
)

k %>% 
  rowwise() %>% 
  mutate(sum = sum(c(app:del)))



# If you need to do it without using specific values
t %>%
  filter(type == "cost") %>%
  group_by(system) %>%
  reframe(
    id = 1:n(),
    sim = case_when(
    dist == "normal" ~ rnorm(n = 1000, mean = mu, sd = sigma),
    dist == "exponential" ~ rexp(n = 1000, rate = 1 / mu),
    dist == "poisson" ~ rpois(n = 1000, lambda = mu)
  )) 





# EXAMPLE 3: SIMULATING DISCRETE DISTRIBUTIONS
# Let's say in the Donut Cannon Subsystem,
# every cannon has the same reliability (p = 95%)
p <- 0.95
# If we have n donuts we want to launch...
n <- 10
# We can calculate using a binomial distribution PDF quantities of interest

# 3.1 What's the probability that 9 out of 10 land successfully?
dbinom(9, size = n, prob = p)

# 3.2 What's the probability that at least 9 land successfully?
pbinom(9, size = n, prob = p)

# more than 9
1 - pbinom(9, size = n, prob = p)

# 3.3 What's the expected number of donuts that land safely?
rbinom(100, n, p) %>% mean()
rbinom(100, n, p) %>% sd()




