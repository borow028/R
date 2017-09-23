library(tidyverse)
library(hms)


# Mon Jan 16 12:15:51 2017 ------------------------------

#read_csv(), read_csv2(), read_tsv(), read_delim(), read_fwf(), read_table(), read_log()

#loading from file
heights <- read_csv("data/heights.csv")

#creating manually - skip & comment to avoid loading in certain lines - be careful combining
read_csv("# The first line of metadata
  The second line of metadata
  hi
         x,y,z
         1,2,3", skip = 2, comment = "#")

#if no column names use col_names = FALSE or manually specify col_names
read_csv("1,2,3\n4,5,6", col_names = FALSE)
read_csv("1,2,3\n4,5,6", col_names = c("x", "y", "z"), na = ".")

#for speed can use data.table

#Sometimes strings in a CSV file contain commas. To prevent them from causing problems they need 
#to be surrounded by a quoting character, like " or '. By convention, read_csv() assumes that 
#the quoting character will be ", and if you want to change it you’ll need to use read_delim() instead.

df <- read_csv("x,y\n1,\"a,b\"")
write_csv(df,"df.csv")
df1 <- read_csv("df.csv")

#remove commas and convert types
df1 %>%
  mutate_each(funs(as.character(.)), x:y) %>%
  mutate_each(funs(gsub(",", "", .)), x:y) %>%
  mutate_each(funs(as.numeric(.)), x)
#--------------------------------------------------------------------
