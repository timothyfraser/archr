# Script: 05_stakeholder_network_analysis_demo.R
# Original: lecture_4.R
# Topic: Stakeholder network analysis demo
# Section: Stakeholder Analysis
# Developed by: Timothy Fraser, PhD
#' @name lecture_4.R
#' @author Tim Fraser
#' @description Demo of Skill 1.3 Stakeholder Analysis

# install.packages("dplyr")
# If others need installing...
# install.packages("X")
# install.packages("archr_1.0.tar.gz", type = "source")

# Load packages
library(dplyr)
library(readr)
library(ggplot2)
library(archr)

# https://docs.google.com/spreadsheets/d/1VL0jSoWRq0CZqhpEMXQUaY7LQuqu5XbWHdgQ38wbawo/edit#gid=0
# 1VL0jSoWRq0CZqhpEMXQUaY7LQuqu5XbWHdgQ38wbawo

link = get_sheet(docid = "1VL0jSoWRq0CZqhpEMXQUaY7LQuqu5XbWHdgQ38wbawo", gid = "0")
e = link %>% read_csv()
e$from
e$to
e$value
e %>% select(from)

m = get_adjacency(edges = e)

m
# Get igraph object
g = get_graph(a = m)

g

plot(g)


e %>% head(3)
m
colnames(m)

e
g
scores = get_scores(g = g, root = "Project", var = "value")

scores

cycles = get_cycles(g = g, root = "Project", cutoff = 100, 
                    vars = "value")
cycles

# Gets me coordinates for each of my nodes and edges
gg = get_coords(g = g, layout = "kk")

gg$nodes
gg$edges

# ggplot2

gg$nodes

gg$edges

library(ggplot2)

gg$nodes
ggplot() +
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y) )


ggplot() +
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y)) +
  geom_segment(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y))



ggplot() +
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y),
             color = "pink", size = 10) +
  geom_segment(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    color = "blue", linewidth = 5)



ggplot() +
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y)) +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y))



ggplot() +
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y)) +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    arrow = grid::arrow(type = "closed") 
    )


ggplot() +
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y)) +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    arrow = grid::arrow(type = "closed") 
  ) +
  labs(x = "Stuff", y = "Stuff", 
       title = "More Stuff", subtitle = "Hi!",
       caption = "Still here!")


ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25,
    color = "grey", linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "blue", size = 3) 


ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25,
    color = "grey", linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "blue", fill = "gold", 
             size = 3, shape = 21) 



ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25,
    color = "grey", linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "white", fill = "black", 
             size = 3, shape = 21)  +
  geom_text(
    data = gg$nodes, 
    mapping = aes(x= x, y=y, label = name))


ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25,
    color = "grey", linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "white", fill = "black", 
             size = 3, shape = 21)  +
  geom_text(
    data = gg$nodes, 
    mapping = aes(x= x, y=y, label = name), nudge_y = 0.15)





ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25,
    color = "grey", linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "white", fill = "black", 
             size = 3, shape = 21)  +
  geom_text(
    data = gg$nodes, 
    mapping = aes(x= x, y=y, label = name), nudge_y = 0.15) +
  theme_void()





ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, 
                  xend = to_x, yend = to_y,
                  color = value),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25, linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "white", fill = "black", 
             size = 3, shape = 21)  +
  geom_text(
    data = gg$nodes, 
    mapping = aes(x= x, y=y, label = name), nudge_y = 0.15) +
  theme_void()



ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, 
                  xend = to_x, yend = to_y,
                  color = value),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25, linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "white", fill = "black", 
             size = 3, shape = 21)  +
  geom_text(
    data = gg$nodes, 
    mapping = aes(x= x, y=y, label = name), nudge_y = 0.15) +
  theme_void() +
  scale_color_gradient2(mid = "white", high = "red") +
  labs(color = "Stakeholder\nValue")



g2 = ggplot() +
  geom_curve(
    data = gg$edges, 
    mapping = aes(x = from_x, y = from_y, 
                  xend = to_x, yend = to_y,
                  color = value),
    arrow = grid::arrow(type = "closed"),
    curvature = 0.25, linewidth = 0.25
  ) + 
  geom_point(data = gg$nodes, mapping = aes(x = x, y = y), 
             color = "white", fill = "black", 
             size = 3, shape = 21)  +
  geom_text(
    data = gg$nodes, 
    mapping = aes(x= x, y=y, label = name), nudge_y = 0.15)

g2


g2 +
  theme_void(base_size = 14) +
  # Add as many optional settings here as you like, like
  theme(
    # put legend on the bottom
    legend.position = "bottom",
    # horizontally justify the plot title at 50% (0 = left and 1 = right)
    plot.title = element_text(hjust = 0.5)) +
  # Add some labels
  labs(color = "Value Flow", title = "Stakeholder Network for Technology X") +
  # We can add a color gradient, ranging from 0 to the max
  scale_color_gradient2(mid = "white", high = "red", midpoint = 0)


colors()


"steelblue"
"firebrick"

ggplot() +
  geom_point(data = gg$nodes, mapping = aes(x=x, y=y),
             size = 5, fill = "thistle1", shape = 21, color = "black")








