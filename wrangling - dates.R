library(tidyverse)
library(lubridate)
library(nycflights13)

# Sat Jan 21 11:59:37 2017 ------------------------------
today() #current date
now() #current datetime
#------------------------------------------------------------------------
#FROM STRINGS
ymd("2017-01-31")
mdy("January 31st, 2017")
dmy("31-Jan-2017")
ymd(20170131)

ymd_hms("2017-01-31 20:11:59")
mdy_h("01/31/2017 08:01")

ymd(20170131, tz = "UTC")
#---------------------
#FROM INDIVIDUAL COMPONENTS
flights %>% 
  select(year, month, day, hour, minute)

flights %>% 
  select(year, month, day, hour, minute) %>% 
  mutate(departure = make_datetime(year, month, day, hour, minute))
#----------
make_datetime_100 <- function(year, month, day, time) {
  make_datetime(year, month, day, time %/% 100, time %% 100)
}

flights_dt <- flights %>% 
  filter(!is.na(dep_time), !is.na(arr_time)) %>% 
  mutate(
    dep_time = make_datetime_100(year, month, day, dep_time),
    arr_time = make_datetime_100(year, month, day, arr_time),
    sched_dep_time = make_datetime_100(year, month, day, sched_dep_time),
    sched_arr_time = make_datetime_100(year, month, day, sched_arr_time)
  ) %>% 
  select(origin, dest, ends_with("delay"), ends_with("time"))

flights_dt %>% 
  ggplot(aes(dep_time)) + 
  geom_freqpoly(binwidth = 86400) # 86400 seconds = 1 day

flights_dt %>% 
  filter(dep_time < ymd(20130102)) %>% 
  ggplot(aes(dep_time)) + 
  geom_freqpoly(binwidth = 600) # 600 s = 10 minutes

#Note that when you use date-times in a numeric context (like in a histogram), 1 means 1 second, so a binwidth of 86400 means one day. For dates, 1 means 1 day.
#---------------------
#FROM OTHER TYPES
as_datetime(today())
as_date(now())
as_datetime(60 * 60 * 10)
as_date(365 * 10 + 2)

"January 1, 2010"
"2015-Mar-07"
"06-Jun-2017"
c("August 19 (2015)", "July 1 (2015)")
"12/30/14" # Dec 30, 2014

#practice
mdy("January 1, 2010")
ymd("2015-Mar-07")
dmy("06-Jun-2017")
mdy(c("August 19 (2015)", "July 1 (2015)"))
#----------------------------------------------------------------
#DATE-TIME COMPONENTS
datetime <- ymd_hms("2016-07-08 12:34:56")
year(datetime)
month(datetime, label = TRUE, abbr = FALSE)
mday(datetime)
yday(datetime)
wday(datetime, label = TRUE, abbr = FALSE)
hour(datetime)
minute(datetime)
second(datetime)

flights_dt %>% 
  mutate(wday = wday(dep_time, label = TRUE)) %>% 
  ggplot(aes(x = wday)) +
  geom_bar()

#flight delays vary by minute within the hour
flights_dt %>% 
  mutate(minute = minute(dep_time)) %>% 
  group_by(minute) %>% 
  summarise(
    avg_delay = mean(arr_delay, na.rm = TRUE),
    n = n()) %>% 
  ggplot(aes(minute, avg_delay)) +
  geom_line()

#based on schedule shouldn't be happening
sched_dep <- flights_dt %>% 
  mutate(minute = minute(sched_dep_time)) %>% 
  group_by(minute) %>% 
  summarise(
    avg_delay = mean(arr_delay, na.rm = TRUE),
    n = n())

ggplot(sched_dep, aes(minute, avg_delay)) +
  geom_line()

#departure times being manipulated to "nice" even numbers
ggplot(sched_dep, aes(minute, n)) +
  geom_line()
#--------------
#ROUNDING
#floor_date(), round_date(), ceiling_date()

#number of flights per week
flights_dt %>% 
  count(week = floor_date(dep_time, "week")) %>% 
  ggplot(aes(week, n)) +
  geom_line()
#--------------
#SETTING COMPONENTS - change date values - update()
(datetime <- ymd_hms("2016-07-08 12:34:56"))
year(datetime) <- 2020
month(datetime) <- 01
hour(datetime) <- hour(datetime) + 1
datetime

update(datetime, year = 2020, month = 2, mday = 2, hour = 2)
#if values are too big they will roll over - i.e. 30 days in feb
ymd("2015-02-01") %>% 
  update(mday = 30)
ymd("2015-02-01") %>% 
  update(hour = 400)

#You can use update() to show the distribution of flights across the course of the day for every day of the year:
flights_dt %>% 
  mutate(dep_hour = update(dep_time, yday = 1)) %>% 
  ggplot(aes(dep_hour)) +
  geom_freqpoly(binwidth = 300)

#practice
flights2 <- flights %>% 
  filter(!is.na(dep_time), !is.na(arr_time)) %>% 
  mutate(
    dep_time = make_datetime_100(year, month, day, dep_time),
    arr_time = make_datetime_100(year, month, day, arr_time),
    sched_dep_time = make_datetime_100(year, month, day, sched_dep_time),
    sched_arr_time = make_datetime_100(year, month, day, sched_arr_time)
  ) %>% 
  select(origin, dest, ends_with("delay"), ends_with("time"))

