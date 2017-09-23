library(tidyverse)
#tidyr
#Each variable must have its own column.
#Each observation must have its own row.
#Each value must have its own cell.
#----------------------------------------------
#Gathering - values are listed as column names
table4a
tidy4a <- table4a %>% 
  gather(`1999`, `2000`, key = "year", value = "cases")
tidy4b <- table4b %>% 
  gather(`1999`, `2000`, key = "year", value = "population")

left_join(tidy4a, tidy4b)
#----------------------------------------------
#Spreading - opposite of gathering - observation spread across 2+ rows
table2
spread(table2, key = type, value = count)
#----------------------------------------------
#Separate - one column contains two variables
table3
table3 %>% 
  separate(rate, into = c("cases", "population"), convert = TRUE) #convert = TRUE will specify the data types

table3 %>% 
  separate(year, into = c("century", "year"), sep = 2) #sep = 2 is 2 chars from left of string starting at 1

#too many values
tibble(x = c("a,b,c", "d,e,f,g", "h,i,j")) %>% 
  separate(x, c("one", "two", "three"), extra = "merge")
#too few values
tibble(x = c("a,b,c", "d,e", "f,g,i")) %>% 
  separate(x, c("one", "two", "three"), fill = "right")
#----------------------------------------------
#Unite - single variable spread across multiple columns
table5 %>% 
  unite(new, century, year, sep = "") #use sep to avoid _ coming in
#----------------------------------------------
#Missing Values
#implicit - 2016 - q1 is missing
stocks <- tibble(
  year   = c(2015, 2015, 2015, 2015, 2016, 2016, 2016),
  qtr    = c(   1,    2,    3,    4,    2,    3,    4),
  return = c(1.88, 0.59, 0.35,   NA, 0.92, 0.17, 2.66)
)
#make explicit by putting year in columns or use complete
stocks %>% 
  spread(year, return)

#complete
stocks %>% 
  complete(year, qtr)

#remove explicit if not needed using na.rm = TRUE
stocks %>% 
  spread(year, return) %>% 
  gather(year, return, `2015`:`2016`, na.rm = TRUE)

#fill in missing values - carry forward
treatment <- tribble(
  ~ person,           ~ treatment, ~response,
  "Derrick Whitmore", 1,           7,
  NA,                 2,           10,
  NA,                 3,           9,
  "Katherine Burke",  1,           4
)

treatment %>% 
  fill(person)
#----------------------------------------------
#case study example
who
#start with gather - The best place to start is almost always to gather together the columns that are not variables.
who1 <- who %>% 
  gather(new_sp_m014:newrel_f65, key = "key", value = "cases", na.rm = TRUE)
who1

who1 %>% 
  count(key)

#str_replace
who2 <- who1 %>% 
  mutate(key = stringr::str_replace(key, "newrel", "new_rel"))

#split key into new columns
who3 <- who2 %>% 
  separate(key, c("new", "type", "sexage"), sep = "_")
who3

#drop redundant columns
who4 <- who3 %>% 
  select(-new, -iso2, -iso3)

#split sex age after 1st char (sep = 1)
who5 <- who4 %>% 
  separate(sexage, c("sex", "age"), sep = 1)

#all in one
who4 <- who %>%
  gather(code, value, new_sp_m014:newrel_f65, na.rm = TRUE) %>% 
  mutate(code = stringr::str_replace(code, "newrel", "new_rel")) %>%
  separate(code, c("new", "var", "sexage")) %>% 
  select(-new, -iso2, -iso3) %>% 
  separate(sexage, c("sex", "age"), sep = 1)

#practice
who4 %>%
  group_by(country,year,sex) %>%
  summarise(total = sum(value)) %>%
  ggplot(aes(year,total, color = sex)) +
  geom_point()

