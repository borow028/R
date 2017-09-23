library(tidyverse)
library(forcats)

# Sat Jan 21 10:55:47 2017 ------------------------------
#can't sort w/char data type
x1 <- c("Dec", "Apr", "Jan", "Mar")
x2 <- c("Dec", "Apr", "Jam", "Mar") #with typo

month_levels <- c(
  "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
)

y1 <- factor(x1, levels = month_levels)
sort(y1)

y2 <- factor(x2, levels = month_levels) #will fill in typos with NA
y2

y2 <- parse_factor(x2, levels = month_levels) #to get warning message

#if levels aren't added will go in alphabetical order - Apr, Dec, Jan, Mar

#to set levels in order of appearance
f1 <- factor(x1, levels = unique(x1))
f1
f2 <- x1 %>% factor() %>% fct_inorder()
f2

#to see levels
levels(f2)
#----------------------------------------------------------------------------
gss_cat
#to see levels and counts
gss_cat %>%
  count(race)

ggplot(gss_cat, aes(race)) +
  geom_bar()
#By default, ggplot2 will drop levels that don’t have any values. You can force them to display with:
ggplot(gss_cat, aes(race)) +
  geom_bar() +
  scale_x_discrete(drop = FALSE)

#practice
gss_cat %>%
  count(relig, denom)

ggplot(gss_cat, aes(relig, fill = denom)) +
  geom_bar() 
#----------------------------------------------------------------------------
#CHANGING FACTOR ORDER
relig <- gss_cat %>%
  group_by(relig) %>%
  summarise(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )

ggplot(relig, aes(tvhours, relig)) + 
  geom_point()

#to reorder plot - fct_reorder
ggplot(relig, aes(tvhours, fct_reorder(relig, tvhours))) +
  geom_point() 

#use mutate to avoid cluttering ggplot function
relig %>%
  mutate(relig = fct_reorder(relig, tvhours)) %>%
  ggplot(aes(tvhours, relig)) +
  geom_point()
#---------------------
#to move levels to front of line
#not applicable at front
ggplot(rincome, aes(age, rincome)) +
  geom_point()
#move not applicable to end - fct_relevel
ggplot(rincome, aes(age, fct_relevel(rincome, "Not applicable"))) +
  geom_point()
#---------------
#fct_reorder2() - use in visual display - changes legend
by_age <- gss_cat %>%
  filter(!is.na(age)) %>%
  group_by(age, marital) %>%
  count() %>%
  mutate(prop = n / sum(n)) #this number is wrong?

ggplot(by_age, aes(age, prop, colour = marital)) +
  geom_line(na.rm = TRUE)

#changes the legend to map to highest values
ggplot(by_age, aes(age, prop, colour = fct_reorder2(marital, age, prop))) +
  geom_line() +
  labs(colour = "marital")

#---------------
#reorder bar plots - fct_infreq() - fct_rev() flips from left to right
gss_cat %>%
  mutate(marital = marital %>% fct_infreq() %>% fct_rev()) %>%
  ggplot(aes(marital)) +
  geom_bar()
#----------------------------------------------------------------------------
#MODIFYING FACTOR LEVELS - fct_recode()
gss_cat %>% count(partyid) #not good descriptions

gss_cat %>%
  mutate(partyid = fct_recode(partyid,
                              "Republican, strong"    = "Strong republican",
                              "Republican, weak"      = "Not str republican",
                              "Independent, near rep" = "Ind,near rep",
                              "Independent, near dem" = "Ind,near dem",
                              "Democrat, weak"        = "Not str democrat",
                              "Democrat, strong"      = "Strong democrat"
  )
  ) %>% count(partyid)

#to combine levels do similar
gss_cat %>%
  mutate(partyid = fct_recode(partyid,
                              "Republican, strong"    = "Strong republican",
                              "Republican, weak"      = "Not str republican",
                              "Independent, near rep" = "Ind,near rep",
                              "Independent, near dem" = "Ind,near dem",
                              "Democrat, weak"        = "Not str democrat",
                              "Democrat, strong"      = "Strong democrat",
                              "Other"                 = "No answer",
                              "Other"                 = "Don't know",
                              "Other"                 = "Other party"
  )) %>%
  count(partyid)

#to collapse - make less levels out of many
gss_cat %>%
  mutate(partyid = fct_collapse(partyid,
                                other = c("No answer", "Don't know", "Other party"),
                                rep = c("Strong republican", "Not str republican"),
                                ind = c("Ind,near rep", "Independent", "Ind,near dem"),
                                dem = c("Not str democrat", "Strong democrat")
  )) %>%
  count(partyid)

#fct_lump() will try to auto-group - BE CAREFUL - set n to number of levels
gss_cat %>%
  mutate(relig = fct_lump(relig, n = 10)) %>%
  count(relig, sort = TRUE) %>%
  print(n = Inf)

#practice
gss_cat %>%
  mutate(partyid = fct_collapse(partyid,
                                other = c("No answer", "Don't know", "Other party"),
                                rep = c("Strong republican", "Not str republican"),
                                ind = c("Ind,near rep", "Independent", "Ind,near dem"),
                                dem = c("Not str democrat", "Strong democrat")
  )) %>%
ggplot(aes(year, fill = partyid)) +
  geom_bar()

gss_cat %>%
  mutate(rincome = fct_collapse(rincome,
                                Zero = c("No answer", "Don't know", "Refused", "Not applicable"),
                                Low = c("Lt $1000", "$1000 to 2999","$3000 to 3999","$4000 to 4999","$5000 to 5999","$6000 to 6999"),
                                Med = c("$10000 - 14999", "$8000 to 9999",  "$7000 to 7999"),
                                High = c("$25000 or more", "$20000 - 24999", "$15000 - 19999")
  )) %>%
  count(rincome)