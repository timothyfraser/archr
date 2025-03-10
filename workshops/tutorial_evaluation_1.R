#' @name tutorial_evaluation.R
#' @author Tim Fraser

## Tutorial: Evaluation - Measuring Risk!
## Dr. Fraser

# Today, we'll do several exercises! 
# Please try each Example (EX), followed by each Learning Check (LC)!

## PACKAGES ###############################
library(dplyr)
library(readr)

## DATA ####################################

# You're designing a donut delivery service in Ithaca!
  
# There are 500 possible ways (1 architecture = 1 row) to make the overall system.
# Each architecture includes 5 subsystems.
# Each subsystem takes a certain amount of development **time** with certain **costs**.

# Subsystem 1: Gimme Donuts App ("app")
# Subsystem 2: Donut Maker Machine ("mak")
# Subsystem 3: Donut Sprinkler & Decoration Service ("dec")
# Subsystem 4: Donut Quality Control & Taste Testing Office ("qc")
# Subsystem 5: Donut Delivery Cannon ("del")

# Fortunately, you've estimated, based on data from past studies, 
# statistics describing the **time** and **cost** distributions of each subsystem!

# Write them up using tribble() from dplyr!

# Cost distribution stats ($1000s) by subsystem
cost = tribble(
  ~type, ~system, ~dist,    ~mu, ~sigma,
  "cost", "app",  "normal", 40,  2,
  "cost", "mak",  "exponential", 30,  NA,
  "cost", "dec",  "normal", 60,  4,
  "cost", "qc",  "poisson", 20,  NA,
  "cost", "del",  "normal", 80,  5
)

# Time distribution stats (hours) by subsystem
time <- tribble(
  ~type, ~system, ~dist,        ~mu, ~sigma,
  "time", "app",  "normal",      500,   25,
  "time", "mak",  "exponential", 1500,  NA,
  "time", "dec",  "normal",      400,   25,
  "time", "qc",   "poisson",     1200,  NA,
  "time", "del",  "normal",      1300,  30
)



## EXAMPLE 1: SIMULATION ###################################################

## 1.1 We know the stats of the App Subsystem's Time distribution
# view the app row - it's a normal distribution
time

# grab stats 's'
s = time %>% filter(system == "app")



s$mu # access the mean ("mu")  
s$sigma  # access the standard deviation ("sigma")  




## 1.2 Calculate Quantities of Interest (QIs)


# Get Quantities of Interest
# Set benchmark 'bench'
bench = 520;


# Eg. What # of cases took exactly 520 hours to make "app"?
# --  P(x = 520) = ???
dnorm(bench, mean = s$mu, sd = s$sigma)

# -- Eg. What # of cases took <= 520 hours?
pnorm(bench, mean = s$mu, sd = s$sigma)

# What # of cases took MORE than 520 hours?
1 - pnorm(bench, mean = s$mu, sd = s$sigma)

# Joint probability of failure!

time %>%
  mutate(prob = 1 - pnorm(bench, mean = mu, sd = sigma))


p = time %>% 
  mutate(prob = case_when(
    # when normal...
    dist == "normal" ~  1 - pnorm(bench, mean = mu, sd = sigma),
    dist == "exponential" ~ 1 - pexp(bench, rate = 1 / mu),
    dist == "poisson" ~ 1 - ppois(bench, lambda = mu),
    # otherwise
    TRUE ~ NA
  ))

p %>% summarize(joint = prod(prob))


p


## 1.3 Calculate MANY Quantities of Interest

# Let's get 100 values...
n = 100;

p1 = tibble(
  bench = bench,
  x = seq(from = 420, to = 560, length.out = 100),
  fill = x < bench,
  prob = dnorm(x, mean = s$mu, sd = s$sigma)
)

ggplot() +
  geom_point(data = p1, mapping = aes(x = x, y = prob))

ggplot() +
  geom_area(data = p1, mapping = aes(x = x, y = prob))
ggplot() +
  geom_line(data = p1, mapping = aes(x = x, y = prob))


ggplot() +
  geom_area(data = p1, mapping = aes(x = x, y = prob)) +
  geom_line(data = p1, mapping = aes(x = x, y = prob), color = "steelblue", size = 2)


ggplot() +
  geom_area(data = p1, mapping = aes(x = x, y = prob, fill = fill)) 

ggplot() +
  geom_area(data = p1, mapping = aes(x = x, y = prob, fill = fill)) 



p2 = tibble(
  bench = bench,
  x = seq(from = 420, to = 560, length.out = 100),
  fill = x < bench,
  prob = dnorm(x, mean = s$mu, sd = s$sigma),
  # Cumulative probability
  cprob = pnorm(x, mean = s$mu, sd = s$sigma),
  # random values
  sim = rnorm(x, mean = s$mu, sd = s$sigma)
)

ggplot() +
  geom_area(data = p2, mapping = aes(x = x, y = cprob, fill = fill))

p2 %>% 
  select(sim)

ggplot() +
  geom_histogram(data = p2, mapping = aes(x = sim), fill = "steelblue", color = "black")


ggplot() +
  geom_histogram(data = p2, mapping = aes(x = sim), fill = "steelblue", color = "black")

ggplot() +
  geom_histogram(data = p2, mapping = aes(x = sim), fill = "#023402", color = "black")

ggplot() +
  geom_density(data = p2, mapping = aes(x = sim), fill = "#023402", color = "black")


colors()


  
