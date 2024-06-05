#' @name workshop_1.R
#' @title Workshop 1
#' @author Tim Fraser
#' @description 
#' In-Class Demo script for Workshop 1.
#' Pairs with Workshop 1 HTML document. Be sure to read the HTML doc!



# addition 
1 + 1



# make object 'x'
x = 2

x + 2

# make new objects
y = x + 2
y

# Remove specific objects
remove(x,y)
# Clear everything all at once
rm(list = ls())


# Install
install.packages(c("dplyr", "readr", "ggplot2"))

# Load packages
library(dplyr)
library(readr)
library(ggplot2)



myvec = c(1,2,3,4)

myvec

myrow = matrix( c(1,2,3,4), nrow = 1)

mycol = matrix( c(1,2,3,4), ncol = 1)

matrix(c(myrow, myrow, myrow), byrow = TRUE, ncol = 4)


matrix(c(mycol, mycol, mycol), byrow = FALSE, ncol = 3)

# make a table - called a data.frame

data.frame(
  x = c(1,2,3),
  y = c("corgi", "dalmatian", "goldendoodle"),
  z = c(1, 2, "3")
)


matrix(c(1,2,3, 4,5,6, 7,8,9), byrow = TRUE, nrow = 3, ncol = 3)


mymat3 = matrix(
  # put comments inside of these chunks
  c(1,2,3, 
    4,5,6, 
    7,8,9), 
  # settings
  byrow = TRUE, nrow = 3, ncol = 3)


mymat3^2

mymat3*2

mymat3 + mymat3


mymat3 %*% mymat3






day = c("M", "T", "W", "R", "F")
temp = c(30, 20, 25, 27, 29)
t = data.frame(day, temp)

t$day
t$temp + 2

t$temp


t$temp = t$temp + 2


t$snow = c("yes", "no", "yes", "no", "no")

t$rain = c("yes", "no", "no", "no", NA)



t[1:3, 2]

mymat3[1, 2:3]


rm(list = ls())


t = readr::read_csv("workshops/test_data.csv")

t$id
t$coffees
t$sale

# .rds - r data storage
m = readr::read_rds("workshops/test_data.rds")

m


readr::write_csv(t, file = "workshops/test_data2.csv")

write_csv(t, file = "workshops/test_data2.csv")

write_rds(as.matrix(t), file = "workshops/test_data2.rds")


rm(list = ls())



# input(s)
# output
# process

plusone = function(inputs){ output = inputs; output }
plusone = function(inputs){ output = inputs; return(output) }
plusone = function(inputs){ 
  output = inputs;
  output 
}


plusone(inputs = 2)

remove(plusone)

plusone = function(x){  y = x + 1; return(y)   }
plusone(x = 2)
plusone(x = c(2,3))


plustwo = function(x){  y = x + 2; return(y)  } 
plustwo(x = c(2,3))


# How to use dplyr package


plustwo(plusone(x = 1))
library(dplyr)


# pipeline
%>%
%>%

# shortcut: ctl shift m
%>% %>% %>% %>% %>% %>% %>% %>% %>% %>% %>% %>% %>% %>% 

1 %>% plusone()
  
1 %>% plusone(x = .) 

1 %>% plusone() %>% plustwo()

1 %>% 
  plusone() %>%
  plustwo()

1 %>% 
  # Take 1 and use plusone() on it
  plusone() %>%
  # Now take the output and use plustwo() on it
  plustwo()


# Let's make a table including...
sh = tibble(
  # name of stakeholder
  name = c("Project", "Company", 
           "Regulator", "Government", "Residents"),
  # type of stakeholder
  type = c("Beneficiary", "Beneficiary", "Problem", "Beneficiary", "Charitable"),
  # number of value cycles they are a part of
  cycles = c(3, 4, 2, 2, 2)
)

#stakeholders
sh


sh2 = sh %>%
  mutate(value = c(NA, 0.3, 0.5, 0.3, 0.8))


sh2 %>%
  summarize(total_value = sum(value, na.rm = TRUE))

summarize(sh2, total_value = sum(value, na.rm = TRUE))

sh2$value %>% sum(na.rm = TRUE)


sh2 %>%
  summarize(
    total_value = sum(value, na.rm = TRUE),
    count = n())


sh2 %>%
  group_by(type) %>%
  summarize(total_value = sum(value, na.rm = TRUE))

sh2 %>%
  group_by(type) %>%
  summarize(total_value = sum(value, na.rm = TRUE),
            count = n())

sh2 %>%
  group_by(type)

sh2 %>%
  group_by(type) %>%
  summarize(total_value = sum(value, na.rm = TRUE),
            count = n()) %>%
  ungroup()

sh2 %>%
  group_by(type) %>%
  summarize(total_value = sum(value, na.rm = TRUE),
            count = n())

seq(from = min(sh2$value, na.rm = TRUE),
    to = max(sh2$value, na.rm = TRUE),
    by = 0.1)



sh2 %>%
  reframe(
    range = seq(from = min(value, na.rm = TRUE),
                to = max(value, na.rm = TRUE),
                by = 0.1)
  )







sh2 %>%
  select(name, value)

sh2 %>%
  select(group = name)


sh2 %>%
  slice(2)

sh2 %>%
  slice(c(1,2))


sh2 %>%
  slice(-c(1,2))

sh2[-c(1,2), ]


sh2 %>%
  filter(value > 0.5)



sh2 %>% 
  filter(value > 0.5 |  type == "Problem")


sh2 %>% 
  filter(value >= 0.5)

sh2 %>%
  filter(is.na(value))


sh2 %>%
  filter(!is.na(value))


sh2 %>%
  arrange(value)

sh2 %>%
  arrange(desc(value))


# Lets make our stats table
stats = tibble(
  type = c("Beneficiary", "Charitable", "Problem"),
  total = c(1.4, 1.8, 0.9)
)

stats

sh2

left_join(x = sh2, y = stats, by = "type")

sh2 %>%
  left_join(y = stats, by = "type")


sh2 %>%
  left_join(by = "type", y = stats) %>%
  mutate(importance = value / total) %>%
  filter(!is.na(importance)) %>%
  group_by(type) %>%
  summarize(avg = mean(importance)) %>%
  arrange(desc(avg))


rm(list = ls())







