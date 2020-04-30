
library(tidyverse)

# Campbell's list
ewc <- read.csv("/Users/auderset/Documents/GitHub/mixteca/LexList/campbell-list-raw.csv")
glimpse(ewc)

# delete empty columns and emtpy rows
ewc1 <- ewc %>% select(X., Glosa.Gloss) %>% filter(Glosa.Gloss!="") %>% droplevels()
glimpse(ewc1)
# split eng and spa glosses
ewc2 <- ewc1 %>% separate(Glosa.Gloss, sep = "\\(", into = c("English", "Spanish"))
glimpse(ewc2)
# clean out whitespace, brackets
ewc3 <- ewc2 %>% mutate(English = str_remove(English, "\\s+")) %>%
  mutate(Spanish = str_remove(Spanish, "\\s+")) %>%
  mutate(Spanish = str_remove(Spanish, "\\)")) %>%
  mutate_if(is.character, as.factor) 

glimpse(ewc3)
head(ewc3)

# write for manual clean up
write_csv(ewc3, "/Users/auderset/Documents/GitHub/mixteca/LexList/campbell-list-new.csv")


# Eric's New List
ewcc <- read.csv("/Users/auderset/Documents/GitHub/mixteca/LexList/campbell-list-final.csv")
glimpse(ewcc)

# Josserand's list
joss <- read.csv("/Users/auderset/Documents/GitHub/mixteca/LexList/josserand-list-raw.csv")
glimpse(joss)

# Dürr's list
durr <- read.csv("/Users/auderset/Documents/GitHub/mixteca/LexList/durr-list-raw.csv")
glimpse(durr)

# Swanton-Mendoza list
swme <- read.csv("/Users/auderset/Documents/GitHub/mixteca/LexList/swanton-mendoza-list-raw.csv")
glimpse(swme)


# merge the lists, start with largest ones, moving to smaller; rename ID columns
# merge campbell + josserand
m1 <- full_join(ewcc, joss, by = c("Spanish", "English")) %>% rename(EWC = ID.x, JOSS = ID.y)
glimpse(m1)
# merge with durr
m2 <- full_join(m1, durr, by = c("Spanish", "English")) %>% rename(DURR = ID)
glimpse(m2)
# merge with swanton-mendoza
m3 <- full_join(m2, swme, by = c("Spanish", "English")) %>% rename(SWME = ID)
glimpse(m3)

# reorder columns
m3 <- m3 %>% select(EWC, JOSS, DURR, SWME, Spanish, English)
# check for duplicates
anyDuplicated(m3)

# export for manual clean up
write_csv(m3, "/Users/auderset/Documents/GitHub/mixteca/LexList/full-list-raw.csv")






