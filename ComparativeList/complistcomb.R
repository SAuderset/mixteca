
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

# move floating tones to new column
wl1 <- wl1 %>% separate(VALUE, into = c("VALUE", "FLOAT1"), sep = "(?= \\[)") %>% 
  separate(VALUE, into = c("VALUE", "FLOAT2"), sep = "(?= \\{)") %>% 
  unite("FLOATTONE", FLOAT1, FLOAT2) %>%
  mutate(FLOATTONE = str_remove(FLOATTONE, "NA_NA")) %>%
  mutate(FLOATTONE = str_remove(FLOATTONE, "NA_")) %>%
  mutate(FLOATTONE = str_remove(FLOATTONE, "_NA"))
glimpse(wl1)

# copy values to form, if form is empty, order columsn
wl2 <- wl1 %>% mutate(FORM = if_else(is.na(FORM), VALUE, FORM)) %>%
  select(ID:VALUE, FORM, FLOATTONE, IDlist:SOURCE)
# normalize unicode
wl2$FORM <- stri_trans_nfd(wl2$FORM)
# lower case
wl2$FORM <- tolower(wl2$FORM)
glimpse(wl2)
head(wl2)

# check for duplicate IDs after every list to avoid issues!
wl2 %>% count(ID) %>% filter(n > 1)
# check for NA in ID
which(is.na(wl2$ID))

# sort by list item, then variety
wl2 <- wl2 %>% arrange(IDlist, DOCULECT) 

# entries per concept
ct <- table(wl2$IDlist)
plot(ct)
mean(ct)
median(ct)
max(ct)
min(ct)

# export to tsv for further processing
write_tsv(wl2, "/Users/auderset/Documents/GitHub/mixteca/ComparativeList/mixt_complist.tsv")

# to know where to continue IDs
max(wl2$ID, na.rm = TRUE)
# 5081
