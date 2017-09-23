library(tidyverse)
library(hms)

# Mon Jan 16 16:06:44 2017 ------------------------------
#parsing

#8 most important parsers - parse_logical(), parse_integer(), parse_double(), parse_number(), parse_character(), parse_factor(), parse_datetime(), parse_date(), parse_time()

str(parse_logical(c("TRUE", "FALSE", "NA")))
str(parse_integer(c("1", "2", "3")))
str(parse_date(c("2010-01-01", "1979-10-14")))

parse_integer(c("1", "231", ".", "456"), na = ".")

#(problems) will show all parsing errors
#-------------------------------
#NUMBERS
#for non-us dollars where decimal point is comma
parse_double("1,23", locale = locale(decimal_mark = ","))

#use parse_number to deal with $, % signs
parse_number("$100") #100
parse_number("20%") #20
parse_number("It cost $123.45") #123

parse_number("123.456.789", locale = locale(grouping_mark = "."))
#-------------------------------
#CHARACTERS
#readr uses UTF-8
charToRaw("Hadley")
#to convert to latin
parse_character(x1, locale = locale(encoding = "Latin1"))

guess_encoding(charToRaw(x1))
#-------------------------------
#FACTORS
fruit <- c("apple", "banana")
parse_factor(c("apple", "banana", "bananana"), levels = fruit)
#-------------------------------
#DATE-TIME
parse_datetime("2010-10-01T2010")
parse_datetime("20101010") #if time is blank, defaults to midnight
parse_date("2010-10-01")
parse_time("01:10 pm")
parse_time("20:10:01")

# Year
# %Y (4 digits).
# %y (2 digits); 00-69 -> 2000-2069, 70-99 -> 1970-1999.

# Month
# %m (2 digits).
# %b (abbreviated name, like “Jan”).
# %B (full name, “January”).

# Day
# %d (2 digits).
# %e (optional leading space).

# Time
# %H 0-23 hour.
# %I 0-12, must be used with %p.
# %p AM/PM indicator.
# %M minutes.
# %S integer seconds.
# %OS real seconds.
# %Z Time zone (as name, e.g. America/Chicago). Beware of abbreviations: if you’re American, note that “EST” is a Canadian time zone that does not have daylight savings time. It is not Eastern Standard Time! We’ll come back to this time zones.
# %z (as offset from UTC, e.g. +0800).

# Non-digits
# %. skips one non-digit character.
# %* skips any number of non-digits.

#test out before using
parse_date("01/02/15", "%m/%d/%y")
parse_date("01/02/15", "%d/%m/%y")
parse_date("01/02/15", "%y/%m/%d")
parse_date("1 janvier 2015", "%d %B %Y", locale = locale("fr"))

#practice
d1 <- "January 1, 2010"
d2 <- "2015-Mar-07"
d3 <- "06-Jun-2017"
d4 <- c("August 19 (2015)", "July 1 (2015)")
d5 <- "12/30/14" # Dec 30, 2014
t1 <- "1705"
t2 <- "11:15:10.12 PM"

parse_date(d1, "%B %d, %Y")
parse_date(d2, "%Y-%b-%d")
parse_date(d3, "%d-%b-%Y")
parse_date(d3, "%d-%b-%Y")
parse_date(d4, "%B %d (%Y)")
parse_date(d5, "%m/%d/%y")
parse_time(t1, "%H%M")
parse_time(t2, "%H:%M:%S%*") #not sure how to get pm

guess_parser("2010-10-01")
str(parse_guess("2010-10-10"))
#-------------------------------
#Problems
#The column might contain a lot of missing values. If the first 1000 rows contain only NAs, readr will guess that it’s a character vector, whereas you probably want to parse it as something more specific.
#ALWAYS SPECIFY MANUALLY TO AVOID ISSUES
challenge <- read_csv(readr_example("challenge.csv"))
problems(challenge)
#to fix - manually specify column types
challenge <- read_csv(
  readr_example("challenge.csv"), 
  col_types = cols(
    x = col_double(),
    y = col_date()
  ))
#stop_for_problems(): will throw an error and stop your script if there are any parsing problems.

#look at more than first 1000 rows
challenge2 <- read_csv(readr_example("challenge.csv"), guess_max = 1001)

#read all columns in as char vectors
challenge2 <- read_csv(readr_example("challenge.csv"), 
                       col_types = cols(.default = col_character())
)
#convert from char to other - automatic?
type_convert(df)

#If you’re having major parsing problems, sometimes it’s easier to just read into a character vector of lines with read_lines(), or even a character vector of length 1 with read_file(). Then you can use the string parsing skills you’ll learn later to parse more exotic formats.
#-------------------------------
#Writing to file
write_csv(challenge, "challenge.csv")
write_excel_csv(challenge, "challenge.xls")
write_tsv(challenge, "challenge.tsv")

#will have to recreate column spec each time load in - to address use write_rds(), read_rds()
write_rds(challenge, "challenge.rds")
read_rds("challenge.rds")

#files that can be shared w/different programming languages
library(feather)
write_feather(challenge, "challenge.feather")
read_feather("challenge.feather")

#haven reads SPSS, Stata, and SAS files.
#readxl reads excel files (both .xls and .xlsx).
#DBI, along with a database specific backend (e.g. RMySQL, RSQLite, RPostgreSQL etc) allows you to run SQL queries against a database and return a data frame.
#jsonlite (by Jeroen Ooms) for json
#xml2 for XML
#rio