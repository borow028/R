library(tidyverse)
library(stringr)

#use "" unless you want to include a quote in the string
string1 <- "This is a string"
string2 <- 'If I want to include a "quote" inside a string, I use single quotes'

#use \ to include quotes in string
double_quote <- "\"" # or '"'
single_quote <- '\'' # or "'"

#if need to use \ use \\

x <- c("\"", "\\")

#to show string contents
writeLines(x)

#?'"' for help info

str_length(c("a", "R for data science", NA))

#concat strings
str_c("x", "y")
str_c("x", "y", sep = ", ")

#dealing with NA's
x <- c("abc", NA)
str_c("|-", x, "-|")
str_c("|-", str_replace_na(x), "-|")

#vectorized
str_c("prefix-", c("a", "b", "c"), "-suffix")

#collapse vector of strings into one string
str_c(c("x", "y", "z"), collapse = ", ")

#subsetting strings
x <- c("Apple", "Banana", "Pear")
str_sub(x, 1, 3)
str_sub(x, -3, -1)

str_sub(x, 1, 1) <- str_to_lower(str_sub(x, 1, 1))

#str_wrap
n = "Regexps are a very terse language that allow you to describe patterns in strings. They take a little while to get your head around, but once you understand them, you’ll find them extremely useful. To learn regular expressions, we’ll use str_view() and str_view_all(). These functions take a character vector and a regular expression, and show you how they match. We’ll start with very simple regular expressions and then gradually get more and more complicated. Once you’ve mastered pattern matching, you’ll learn how to apply those ideas with various stringr functions."
str_wrap(n, width = 20)
#-----------------------------------------------------------------
# Fri Jan 20 13:02:34 2017 ------------------------------
#REGULAR EXPRESSIONS (REGEX)
#identify match to a pattern: grep(..., value = FALSE), grepl(), stringr::str_detect()
#extract match to a pattern: grep(..., value = TRUE), stringr::str_extract(),  stringr::str_extract_all()
#locate pattern within a string, i.e. give the start position of matched patterns. regexpr(), gregexpr(),  stringr::str_locate(), string::str_locate_all()
#replace a pattern: sub(), gsub(), stringr::str_replace(), stringr::str_replace_all()
#split a string using a pattern: strsplit(), stringr::str_split()

#METACHARACTERS - $ * + . ? [ ] ^ { } | ( ) \

#ESCAPE SEQUENCES
#\n	newline
#\r	carriage return
#\t	tab
#\b	backspace
#\a	alert (bell)
#\f	form feed
#\v	vertical tab
#\\	backslash \
#\'	ASCII apostrophe '
#\"	ASCII quotation mark "
#\`	ASCII grave accent (backtick) `
#\nnn	character with given octal code (1, 2 or 3 digits)
#\xnn	character with given hex code (1 or 2 hex digits)
#\unnnn	Unicode character with given code (1--4 hex digits)
#\Unnnnnnnn	Unicode character with given code (1--8 hex digits)

#QUANTIFIERS
#*: matches at least 0 times.
#+: matches at least 1 times.
#?: matches at most 1 times.
#{n}: matches exactly n times.
#{n,}: matches at least n times.
#{n,m}: matches between n and m times.

x <- c("apple", "banana", "pear")
str_view(x, "an") #matches exact strings
str_view(x, ".a.") #. matches any char except newline

#need to use an “escape” to tell the regular expression you want to match it exactly, not use its special behaviour. \
dot <- "\\."
writeLines(dot) #only contains one slash

str_view(c("abc", "a.c", "bef"), "a\\.c") #removing slashes would make it an inexact match

#to match an escape character need 4 slashes!
x <- "a\\b"
writeLines(x)
str_view(x, "\\\\")

#ANCHORS - match from start or end of string 
#^ = start, $ = end
x <- c("apple", "banana", "pear")
str_view(x, "^a")
str_view(x, "a$")
str_view(x, "^apple$") #to only match complete string
#practice
words <- stringr::words
str_view(words, "^y", match = TRUE)
str_view(words, "x$", match = TRUE)
str_view(words, "^...$", match = TRUE)
str_view(words, "^.......", match = TRUE)

