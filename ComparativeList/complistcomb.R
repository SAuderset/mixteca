# create comparative Mixtecan list

library(tidyverse)
library(stringi)

setwd("/Users/auderset/Desktop/Thesis/mixteca/ComparativeList")


# read in all files (except template file)
# won't work without full.names = TRUE!
wl <- map_dfr(list.files(path = "./LISTS", pattern = "*\\d\\d_*.csv", full.names = TRUE), read_tsv)
head(wl)
glimpse(wl)

# restructure, delete rows with NA
wl1 <- wl %>% select(DOCULECT, GLOSS, VALUE, FORM, IDlist, NOTES, LOAN, LOAN_SOURCE, SOURCE) %>%
  filter(VALUE!="$")
wl1 <- wl1 %>% mutate(ID = 1:nrow(wl1))
glimpse(wl1)

unique(wl1$SOURCE)
sort(unique(wl1$DOCULECT))

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


# add Concepticon IDs and concepts
#cpt <- read_tsv("/Users/auderset/Documents/GitHub/mixteca/ComparativeList/concepticon-mapping.tsv")
#glimpse(cpt)
#cpt.sub <- select(cpt, IDlist, CONCEPTICON_ID, CONCEPT)
#wl2 <- full_join(wl2, cpt.sub, by = "IDlist") %>% distinct()


# copy values to form, if form is empty, order columns
# for some reason it didn't work without coalesce...
# delete brackets from FORM column (pertinent to Josserand 1983)
wl3 <- wl2 %>% mutate(VALUE = stri_trans_nfc(VALUE)) %>%
  mutate(FORM = ifelse(is.na(FORM), coalesce(VALUE, FORM), coalesce(FORM, FORM))) %>%
  mutate(FORM = str_remove_all(FORM, "\\(")) %>%
  mutate(FORM = str_remove_all(FORM, "\\)"))
# normalize unicode, lower case for initial capitals
# attention: do not lowercase everything! in Josserand the upper case is used for voiceless segments!
# all spaces to -, otherwise really weird stuff shows up in the orthography profile
wl3 <- wl3 %>% mutate(FORM = stri_trans_nfc(wl3$FORM)) %>%
  mutate(FORM = if_else(stri_detect_regex(FORM, "^[[:upper:]]"), stri_trans_tolower(FORM), stri_trans_nfc(FORM))) %>% mutate(FORM = str_replace_all(FORM, fixed(" "), "-"))
# rearrange columns
wl3 <- select(wl3, ID, DOCULECT, GLOSS:IDlist, LOAN:FLOATTONE) %>% distinct()
glimpse(wl3)
head(wl3)


# check for NA in identifier columns
which(is.na(wl3$ID))
which(is.na(wl3$DOCULECT))
which(is.na(wl3$IDlist))

# sort by list item, then variety
wl3 <- wl3 %>% arrange(IDlist, DOCULECT)

# entries per concept
ct <- sort(table(wl3$IDlist))
plot(sort(ct))
mean(ct)
median(ct)
max(ct)
min(ct)

ctdf <- wl3 %>% group_by(IDlist) %>% summarise(entries = n()) %>% arrange(desc(entries))
ctdf

# how many loans
table(wl$LOAN)
# ca. 270

# total varieties
length(unique(wl3$DOCULECT))
# 140

# entries per variety
ev <- wl3 %>% group_by(DOCULECT) %>% summarise(entries = n()) %>% arrange(desc(entries))
ev
tail(ev)

# export to tsv for further processing
write_tsv(wl3, "mixt_complist.tsv")

# export list of doculects plus source for checking off orthography profiles
orthography_list <- wl3 %>% select(DOCULECT, SOURCE) %>% distinct()
write_tsv(orthography_list, "orthography_checklist.tsv")

# to know where to continue IDs
max(wl3$ID, na.rm = TRUE)
# 21764


# ### export single sheets for orthography profiles
# # make named list
# group_names <- wl3 %>% group_keys(DOCULECT) %>% pull(1)
# docugroups <- wl3 %>% group_split(DOCULECT) %>% set_names(group_names)
# # solution from here: https://martinctc.github.io/blog/vignette-write-and-read-multiple-excel-files-with-purrr/
# # Step 1
# # Define a function for exporting csv with the desired file names and into the right path
# profiles_tsv <- function(data, names){ 
#   folder_path <- "/Users/auderset/Documents/GitHub/mixteca/ComparativeList/ProfileLists/"
#   write_tsv(data, paste0(folder_path, "profile-basis-", names, ".tsv"))
# }
# # Step 2
# list(data = docugroups,
#      names = names(docugroups)) %>% pmap(profiles_tsv)

