# create comparative Mixtecan list

library(tidyverse)
library(stringi)

# read in word list

setwd("/Users/auderset/Documents/GitHub/mixteca/ComparativeList/LISTS")

# read in all files (delete template file and all unfinished ones first)
wl <- list.files(pattern = "*_*.csv") %>% map_df(~read_delim(., "\t"))
head(wl)
glimpse(wl)


# restructure, delete rows with NA
wl1 <- wl %>% select(ID, DOCULECT, GLOSS, VALUE, FORM, IDlist, NOTES, LOAN, LOAN_SOURCE, SOURCE) %>%
  filter(VALUE!="$")
glimpse(wl1)

# subset with just loanwords for meeting
loans <- wl1 %>% filter(!is.na(LOAN)) %>% distinct()
write_csv(loans, "loanwords.csv")


# move floating tones in Hollenbach 2013/pena11 to new column
hb <- wl1 %>% filter(SOURCE=="hollenbach2017diccionario" | SOURCE=="alexander1980gramatica") %>% 
  separate(VALUE, into = c("VALUE", "FLOAT1"), sep = "(?= \\[)") %>% 
  separate(VALUE, into = c("VALUE", "FLOAT2"), sep = "(?= \\{)") %>% 
  unite("FLOATTONE", FLOAT1, FLOAT2) %>%
  mutate(FLOATTONE = str_remove(FLOATTONE, "NA_NA")) %>%
  mutate(FLOATTONE = str_remove(FLOATTONE, "NA_")) %>%
  mutate(FLOATTONE = str_remove(FLOATTONE, "_NA")) %>%
  mutate(FLOATTONE = trimws(FLOATTONE))
glimpse(hb)

# move floating tones in Swanton-Mendoza/vari to new column
sm <- wl1 %>% filter(SOURCE=="swanton2020observaciones") %>% 
  separate(VALUE, into = c("VALUE", "FLOATTONE"), sep = "(?=\\+)") %>%
  mutate(FLOATTONE = trimws(FLOATTONE))
glimpse(sm)

# add column to main df, paste two other dfs back
wl1.sub <- wl1 %>% filter(SOURCE!="swanton2020observaciones") %>% filter(SOURCE!="hollenbach2017diccionario") %>% filter(SOURCE!="alexander1980gramatica") %>% mutate(FLOATTONE=NA)
glimpse(wl1.sub)
wl2 <- bind_rows(wl1.sub, hb, sm)
wl2 <- filter(distinct(wl2))


# copy values to form, if form is empty, order columns
# for some reason it didn't work without coalesce...
wl3 <- wl2 %>% mutate(FORM = ifelse(is.na(FORM), coalesce(VALUE, FORM), coalesce(FORM, FORM)))
# normalize unicode
wl3$FORM <- stri_trans_nfd(wl3$FORM)
# lower case
wl3$FORM <- tolower(wl3$FORM)
glimpse(wl3)
head(wl3)

# check for duplicate IDs after every list to avoid issues!
wl3 %>% count(ID) %>% filter(n > 1)


# check for NA in identifier columns
which(is.na(wl3$ID))
which(is.na(wl3$DOCULECT))
which(is.na(wl3$IDlist))
wl3[26, ]

# sort by list item, then variety
wl3 <- wl3 %>% arrange(IDlist, DOCULECT)

# entries per concept
ct <- table(wl3$IDlist)
plot(ct)
mean(ct)
median(ct)
max(ct)
min(ct)

ctdf <- wl3 %>% group_by(IDlist) %>% summarise(entries = n()) %>% arrange(desc(entries))
ctdf

# how many loans
table(wl$LOAN)
# ca. 70


# total varieties
length(unique(wl3$DOCULECT))
# 133

# entries per variety
ev <- wl3 %>% group_by(DOCULECT) %>% summarise(entries = n()) %>% arrange(desc(entries))
ev
tail(ev)

# list all varieties
sort(unique(wl3$DOCULECT))
# 133 varieties

# export to tsv for further processing
write_tsv(wl3, "/Users/auderset/Documents/GitHub/mixteca/ComparativeList/mixt_complist.tsv")

# to know where to continue IDs
max(wl3$ID, na.rm = TRUE)
# 20249


### export single sheets for Josserand orthography profiles
jossp <- wl3 %>% group_by()
