
library(tidyverse)
library(stringi)

# read in word list

setwd("/Users/auderset/Documents/GitHub/mixteca/ComparativeList/LISTS")

# read in all files (delete template file and all unfinished ones first)
wl <- list.files(pattern = "*.csv") %>% map_df(~read_csv(.))
class(wl)
head(wl)

# restructure, delete rows with NA
wl1 <- wl %>% select(ID, DOCULECT, GLOSS, VALUE, FORM, IDlist, NOTES, SOURCE) %>%
  filter(VALUE!="$")
glimpse(wl1)

# copy values to form, if form is empty
wl1 <- wl1 %>% mutate(FORM = if_else(is.na(FORM), VALUE, FORM))
# normalize unicode
wl1$FORM <- stri_trans_nfd(wl1$FORM)
# lower case
wl1$FORM <- tolower(wl1$FORM)
glimpse(wl1)
head(wl1)

# check for duplicate IDs after every list to avoid issues!
wl1 %>% count(ID) %>% filter(n > 1)

# export to tsv for further processing
write_tsv(wl1, " /Users/auderset/Documents/GitHub/mixteca/ComparativeList/mixt_complist.tsv")

# to know where to continue IDs
max(wl1$ID)
