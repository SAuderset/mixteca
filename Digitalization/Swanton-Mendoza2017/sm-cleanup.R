
library(tidyverse)

sm <- read_csv("/Users/auderset/Documents/GitHub/mixteca/Digitalization/Swanton-Mendoza2017/swanton-mendoza2017_raw.csv")
head(sm)
glimpse(sm)

# convert to long format
incl <- c("PMx", "ALCO", "ZACA", "CHAL", "YUCQ")
sml <- sm %>% pivot_longer(cols = all_of(incl), names_to = "DOCULECT", values_to = "VALUE")
head(sml)
glimpse(sml)

# concatenate comments column
sml1 <- sml %>% unite("NOTES", CommentCHAL:CommentYUCQ, remove = TRUE, na.rm = TRUE)
glimpse(sml1)

# rename varieties
sml1 <- sml1 %>% mutate(DOCULECT = if_else(DOCULECT=="ALCO", "alco11", 
                                           if_else(DOCULECT=="ZACA", "zaca11", 
                                                   if_else(DOCULECT=="CHAL", "chal11", 
                                                           if_else(DOCULECT=="YUCQ", "yucu16", 
                                                                   if_else(DOCULECT=="PMx", "prom01", ""))))))

# add source column
# 430 rows
sml1$SOURCE <- rep("swanton2020observaciones", 430)

# reorder columns
sml2 <- sml1 %>% select(GLOSS, VALUE, NOTES, DOCULECT, SOURCE)


# write to csv
write_csv(sml2, "/Users/auderset/Documents/GitHub/mixteca/Digitalization/Swanton-Mendoza2017/swanton-mendoza2017_long.csv")

# rest has to be cleaned up by hand


