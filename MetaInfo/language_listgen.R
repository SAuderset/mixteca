# generate a languages file for cldf from concordance

library(tidyverse)
setwd("/Users/auderset/Documents/GitHub/mixteca/MetaInfo")

# read concordance
conc <- read_csv("mixtecan_concordance.csv")
glimpse(conc)

# select and rename relevant columns
conc1 <- conc %>% select(Name = id, Location = village_name, Branch = branch, Latitude = latitude, Longitude = longitude, Glottocode = glottocode, ISO639P3code = isocode) %>%
  filter(!is.na(Name))
glimpse(conc1)

# add ID column
conc2 <- conc1 %>% mutate(ID = seq_along(1:nrow(conc1))) %>% select(ID, everything())

# save as tsv
write_tsv(conc2, "languages.tsv")
