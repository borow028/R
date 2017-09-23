library(tidyverse)
library(nycflights13)
library(fueleconomy)

#checking for unique primary key
planes %>% 
  count(tailnum) %>% 
  filter(n > 1)

#Surrogate Key - If a table lacks a primary key, it’s sometimes useful to add one with mutate() and row_number(). That makes it easier to match observations if you’ve done some filtering and want to check back in with the original data. This is called a surrogate key.

#add surrogate key
flights %>%
  mutate(sk = row_number())

#practice - finding primary key
lahman <- Lahman::Batting
lahman %>% 
  count(playerID, yearID, stint) %>% 
  filter(n > 1)

flights2 <- flights %>% 
  select(year:day, hour, origin, dest, tailnum, carrier)

#left join
flights2 %>%
  select(-origin, -dest) %>% 
  left_join(airlines, by = "carrier")

#inner join - generally avoid in analysis - don't want to lose rows
x %>% 
  inner_join(y, by = "key")

#left join
left_join(x, y, by = "key")

#natural join - default is "by = NULL" - matches on all keys
flights2 %>% 
  left_join(weather)

#when keys have different names in diff tables
#A named character vector: by = c("a" = "b"). This will match variable a in table x to variable b in table y. The variables from x will be used in the output.
flights2 %>% 
  left_join(airports, by = c("dest" = "faa"))

#practice
flights2 <- flights %>%
  group_by(origin, dest) %>%
  summarise(ad = mean(arr_delay, na.rm = TRUE)) %>%
  arrange(desc(ad)) %>%
  left_join(airports, c("dest" = "faa")) %>%
  left_join(airports, c("origin" = "faa")) %>%
  ggplot(aes(lon.x, lat.x, color = ad, size = ad)) +
  borders("state") +
  geom_point(na.rm = TRUE) +
  coord_quickmap()

flights_new <- flights %>%
  left_join(planes, "tailnum") %>%
  group_by(year.y) %>%
  summarise(ad = mean(arr_delay, na.rm = TRUE)) %>%
  ggplot(aes(year.y, ad)) +
  geom_point()

#full join - SELECT * FROM x FULL OUTER JOIN y USING (z)
full_join(x, y)

#semi-join - keeps rows with match
#Filtering joins match observations in the same way as mutating joins, but affect the observations, not the variables.
#semi_join(x, y) keeps all observations in x that have a match in y.

top_dest <- flights %>%
  count(dest, sort = TRUE) %>%
  head(10)

flights2 <- flights %>% 
  semi_join(top_dest)

#anti-join - keeps rows without match
flights4 <- flights %>%
  anti_join(planes, by = "tailnum") %>%
  count(tailnum, sort = TRUE)

#practice
flights %>%
  filter(count(tailnum) > 100)

flights %>%
  count(tailnum, sort = TRUE) %>%
  filter(n > 100)

vehicles %>%
  left_join(common, c("make","model"))

flights %>% 
  left_join(weather, by = c("origin", "year", "month", "day", "hour")) %>%
  group_by(origin, year, month, day, hour) %>%
  summarize(td = sum(arr_delay)) %>%
  arrange(desc(td)) %>%
  head(48)

#intersect(x, y): return only observations in both x and y.
#union(x, y): return unique observations in x and y.
#setdiff(x, y): return observations in x, but not in y.