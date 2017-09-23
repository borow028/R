library(tidyverse)
library(ggplot2)

# Mon Jan 16 11:33:37 2017 ------------------------------

#TIBBLE

#data frame to tibble
as_tibble(iris)

#tibble to dataframe
class(as.data.frame(tb))

#create tibble
tibble(
  x = 1:5, 
  y = 1, 
  z = x ^ 2 + y
)

#create tribble - laying out the data in rows, rather than in columns
tribble(
  ~x, ~y, ~z,
  #--|--|----
  "a", 2, 3.6,
  "b", 1, 8.5
)

#There are two main differences in the usage of a tibble vs. a classic data.frame: printing and subsetting.

#printing - to change row/columns visible
nycflights13::flights %>% 
  print(n = 10, width = Inf)

#options(tibble.print_max = n, tibble.print_min = m)
#options(dplyr.print_min = Inf)
#options(tibble.width = Inf)

#subsetting - [[ can extract by name or position; $ only extracts by name
df <- tibble(
  x = runif(5),
  y = rnorm(5)
)
#extract by name
df$x
df[["x"]]

#extract by position
df[[1]]

#in pipe
df %>% .$x
df %>% .[["x"]]