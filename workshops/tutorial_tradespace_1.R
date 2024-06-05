#' @name tutorial_tradespace_1.R
#' @author Tim Fraser

# 0. SETUP ##########################################################

library(dplyr)
library(archr)
library(ggplot2)

archs = enumerate_binary(n = 5, .id = TRUE)


# 1. FUNCTIONS ##################################################

# Cost metric function
get_cost = function(d1,d2,d3,d4,d5){
  m1 = case_when(d1 == 1 ~ 40, TRUE ~ 0)
  m2 = case_when(d2 == 1 ~ 750, TRUE ~ 0)
  m3 = case_when(d3 == 1 ~ 200, TRUE ~ 0)
  m4 = case_when(d4 == 1 ~ 500, TRUE ~ 0)
  m5 = case_when(d5 == 1 ~ 1000, TRUE ~ 0)
  output = m1+m2+m3+m4+m5
  return(output)
}

# Benefit metric function
get_benefit = function(d1,d2,d3,d4,d5){
  # 10-point ordinal scale
  m1 = case_when(d1 == 1 ~ 3, TRUE ~ 2)
  m2 = case_when(d2 == 1 ~ 2, TRUE ~ 4)
  m3 = case_when(d3 == 1 ~ 5, TRUE ~ 7)
  m4 = case_when(d4 == 1 ~ 9, TRUE ~ 2)
  m5 = case_when(d5 == 1 ~ 5, TRUE ~ 3)
  output = m1+m2+m3+m4+m5
  return(output)
}

# Reliability metric function
get_reliability = function(t = 100, d1,d2,d3,d4,d5){
  # Several ways to model a decision's impact on overall reliability...
  # Option 1:
  # If we adopt technology d1=1, the failure rate is 1/1000, so the reliability at time t will be...
  p1 = case_when(d1 == 1 ~ 1 - pexp(t, rate = 1/1000),
                 # If we DON'T adopt that technology, the OTHER technology has a failure rate of 1/10000
                 d1 == 0 ~ 1 - pexp(t, rate = 1/10000))
  # Option 2:
  p2 = case_when(
    # If we adopt tech d2=1....
    d2 == 1 ~ 1 - pexp(t, rate = 1/2000),
    # If we DON'T adopt tech d2=1, no tech to fail, so R=1
    TRUE ~ 1)
  p3 = case_when(d3 == 1 ~ 1 - pexp(t, rate = 1/15000), TRUE ~ 1)
  p4 = case_when(d4 == 1 ~ 1 - pexp(t, rate = 1/5000), TRUE ~ 1)
  # Option 3:
  # Maybe d5 has no relevance to operational risk.
  # p5 = case_when(d1 == 1 ~ 1 - pexp(t, rate = 1/500000), TRUE ~ 1)
  # Whether d5=1 or d5=0, reliability will still be 100%
  p5 = 1
  
  output = p1*p2*p3*p4*p5
  return(output)
}

# 2. METRICS ###########################################################################
archs = archs %>% mutate(cost = get_cost(d1,d2,d3,d4,d5))
archs = archs %>% mutate(benefit = get_benefit(d1,d2,d3,d4,d5))
archs = archs %>% mutate(reliability = get_reliability(t = 1000, d1,d2,d3,d4,d5))

archs

# 3. PAIRWISE CORRELATION PLOT ######################################################### 
# install.packages("GGally")
library(GGally)
archs %>%
  select(cost, benefit, reliability) %>%
  GGally::ggpairs(data = ., title = "Title")

?ggpairs
# https://ggobi.github.io/ggally/articles/ggpairs.html


gg1 = ggplot() + geom_point(data = archs, mapping = aes(x = benefit, y = cost)) + theme_bw()
gg2 = ggplot() + geom_point(data = archs, mapping = aes(x = benefit, y = reliability)) + theme_bw()
gg3 = ggplot() + geom_point(data = archs, mapping = aes(x = cost, y = reliability)) + theme_bw()
library(ggpubr)
ggarrange(gg1,gg2,gg3, nrow = 1)



# 4. PARALLEL COORDINATES PLOT ########################################################

lines = archs %>%
  # Convert metrics into z-scores
  mutate(cost = scale(cost),
         benefit = scale(benefit),
         reliability = scale(reliability)) %>%
  # For each architecture...
  group_by(id) %>%
  # Reframe the metrics into this shape
  reframe(
    type = c("cost", "benefit", "reliability"),
    value = c(cost, benefit, reliability),
    # Keep features 
    d1 = c(d1,d1,d1),
    d2 = c(d2,d2,d2),
    d3 = c(d3,d3,d3),
    d4 = c(d4,d4,d4),
    d5 = c(d5,d5,d5)
  )



gg = ggplot() +
  theme_bw() +
  geom_line(
    data = lines, 
    # Make one line per id
    mapping = aes(x = type, y = value, group = id,
                  # Color the lines by feature
                  color = factor(d5) ))  
gg # view it

