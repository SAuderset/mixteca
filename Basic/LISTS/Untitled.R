
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

# check for duplicate IDs
wl1 %>% count(ID) %>% filter(n > 1)
# fix ID
wl2 <- mutate(wl1, ID = 
                ifelse(ID>558, ID+1, 
                                  ifelse(ID==558 & CONCEPT=="rope", ID+1, ID)))
# more fixes 
wl2 <- mutate(wl2, ID = ifelse(ID>1375, ID+1, ID))
wl2 <- mutate(wl2, ID = ifelse(ID>1426, ID+1, ID))
# add IDs for NA
wl2 <- mutate(wl2, ID = ifelse(DOCULECT=="yoso11" & CONCEPT =="face", 1376, ID))
wl2 <- mutate(wl2, ID = ifelse(DOCULECT=="yoso11" & CONCEPT =="rope", 1427, ID))
wl2 %>% count(ID) %>% filter(n > 1)


# export to tsv for further processing
write_tsv(wl2, "basiclist.tsv")
