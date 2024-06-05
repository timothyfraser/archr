#' @name tutorial_enumeration_6.R

# random sample from a uniform distribution
# -- 2 parameters min (a) and max (b)
runif(n = 5, min = 0, max = 10)

library(dplyr)

data = tibble(
  x = runif(n = 10000, min = 0, max = 1),
  y = runif(n = 10000, min = 0, max = 1))

# Population
g1 = ggplot() +
  geom_point(data = data, mapping = aes(x = x, y = y),
             alpha = 0.1)

sample1 = data %>%
  sample_n(size = 100)

g2 = ggplot() +
  geom_point(data = sample1, mapping = aes(x = x, y = y), 
             alpha = 0.1)

sample2 = data %>%
  mutate(x_quarters = ntile(x, 4),
         y_quarters = ntile(y, 4)) %>%
  group_by(x_quarters, y_quarters) %>%
  sample_n(size = round(100/16))

g3 = ggplot() +
  geom_point(data = sample2, mapping = aes(x = x, y = y), 
             alpha = 0.1)

library(ggpubr)

ggarrange(g1,g2,g3, nrow = 1)