flights3 <- flights2 %>%
  mutate(
    year = as.factor(year(dep_time)),
    month = as.factor(month(dep_time)),
    day = as.factor(mday(dep_time)),
    weekday = as.factor(wday(dep_time)),
    hour = as.factor(hour(dep_time)),
    minute = as.factor(minute(dep_time))
  ) %>%
  group_by(year, month, hour) %>%
  summarise(
    n = n()
  ) 

ggplot(flights3, aes(month, fill = hour)) +
  geom_bar()

flight_diff <- flights_dt %>%
  select(dep_time, sched_dep_time, dep_delay) %>%
  mutate(deptimemin = (hour(dep_time) * 60) + minute(dep_time),
         schdeptimemin = (hour(sched_dep_time) * 60) + minute(sched_dep_time),
         del = deptimemin - schdeptimemin,
         diff = del - dep_delay
         ) %>%
  filter(diff > 0)

air_time_diff <- flights_dt %>%
  select(origin, dest, dep_time, arr_time, air_time) %>%
  mutate(deptimemin = (hour(dep_time) * 60) + minute(dep_time),
         arrtimemin = (hour(arr_time) * 60) + minute(arr_time),
         diff = arrtimemin - deptimemin,
         diff1 = air_time - diff) %>%
  filter(diff1 > 0)


diamonds %>%
  filter(carat < 3.05) %>%
ggplot(aes(carat)) +
  geom_bar()

ggplot(flights, aes(sched_dep_time)) +
  geom_bar()
#----------------------------------------------------------------
#TIMESPANS
#durations, which represent an exact number of seconds.
#periods, which represent human units like weeks and months.
#intervals, which represent a starting and ending point.
#-------------
#DURATIONS
(h_age <- today() - ymd(19791014)) #difftime object
as.duration(h_age) #duration converts to seconds
dseconds(15)
dminutes(10)
dhours(c(12, 24))
ddays(0:5)
dweeks(3)
dyears(1)

#can add and multiply durations
2 * dyears(1)
dyears(1) + dweeks(12) + dhours(15)
tomorrow <- today() + ddays(1)
last_year <- today() - dyears(1)

#be careful with timezones and daylight savings time!
one_pm <- ymd_hms("2016-03-12 13:00:00", tz = "America/New_York")
one_pm
one_pm + ddays(1)
#-------------
#PERIODS - don't work in seconds, more intuitive - more likely to do what you expect than durations
one_pm + days(1) #doesn't have timezone/dst issue as above
seconds(15)
minutes(10)
hours(c(12, 24))
days(7)
months(1:6)
weeks(3)
years(1)

10 * (months(6) + days(1))
days(50) + hours(25) + minutes(2)

#practice - flights w/arr times < dep time
flights_dt <- flights_dt %>% 
  mutate(
    overnight = arr_time < dep_time,
    arr_time = arr_time + days(overnight * 1),
    sched_arr_time = sched_arr_time + days(overnight * 1)
  )
#-------------
#INTERVALS - more accurate than periods
next_year <- today() + years(1)
(today() %--% next_year) / ddays(1)
(today() %--% next_year) %/% days(1)
#-------------
#SUMMARY
#If you only care about physical time, use a duration; 
#if you need to add human times, use a period; 
#if you need to figure out how long a span is in human units, use an interval.
#-------------
#PRACTICE
year = 2017
vec <- c(mdy("1/1/15"), mdy("2/1/15"), mdy("3/1/15"),
         mdy("4/1/15"), mdy("5/1/15"), mdy("6/1/15"),
         mdy("7/1/15"), mdy("8/1/15"), mdy("9/1/15"),
         mdy("10/1/15"), mdy("11/1/15"), mdy("12/1/15")
)
vec2 <- wday(vec, label = TRUE, abbr = FALSE)
vec2
#----------------------------------------------------------------
#TIMEZONES
#R uses the international standard IANA time zones
Sys.timezone()
OlsonNames()

#these all represent same thing
(x1 <- ymd_hms("2015-06-01 12:00:00", tz = "America/New_York"))
(x2 <- ymd_hms("2015-06-01 18:00:00", tz = "Europe/Copenhagen"))
(x3 <- ymd_hms("2015-06-02 04:00:00", tz = "Pacific/Auckland"))
x1 - x2

#Unless other specified, lubridate always uses UTC. UTC (Coordinated Universal Time) is the standard time zone used by the scientific community and roughly equivalent to its predecessor GMT (Greenwich Mean Time)

#changing timezone
#Keep the instant in time the same, and change how it’s displayed. Use this when the instant is correct, but you want a more natural display.
(x4 <- c(x1, x2, x3))
(x4a <- with_tz(x4, tzone = "Australia/Lord_Howe"))
#Change the underlying instant in time. Use this when you have an instant that has been labelled with the incorrect time zone, and you need to fix it.
(x4b <- force_tz(x4, tzone = "Australia/Lord_Howe"))

