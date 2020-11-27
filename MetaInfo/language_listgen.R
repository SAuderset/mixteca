# generate a languages file for cldf from concordance

library(tidyverse)
library(stringi)
setwd("/Users/auderset/Documents/GitHub/mixteca/MetaInfo")

# read concordance
conc <- read_tsv("mixtecan_concordance.tsv")
glimpse(conc)

# select and rename relevant columns
conc1 <- conc %>% select(Code = ID, Location = Village_Name, SubGroup = Subgroup, Latitude, Longitude, Glottocode, ISO639P3code) %>% filter(!is.na(Code))
glimpse(conc1)

# add Number column
conc2 <- conc1 %>% mutate(Number = seq_along(1:nrow(conc1))) %>% select(Number, everything())
glimpse(conc2)

# make new name column for better readability
conc3 <- conc2 %>% unite("Name", Location:SubGroup, sep = "", remove = FALSE) %>% 
  mutate(Name = stri_trans_general(Name, "Latin-ASCII")) %>% 
  mutate(Name = str_remove_all(Name, " de | del | de la |\\(|\\)")) %>%
  mutate(Name = str_replace_all(Name, " ", ""))
glimpse(conc3)


# save file
write_tsv(conc3, "languages.tsv")