# Add labels
gg = gg + 
  labs(title = "Metrics for N = 32 architectures",
       color = "Decision 5",
       y = "Metric Value (Z-score)",
       x = "Type of Metric")
gg

# Relabel axis values
gg = gg + 
  scale_x_discrete(
    # Adjust labels
    labels = c("benefit" = "Benefit", "cost" = "Cost", "reliability" = "Reliability"),
    # Change the amount of white space
    expand = expansion(c(0.05, 0.05))) +
  # Adjust labels
  scale_color_discrete(labels = c("0" = "Not Adopted", "1" = "Adopted")) 
gg

# Add a nice border
gg = gg + 
  theme_classic() +
  theme(panel.border = element_rect(fill = NA, color = "black"))

# View it!
gg



# 5. Radar ##########################################################
# Don't recommend.
gg + coord_polar()



# 6. K-Means ########################################################
library(broom)

k = archs %>%
  mutate(cost = scale(cost),
         benefit = scale(benefit),
         reliability = scale(reliability)) %>%
  select(cost, benefit, reliability) %>%
  kmeans(x = ., centers = 3)

k

k$cluster
# Easy way to extract values in a data.frame

# Cluster means
k %>% broom::tidy()

# Clustering Model statistics
k %>% broom::glance()


# Update with cluster id
archs = archs %>%
  # Add the cluster id in
  mutate(cluster = factor(k$cluster))

archs

gg1 = ggplot() +
  theme_bw() +
  geom_point(data = archs, 
             mapping = aes(x = benefit, y = cost, 
                           color = cluster),
             size = 5)
gg1

gg2 = ggplot() +
  theme_bw() +
  geom_point(data = archs, 
             mapping = aes(x = reliability, y = cost, color = cluster),
             size = 5)

gg3 = ggpubr::ggarrange(gg1,gg2, common.legend = TRUE)

gg3


# 7. Pareto Front ###########################################

# Get pareto front
archs = archs %>%
  mutate(pareto = pareto(x = cost, y = -benefit))

archs

ggplot() +
  geom_line(data = archs %>% filter(pareto == TRUE),
            mapping = aes(x = benefit, y = cost)) +
  geom_point(data = archs, mapping = aes(x = benefit, y = cost, color = pareto),
             size = 3)

archs = archs %>%
  mutate(pareto = pareto(x = cost, y = benefit))

ggplot() +
  geom_line(data = archs %>% filter(pareto == TRUE),
            mapping = aes(x = benefit, y = cost)) +
  geom_point(data = archs, mapping = aes(x = benefit, y = cost, color = pareto),
             size = 3)

archs = archs %>%
  mutate(pareto = pareto(x = cost, y = reliability))

ggplot() +
  geom_line(data = archs %>% filter(pareto == TRUE),
            mapping = aes(x = reliability, y = cost)) +
  geom_point(data = archs, mapping = aes(x = reliability, y = cost, color = pareto),
             size = 3)


# 8. ARM metrics ############################################

archr::get_arm

?archr::get_arm

# Driving Features of being in the Pareto Front
archs %>%
  select(d1, d2, pareto) %>%
  archr::get_arm(p = "pareto")

archs %>%
  select(d1, d2, front = pareto) %>%
  archr::get_arm(p = "front")

# Multiple features
archs %>%
  select(d1, d2, d3, pareto) %>%
  archr::get_arm(p = "pareto")

# Driving Features of being in Cluster 1
archs %>%
  #mutate(cluster1 = cluster == 1) %>%
  mutate(cluster1 = case_when(cluster == 1 ~ TRUE, cluster != 1 ~ FALSE)) %>%
  select(d1, d2, cluster1) %>%
  archr::get_arm(p = "cluster1")


archs %>%
  #mutate(cluster2 = cluster == 1) %>%
  mutate(cluster2 = case_when(cluster == 2 ~ TRUE, cluster != 2 ~ FALSE)) %>%
  select(d1, d2, d3, d4, cluster2) %>%
  archr::get_arm(p = "cluster2")

# Visualize that!


viz = archs %>%
  select(d1, d2, d3, d4, d5, pareto) %>%
  archr::get_arm(p = "pareto")

ggplot() +
  geom_col(data = viz, mapping = aes(x = did, y = lift_f_p))


viz2 = archs %>%
  # Create your own composite feature
  mutate(f = case_when(d1 == 1 & d2 == 0 & d3 == 1 ~ 1,   TRUE ~ 0)) %>%
  select(f, d1, d2, d3, d4, d5, pareto) %>%
  archr::get_arm(p = "pareto")

ggplot() +
  geom_col(data = viz2, mapping = aes(x = did, y = lift_f_p))


ggplot() +
  geom_col(data = viz2, mapping = aes(x = reorder(did, -lift_f_p), y = lift_f_p))


ggplot() +
  geom_col(data = viz2, mapping = aes(x = reorder(did, -lift_f_p), y = lift_f_p,
                                      fill = lift_f_p)) +
  scale_fill_gradient(low = "salmon", high = "skyblue")




