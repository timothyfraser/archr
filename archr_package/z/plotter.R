#' @name plotter
#' @title Plotter Functions for Stakeholder Network Analysis
#' @description
#' Let's try to wrangle the data so that we can match 
#' the general style of a stakeholder network from our slides.
#' 
#' Key things we need to support:
#' - Split an edge up into many points.
#' - Multiple edges per dyad
#' - Clear direction of edges
#' - Text placement for edge weights
#' - Blocky, left-right-up-down style edges rather than diagonals.

library(dplyr)
library(archr)
library(ggplot2)
# Get adjacency matrix 1
data("adj1", package = "archr")
# Get graph
g = get_graph(a = adj1)
# Get list of coordinates
gg = archr::get_coords(g = g)


# For each edge, interpolate several points
edges = gg %>%
  with(edges) %>%
  mutate(edgeid = 1:n()) %>%
  {
    bind_rows(
      select(., edgeid, from, to, value, x = to_x, y = to_y) %>%
        mutate(direction = "to"),
      select(., edgeid, from, to, value, x = from_x, y = from_y) %>%
        mutate(direction = "from")
    )
  }

ggplot() +
  geom_line(
    data = edges, 
    mapping = aes(x = x, y = y, group = edgeid))

interpolate = function(x, y, by = 0.01, nudge_x = 0.01, nudge_y = 0.01){
  # If you have a loop...
  if(length(unique(x)) == 1 & length(unique(y)) == 1){
    # Return just 1 value
    output= tibble(x = rep(x[1], 1), y = rep(y[1], 1))
    
  }else{
    # Interpolate
    xmin = min(x)
    xmax = max(x)
    xout = seq(from = xmin, to = xmax, by = by)
    output = approx(x = x, y = y, xout = xout, na.rm = TRUE) %>% 
      with(tibble(x, y))
  }
  return(output)
}



edge = tribble(
  ~edgeid, ~x, ~y, ~direction,
  1,   2,   2, "from",
  1,   4,   4, "to"
)
edge = tribble(
  ~edgeid, ~x, ~y, ~direction,
  1,   4,   4, "from",
  1,   2,   2, "to"
) 
edge = tribble(
  ~edgeid, ~x, ~y, ~direction,
  1,   2,   4, "from",
  1,   4,   2, "to"
) 
edge = tribble(
  ~edgeid, ~x, ~y, ~direction,
  1,   4,   2, "from",
  1,   2,   4, "to"
) 

nudge = 0.1

function(data){
  
# Take my end and if beginning, do this.
# If end, do that.
data2 = data %>%
  mutate(x = case_when(
    x == min(x) ~ x + nudge,
    x == max(x) ~ x - nudge
  ),
  y = case_when(
    y == min(y) ~ y + nudge,
    y == max(y) ~ y - nudge
  )
) %>%
  arrange(x,y) %>%
  group_by(edgeid) %>%
  mutate(id = 1:n()) %>%
  mutate(x = case_when(
    # If the first cell is the min x and min y, 
    x[id == 1] == min(x) & y[id == 1] == min(y) ~ x - nudge,
    x[id == 1] == min(x) & y[id == 1] == max(y) ~ x + nudge,
    x[id == 1] == max(x) & y[id == 1] == max(y) ~ x,
    x[id == 1] == max(x) & y[id == 1] == min(y) ~ x - nudge
  ),
  y = case_when(
    # If the first cell is the min x and min y,
    x[id == 1] == min(x) & y[id == 1] == min(y) ~ y + nudge,
    x[id == 1] == min(x) & y[id == 1] == max(y) ~ y + nudge,
    x[id == 1] == max(x) & y[id == 1] == max(y) ~ y,
    x[id == 1] == max(x) & y[id == 1] == min(y) ~ y - nudge
  )
  )
  
output = bind_rows(
  data,
  data2
)



ggplot() +
  geom_line(data = edge, mapping = aes(x =x, y =y, group = edgeid)) +
  geom_line(data = edge2, mapping = aes(x =x, y =y, group = edgeid), color = "red")  +
  geom_line(data = edge3, mapping = aes(x =x, y =y, group = edgeid), color = "blue") +
  geom_line(data = new, mapping = aes(x = x, y = y, group = edgeid), color = "grey")
edge2
edge3

interpolate(x = c(2,4), y = c(2,8), by = 0.01)

edges2 = edges %>%
  group_by(edgeid, from, to, value) %>%
  reframe(interpolate(x, y, by = 0.01)) %>%
  group_by(edgeid) %>% 
  # Add a unique id for each
  mutate(id = 1:n()) %>%
  # Make a position
  mutate(position = case_when(
    # For the first point, don't adjust
    id == 1 ~ "node",
    # or the last point, don't adjust
    id == n() ~ "node",
    # If the second point, adjust
    id == 2 & id != n() ~ "start",
    # If the second to last point, adjust
    id == n() - 1 & id != n() & id != 2 ~ "end",
    # Any others
    TRUE ~ "middle"
  )) %>%
    ungroup() %>%
  # Drop this one
  #filter(position != "end") %>%
  # Some function for assigning xadj and yadj and nudge
  mutate(xadj = 1, yadj = -1, nudge = 0.05) %>%
  # Now adjust the positions of the x and y values
  mutate(
    x = case_when(
      # If adjusting to the upper-right...
      xadj == 1 & yadj == 1 & position %in% c("start", "middle", "end") ~ x + nudge,
      
      # If adjusting to the lower-right...
      xadj == 1 & yadj == -1 & position %in% c("start", "middle", "end") ~ x + nudge,
      # If adjusting to the upper-left...
      xadj == -1 & yadj == 1 & position %in% c("start", "middle", "end") ~ x - nudge,
      # If adjusting to the lower-left...
      xadj == -1 & yadj == -1 & position %in% c("start", "middle", "end") ~ x - nudge,
      TRUE ~ x
    ),
    y = case_when(   
      # If adjusting to the upper-right...
      xadj == 1 & yadj == 1 & position %in% c("start", "middle", "end") ~ y + nudge,
      # If adjusting to the lower-right...
      xadj == 1 & yadj == -1 & position %in% c("start", "middle", "end") ~ y - nudge,
      # If adjusting to the upper-left...
      xadj == -1 & yadj == 1 & position %in% c("start", "middle", "end") ~ y + nudge,
      # If adjusting to the lower-left...
      xadj == -1 & yadj == -1 & position %in% c("start", "middle", "end") ~ y - nudge,
      TRUE ~ y
    )
  )  %>%
  # Edit the positions so that the ends are never further than the nodes 
  #group_by(edgeid) %>%
  #mutate()


ggplot() +
  geom_line(
    data = edges, 
    mapping = aes(x = x, y = y, group = edgeid)) +
  geom_line(
    data = edges2,
    mapping = aes(x =x, y=y, group = edgeid, color = position)
  ) +
  geom_line(
    data = edges2 %>% filter(edgeid == 1),
    mapping = aes(x =x, y=y, group = edgeid),
    color = "red", size = 0.5
  ) +
  coord_equal(ratio = 1, clip = "on")
edges2 %>% filter(edgeid == 1) %>% tail(10)
edges3 %>% filter(from == to)



  