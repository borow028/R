library(nycflights13)
library(tidyverse)

# Sun Jan 15 12:19:52 2017 ------------------------------

#dplyr - filter, arrange, select, mutate, summarise
# all can be used with group_by
#-------------------------------------------------------------
#FILTER
#filter() only includes rows where the condition is TRUE; it excludes both FALSE and NA values

(dec25 <- filter(flights, month == 12, day == 25))

#>, >=, <, <=, != (not equal), and == (equal)

#floating point numbers can cause issues (ex. 1/49 * 49 == 1 is false)
#replace == with near()

#& is "and", | is "or", and ! is "not"

nov_dec <- filter(flights, month == 11 | month == 12)
nov_dec <- filter(flights, month %in% c(11, 12)) #better

#same
filter(flights, !(arr_delay > 120 | dep_delay > 120))
filter(flights, arr_delay <= 120, dep_delay <= 120)

#NA
is.na(x)

#dealing with NA's
df <- tibble(x = c(1, NA, 3))

filter(df, x > 1) #BAD
filter(df, is.na(x) | x > 1) #GOOD

#between
filter(flights, between(dep_time,0,600))

#flights with NA dep_time
filter(flights, is.na(dep_time))
#-------------------------------------------------------------
#ARRANGE
arrange(flights, year, month, day)
#descending
arrange(flights, desc(arr_delay))
#NA's go to end always - asc or desc
#-------------------------------------------------------------
#SELECT
# Select columns by name
select(flights, year, month, day)
# Select all columns between year and day (inclusive)
select(flights, year:day)
# Select all columns except those from year to day (inclusive)
select(flights, -(year:day))

#starts_with(), ends_with(), contains(), matches("(.)\\1", num_range("x", 1:3), one_of(), everything()

#rename
rename(flights, tail_num = tailnum)
#starts_with
select(flights, starts_with("dep"))
#ends_with
select(flights, ends_with("time"))
#contains
select(flights, contains("time"))
#one_of 
vars <- c("year", "month", "day", "dep_delay", "arr_delay")
select(flights, one_of(vars))
#everything - moves time_hour & air_time to front
select(flights, time_hour, air_time, everything())
#select helper functions are case insensitive by default (ignore.case = TRUE)
#-------------------------------------------------------------
#MUTATE
flights_sml <- select(flights, 
                      year:day, 
                      ends_with("delay"), 
                      distance, 
                      air_time
)

#create new columns based on existing
mutate(flights_sml,
       gain = arr_delay - dep_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours #can use new variables in calcs
)

#transmute - only keeps new variables
transmute(flights,
          dep_time,
          hour = dep_time %/% 100,
          minute = dep_time %% 100
)

#use log2 for interpretability - doubling/halving

#offsets - lag and lead
(x <- 1:10)
lag(x)
lead(x)

#rolling aggregates - cumsum(), cumprod(), etc. - RcppRoll package
#ranking - others include row_number(), dense_rank(), percent_rank(), cume_dist(), ntile()
y <- c(1, 2, 2, NA, 3, 4)
min_rank(y)
min_rank(desc(y))

y <- mutate(flights, min_rank(desc(dep_delay)))
#-------------------------------------------------------------
#SUMMARISE - use w/group_by
summarise(flights, delay = mean(dep_delay, na.rm = TRUE))

by_day <- group_by(flights, year, month, day)
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))
#na.rm needs to be included
#-------------------------------------------------------------
#PIPE
delays <- flights %>% 
  group_by(dest) %>% 
  summarise(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  filter(count > 20, dest != "HNL")

#different approach, removing the na's first
not_cancelled <- flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay))

delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )

ggplot(data = delays, mapping = aes(x = n, y = delay)) + 
  geom_point(alpha = 1/10)

#integrating dplyr w/ggplot2
delays %>% 
  filter(n > 25) %>% 
  ggplot(mapping = aes(x = n, y = delay)) + 
  geom_point(alpha = 1/10)
#----------------------
batting <- as_tibble(Lahman::Batting)

batters <- batting %>% 
  group_by(playerID) %>% 
  summarise(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE)
  )

batters %>% 
  filter(ab > 100) %>% 
  ggplot(mapping = aes(x = ab, y = ba)) +
  geom_point() + 
  geom_smooth(se = FALSE)

batters %>% 
  arrange(desc(ba))
#----------------------
#other summary functions - median(x), sd(x), IQR(x), mad(x), min(x), max(x), quantile(x, 0.25)
#other position functions - first(x), last(x), nth(x, 2)
#counts - sum(!is.na(x)), n_distinct(x)
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(carriers = n_distinct(carrier)) %>% 
  arrange(desc(carriers))

#does sum rather than count
not_cancelled %>% 
  count(tailnum, wt = distance)

not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(n_early = sum(dep_time < 500))

#proportions
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(hour_perc = mean(arr_delay > 60))

#grouping by multiple variables
daily <- group_by(flights, year, month, day)
(per_day   <- summarise(daily, flights = n()))
(per_month <- summarise(per_day, flights = sum(flights)))
(per_year  <- summarise(per_month, flights = sum(flights)))

#ungroup()
daily %>% 
  ungroup() %>%             # no longer grouped by date
  summarise(flights = n())

#grouped mutates
flights_sml %>% 
  group_by(year, month, day) %>%
  filter(rank(desc(arr_delay)) < 10)

popular_dests <- flights %>% 
  group_by(dest) %>% 
  filter(n() > 10000
         )
popular_dests

popular_dests %>% 
  filter(arr_delay > 0) %>% 
  mutate(prop_delay = arr_delay / sum(arr_delay)) %>% 
  select(year:day, dest, arr_delay, prop_delay)

#practice
#Which plane (tailnum) has the worst on-time record?
not_cancelled %>%
  filter(arr_delay > 0) %>%
  group_by(tailnum) %>%
  mutate(prop_delay = arr_delay / sum(arr_delay),
         total_delay = sum(arr_delay)/ n(),
         n = n()
         ) %>%
  select((tailnum), total_delay) %>%
  arrange(desc(total_delay))
  
not_cancelled %>%
  group_by(sched_dep_time) %>%
  mutate(
    n = n(),
    delays = (sum(arr_delay > 0) / sum(arr_delay <= 0))
  ) %>%
  select(sched_dep_time, n_distinct(delays)) %>%
  summarize(dep_time = n_distinct(sched_dep_time)) %>%
  select(dep_time, delays)
 