#CHARACTER CLASSES & ALTERNATIVES
#.: matches any character except newline
#\d: matches any digit.
#\s: matches any whitespace (e.g. space, tab, newline).
#[abc]: matches a, b, or c.
#[^abc]: matches anything except a, b, or c.
str_view(c("grey", "gray"), "gr(e|a)y")


#practice
str_view(words, "^(a|e|i|o|u)", match = TRUE)
#str_view(words, "[^a|e|i|o|u]", match = TRUE)
#str_view(words, "ed$", match = TRUE)
str_view(words, "ing$|ise$", match = TRUE)
str_view(words, "ie|cei", match = TRUE)
str_view(words, "q.", match = TRUE)

number <- "612-499-8350"
str_view(number, "\\d{3}-\\d{3}-\\d{4}", match = TRUE)

#REPETITION - define how often pattern matches
#?: 0 or 1
#+: 1 or more
#*: 0 or more
#{n}: exactly n
#{n,}: n or more
#{,m}: at most m
#{n,m}: between n and m

x <- "1888 is the longest year in Roman numerals: MDCCCLXXXVIII"
str_view(x, "CC?", match = TRUE)
str_view(x, "CC+", match = TRUE)
str_view(x, 'C[LX]+', match = TRUE)
str_view(x, "C{2}", match = TRUE)
str_view(x, "C{2,}", match = TRUE)
str_view(x, "C{2,3}", match = TRUE)
str_view(x, 'C{2,3}?', match = TRUE)
str_view(x, 'C[LX]+?', match = TRUE)

#practice
str_view(words, "^[^(a|e|i|o|u)]{3}", match = TRUE)
str_view(words, "[(a|e|i|o|u)]{3,}", match = TRUE)
str_view(words, "[(a|e|i|o|u)][^(a|e|i|o|u)]{2,}", match = TRUE)

#GROUPING AND BACKREFERENCES

str_view(fruit, "(..)\\1", match = TRUE)
str_view(fruit, "(.)(.)\\2\\1", match = TRUE)
str_view(words, "(.).\\1.\\1", match = TRUE)
str_view(words, "(.)(.)(.).*\\3\\2\\1", match = TRUE)

#practice - couldn't do
#str_view(words, "^(.)(.)$\\1", match = TRUE)
#str_view(words, "(.)(.)(.){3,}\\1", match = TRUE)

#-----------------------------------------------------------------
#TOOLS
x <- c("apple", "banana", "pear")
str_detect(x, "e")
sum(str_detect(words, "^t"))
mean(str_detect(words, "[aeiou]$"))

# Find all words containing at least one vowel, and negate
no_vowels_1 <- !str_detect(words, "[aeiou]")
# Find all words consisting only of consonants (non-vowels)
no_vowels_2 <- str_detect(words, "^[^aeiou]+$")
identical(no_vowels_1, no_vowels_2)

str_subset(words, "x$")

#working with dataframe - use filter
df <- tibble(
  word = words, 
  i = seq_along(word)
)
df %>% 
  filter(str_detect(words, "x$"))

str_count(x, "a")
mean(str_count(words, "[aeiou]"))

df <- mutate(df,
    vowels = str_count(word, "[aeiou]"),
    consonants = str_count(word, "[^aeiou]"),
    total = vowels + consonants,
    prop = vowels/(consonants+vowels)
  )

str_count("abababa", "aba")
str_view("abababa", "aba")
str_view_all("abababa", "aba")

#practice
str_view(words, "^x|x$", match = TRUE)
words[str_detect(words, "^x|x$")]

#str_view(words, "(^[aeiou])($[^aeiou])", match = TRUE)
vowel <- words[str_detect(words, "^[aeiou]")]
cons <- words[str_detect(words, "[^aeiou]$")]
vowel[vowel %in% cons]

#EXTRACT MATCHES
length(sentences)
head(sentences)

colours <- c("red", "orange", "yellow", "green", "blue", "purple")
colour_match <- str_c(colours, collapse = "|")
colour_match

