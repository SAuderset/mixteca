
library(tidyverse)
library(stringi)

# read in word list

setwd("/Users/auderset/Documents/GitHub/mixteca/Basic/LISTS")

# read in all files (delete template file and all unfinished ones first)
wl <- list.files(pattern = "*.csv") %>% map_df(~read_csv(.))
class(wl)
head(wl)

# restructure, delete rows with NA
wl1 <- wl %>% select(ID, DOCULECT, CONCEPT, FORM, IDlist, NOTES) %>%
  filter(FORM!="$") %>%
  mutate_if(is.double, as.integer)
# normalize unicode
wl1$FORM <- stri_trans_nfd(wl1$FORM)
# lower case
wl1$FORM <- tolower(wl1$FORM)
glimpse(wl1)
head(wl1)

# check for duplicate IDs after every list to avoid issues!
wl1 %>% count(ID) %>% filter(n > 1)

# export to tsv for further processing
write_tsv(wl2, "basiclist.tsv")
