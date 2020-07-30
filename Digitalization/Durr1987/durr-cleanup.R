
library(tidyverse)

d <- read_tsv("/Users/auderset/Documents/GitHub/mixteca/Durr1987/durr-1987-raw.csv")
head(d)
glimpse(d)

# convert to long format
# subset into names and values
dval <- slice(d, -(1:2))
head(dval)

dnames <- slice(d, 1:2)
head(dnames)

d1 <- dval %>% pivot_longer(-CogID)
head(d1)
glimpse(d1)

d2 <- dnames %>% pivot_longer(-1)
head(d2)
glimpse(d2)
#subset again
dconcept <- slice(d2, 1:110)
dcouplet <- slice(d2, 111:220)

# paste together
dcomb <- inner_join(d1, dconcept, by = "name", copy = TRUE)
dcomb <- inner_join(dcomb, dcouplet, by = "name", copy = TRUE)
glimpse(dcomb)

# replace doculect labels with my code ids
unique(dcomb$CogID.x)
dcomb <- dcomb %>% mutate_if(is.character, as.factor) %>%
  mutate(Doculect = recode_factor(CogID.x, Diu = "diux11", Pe = "peno11", Coa = "coat11", Mol = "moli11", Oco = "ocot11", Ata = "atat11", SM = "gran11", Cac = "caca11", Xay = "xaya11", Ay = "ayut11", Ala = "alac11", Met = "metl11", Cah = "cahu11", Mix = "mixt11", Sil = "prog12", Jic = "jica11", Jam = "chay11"))
glimpse(dcomb)

# fix the entries that have additional stuff in them, which are:
# split entries into rows that have /
# "horse", "broken", "weed", "leaf", "important", "it is yellow"
dcomb1 <- dcomb %>% separate_rows(value.x, sep = "/") %>% mutate(value.x = str_remove_all(value.x, "\""))
glimpse(dcomb1)

# add column for tone modification and one for citation form
dcomb1 <- dcomb1 %>% mutate(ToneMod = if_else(str_detect(value.x, "(M)"), "yes", "no")) %>%
  mutate(CitForm = if_else(str_detect(value.x, "!"), "yes", "no"))
# delete those strings
dcomb1 <- dcomb1 %>% mutate(value.x = str_remove_all(value.x, "/(M/)|!"))
glimpse(dcomb1)

# clean up for export, add ID for each entry
dcomb2 <- dcomb1 %>% filter(!is.na(value.x)) %>%  select( Doculect, Concept = value.y, Form = value.x, PMCouplet = value, CogID_Durr = name, ToneMod, CitForm)
dcomb2 <- dcomb2 %>% mutate(ID = seq_along(1:nrow(dcomb2))) %>% select(ID, everything())
glimpse(dcomb2)

# write to csv
write_csv(dcomb2, "/Users/auderset/Documents/GitHub/mixteca/Durr1987/durr-1987-long.csv")

# rest has to be cleaned up by hand