has_colour <- str_subset(sentences, colour_match)
matches <- str_extract_all(has_colour, colour_match)
#to create df of matches use simplify = TRUE
#matches <- str_extract_all(has_colour, colour_match, simplify = TRUE)
head(matches)

#sentences_2 <- str_extract_all(sentences, "[a-z] ", simplify = TRUE)

noun <- "(a|the|The|A) ([^ ]+)"
has_noun <- sentences %>%
  str_subset(noun) %>%
  head(10)

has_noun %>% 
  str_extract(noun)
 #str_extract_all(noun)

has_noun %>% 
 #str_match(noun)
  str_match_all(noun)
  
sen <- tibble(sentence = sentences) %>% 
  tidyr::extract(
    sentence, c("article", "noun"), "(a|the) ([^ ]+)", 
    remove = FALSE
  )

#practice
word <- "(one|two|three) ([^ ]+)"
has_word <- sentences %>%
  str_subset(word) %>%
  head(10)

has_word %>%
  str_extract_all(word)

contract <- "([^ ]+)'([^ ]+)"
has_contract <- sentences %>%
  str_subset(contract) %>%
  head(10)

has_contract %>%
  str_extract_all(contract)

#REPLACING MATCHES
x <- c("apple", "pear", "banana")
str_replace(x, "[aeiou]", "-")
str_replace_all(x, "[aeiou]", "-")

#flip the order of 2nd and 3rd words
sentences %>% 
  str_replace("([^ ]+) ([^ ]+) ([^ ]+)", "\\1 \\3 \\2") %>% 
  head(5)

#SPLITTING
sentences %>%
  head(5) %>% 
  str_split(" ") 
 #str_split(" ", simplify = TRUE) #add simplify = TRUE to get matrix
#1-length vector
"a|b|c|d" %>% 
  str_split("\\|") %>% 
  .[[1]]

fields <- c("Name: Hadley", "Country: NZ", "Age: 35")
fields %>% str_split(": ", n = 2, simplify = TRUE)

str_view_all(sentences, boundary("word"))

str_split(sentences, " ")[[1]]
str_split(sentences, boundary("word"))[[1]]

#practice
c <- "apples, pears, and bananas"
#str_split(c, ", | ") #BAD
str_split(c, boundary("word"))
str_split(c, "")

#str_locate(), str_sub()

#OTHER TYPES OF PATTERN
#can call regex to add parameters (ignore_case, multiline)
#ignore_case = TRUE allows characters to match either their uppercase or lowercase forms.
str_view(bananas, regex("banana", ignore_case = TRUE))

#multiline = TRUE allows ^ and $ to match the start and end of each line rather than the start and end of the complete string.
x <- "Line 1\nLine 2\nLine 3"
str_extract_all(x, "^Line")[[1]]
str_extract_all(x, regex("^Line", multiline = TRUE))[[1]]

#comments = TRUE allows you to use comments and white space to make complex regular expressions more understandable. Spaces are ignored, as is everything after #. To match a literal space, you’ll need to escape it: "\\ "
phone <- regex("
  \\(?     # optional opening parens
               (\\d{3}) # area code
               [)- ]?   # optional closing parens, dash, or space
               (\\d{3}) # another three numbers
               [ -]?    # optional space or dash
               (\\d{3}) # three more numbers
               ", comments = TRUE)

str_match("514-791-8141", phone)

#non reg-ex functions
#fixed() - use for performance reason
microbenchmark::microbenchmark(
  fixed = str_detect(sentences, fixed("the")),
  regex = str_detect(sentences, "the"),
  times = 20
)

#coll() - case insensitive matching - slow compared to regex and fixed

#using boundary
x <- "This is a \\sentence."
str_view_all(x, boundary("word"))
str_extract_all(x, boundary("word"))

#practice
str_view_all(x, "\\\\")
str_detect(x, fixed("\\"))

words <- str_split(sentences, " ")

#find all rmd files in directory
head(dir(pattern = "\\.Rmd$"))

#stringi - extends on stringr - 234 functions compared to 42 - use if can't do in stringR

