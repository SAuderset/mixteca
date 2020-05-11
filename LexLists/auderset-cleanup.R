
library(tidyverse)

aud <- read_csv("/Users/auderset/Documents/GitHub/mixteca/LexLists/Auderset-2020-NA.csv")

glimpse(aud)
tail(aud)

# delete empty rows, delete white space, glosses to lower case
aud1 <- aud %>% slice(1:200) %>% 
  mutate_at(vars(ENGLISH, SPANISH), str_to_lower) %>%
  mutate_if(is.double, as.integer) %>%
  mutate_if(is.character, trimws) %>% 
  mutate_if(is.character, as.factor)
glimpse(aud1)  

# reorder columns
aud2 <- aud1 %>% select(ID, CATEGORY, SPANISH, ENGLISH, CONCEPTICON_ID, CONCEPTICON_GLOSS, ADD_CONCEPT, COVERAGE, ID_EWC, ID_JOSS, ID_DURR, ID_SWME, ID_MAT, ID_PADG, everything())
glimpse(aud2)

# export for final cleanup
write_csv(aud2, "/Users/auderset/Documents/GitHub/mixteca/LexLists/Auderset-2020-200-out.csv")
