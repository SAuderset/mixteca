
library(tidyverse)

d <- read_tsv("/Users/auderset/Desktop/testing/durr-1987-raw.csv")
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

# clean up for export
dcomb1 <- dcomb %>% select(ID_Durr = name, Doculect = CogID.x, Concept = value.y, Form = value.x, PMCouplet = value) %>% filter(!is.na(Form))
glimpse(dcomb1)

# write to csv
write_csv(dcomb1, "/Users/auderset/Desktop/testing/durr-1987-long.csv")


