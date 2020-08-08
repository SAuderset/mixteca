# reformat Oxnard database for comparative list

library(tidyverse)
setwd("/Users/auderset/Documents/GitHub/mixteca/ComparativeList/OxnardDB")

oxn <- read_csv("oxnard-db-20200801.csv")
glimpse(oxn)

# delete second row, extra info not needed for data processing
oxn <- oxn[-1, ]
glimpse(oxn)

# select and rename relevant columns, clean ou leading and tralining white space
oxn1 <- oxn %>% select(ID = `NewID#`, Spanish = Español, English, tlah11 = TLHP, pied12 = `SMP/PiedraAzul`, flor12 = `San Marco de la Flor (SMP)`, mont12 = SSM, bate11 = `SJM (La Batea)`, asun11 = SMA) %>% 
  mutate_all(trimws)
glimpse(oxn1)

# clean up each column (no entry = empty cell)
# empty cells: "--"    "---"   "----"  "-----" "—" "_"    "-"    "--"   "---"  "----"
# delete row: "a que se refieren con esta palabra", "?"
emptycells <- c("--|---|----|-----|—|_|-|\\?")
oxn2 <- oxn1 %>% mutate_at(vars(tlah11:asun11), list(~str_remove_all(.x, emptycells))) %>% 
  mutate_if(is.character, as.factor) %>%
  droplevels()
glimpse(oxn2)
summary(oxn2)

# give number of non-empty cells for each variety
entries <- oxn2 %>% summarize_at(vars(tlah11:asun11), list(entries = ~sum(!is.na(.))))
entries

# merge with my list
mylist <- read_csv("/Users/auderset/Documents/GitHub/mixteca/ComparativeList/LISTS/template.csv")
glimpse(mylist)
# subset
mylist <- select(mylist, IDlist, GLOSS)

# merge
oxnm <- full_join(mylist, oxn2, by = c("GLOSS" = "Spanish"))
glimpse(oxnm)
head(oxnm)
anyDuplicated(oxnm)

# write to file to add other entries
write_csv(oxnm, "oxnard-db-list.csv")

# read edited file back in
oxed <- read.csv("oxnard-db-list-edit.csv")
glimpse(oxed)
# filter out entries from list
oxed1 <- oxed %>% filter(!is.na(IDlist)) %>% 
  select(IDlist, GLOSS, IDoxnard = ID, everything()) %>%
  mutate_if(is.character, as.factor)
summary(oxed1)
# exclude Asuncion, too few entries
oxed1 <- select(oxed1, -asun11)
glimpse(oxed1)
# wide to long, filter out NA
oxed2 <- pivot_longer(oxed1, tlah11:bate11, names_to = "DOCULECT", values_to = "VALUE") %>%
  filter(!is.na(VALUE)) %>%
  filter(VALUE!="")
glimpse(oxed2)
# generate ID, rename and reorder columns
oxed3 <- oxed2 %>% 
  mutate(SOURCE = "oxnard2020") %>%
  mutate(FORM = "") %>%
  mutate(NOTES = "") %>%
  mutate(ID = 2964:(nrow(oxed2)+2963)) %>% 
  select(IDlist, GLOSS, VALUE, FORM, ID, NOTES, DOCULECT, SOURCE) %>%
  mutate_if(is.character, as.factor)
glimpse(oxed3)


# write to file
write_csv(oxed3, "oxnard-complist.csv")



### VERBS ###
oxvb <- read.csv("/Users/auderset/Downloads/verbos-mixteco.csv")
glimpse(oxvb)

# select and rename relevant columns
oxvb1 <- oxvb %>% select(ID., Spanish = Español, English, TLHP_PRES:TLHP_FUT, SMF_PRES:SSM_FUT, SJM_PRES:SJM_FUT) %>%
  mutate_all(trimws) %>%
  mutate_if(is.character, as.factor) %>%
  droplevels()
glimpse(oxvb1)

# count verbs per variety
verbs <- oxvb1 %>% summarize_at(vars(TLHP_PRES:SJM_FUT), list(entries = ~sum(.!="")))
verbs

write_csv(oxvb1, "/Users/auderset/Downloads/oxnard-verbs-clean.csv")
