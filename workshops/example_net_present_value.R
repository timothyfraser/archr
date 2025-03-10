# example_net_present_value.R

# A script for learning how to calculate net present value

# Setup #####################################################
library(dplyr)
library(ggplot2)

# Net Present Value ###########################################

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

## Visualizing NPV ######################################3

# View the results
t

# Plotting NPV over time
ggplot(t, aes(x = time, y = npv)) +       
  geom_point() +
  labs(x = "Time", y = "Net Present Value") +
  ggtitle("Net Present Value Over Time")

# Cleanup
rm(list= ls())
