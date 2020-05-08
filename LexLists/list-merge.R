library(tidyverse)

# load lists
# Campbell
ewc <- read_delim("/Users/auderset/Documents/GitHub/mixteca/LexLists/Campbell-2020-out.tsv", delim = "\t", col_types = list(col_double(), col_factor(), col_factor(), col_double(), col_factor(), col_factor()))
glimpse(ewc)

# Josserand
joss <- read_tsv("/Users/auderset/Documents/GitHub/mixteca/LexLists/Josserand-1983-188-out.tsv", col_types = list(col_factor(), col_double(), col_factor(), col_factor(), col_double(), col_factor(), col_factor()))
glimpse(joss)

# Dürr
durr <- read_tsv("/Users/auderset/Documents/GitHub/mixteca/LexLists/Duerr-1987-110-out.tsv", col_types = list(col_factor(), col_double(), col_factor(), col_double(), col_factor(), col_factor()))
glimpse(durr)

# Swanton-Mendoza
swme <- read_tsv("/Users/auderset/Documents/GitHub/mixteca/LexLists/Swanton-mendoza-2017-out.tsv", col_types = list(col_double(), col_factor(), col_double(), col_factor(), col_factor()))
glimpse(swme)

# Matsukawa
mat <- read_tsv("/Users/auderset/Documents/GitHub/mixteca/LexLists/Matsukawa-2005-523-out.tsv", col_types = list(col_double(), col_factor(), col_factor(), col_double(), col_factor(), col_factor()))
glimpse(mat)

# Padgett
pdt <- read_tsv("/Users/auderset/Documents/GitHub/mixteca/LexLists/Padgett-2014-98-out.tsv", col_types = list(col_double(), col_factor(), col_factor(), col_double(), col_factor(), col_factor()))
glimpse(pdt)


# merge the lists, start with largest ones, moving to smaller; rename ID columns
# merge campbell + matsukawa
m1 <- full_join(ewc, mat, by = c("CONCEPTICON_ID", "CONCEPTICON_GLOSS" , "ADD_CONCEPT")) %>% select(CONCEPTICON_ID, CONCEPTICON_GLOSS, ADD_CONCEPT, ID_EWC = NUMBER.x, ID_MAT = NUMBER.y, SPANISH_EWC = SPANISH.x, SPANISH_MAT = SPANISH.y, ENGLISH_EWC = ENGLISH.x , ENGLISH_MAT = ENGLISH.y)
glimpse(m1)
head(m1)


# merge with josserand
m2 <- full_join(m1, joss, by = c("CONCEPTICON_ID", "CONCEPTICON_GLOSS" ,"ADD_CONCEPT")) %>% select(CONCEPTICON_ID, CONCEPTICON_GLOSS, ADD_CONCEPT, ID_EWC:ID_MAT, ID_JOSS = NUMBER, SPANISH_EWC:SPANISH_MAT, SPANISH_JOSS = SPANISH, ENGLISH_EWC:ENGLISH_MAT, ENGLISH_JOSS = ENGLISH)
glimpse(m2)

# merge with durr
m3 <- full_join(m2, durr, by = c("CONCEPTICON_ID", "CONCEPTICON_GLOSS" ,"ADD_CONCEPT")) %>% select(CONCEPTICON_ID, CONCEPTICON_GLOSS, ADD_CONCEPT, ID_EWC:ID_JOSS, ID_DURR = NUMBER, SPANISH_EWC:SPANISH_JOSS, ENGLISH_EWC:ENGLISH_JOSS, ENGLISH_DURR = ENGLISH)
glimpse(m3)

# merge with swanton-mendoza
m4 <- full_join(m3, swme, by = c("CONCEPTICON_ID", "CONCEPTICON_GLOSS" ,"ADD_CONCEPT")) %>% select(CONCEPTICON_ID, CONCEPTICON_GLOSS, ADD_CONCEPT, ID_EWC:ID_DURR, ID_SWME = NUMBER, SPANISH_EWC:SPANISH_JOSS, SPANISH_SWME = SPANISH, ENGLISH_EWC:ENGLISH_DURR)
glimpse(m4)

# merge with padgett
m5 <- full_join(m4, pdt, by = c("CONCEPTICON_ID", "CONCEPTICON_GLOSS" ,"ADD_CONCEPT")) %>% select(CONCEPTICON_ID, CONCEPTICON_GLOSS, ADD_CONCEPT, ID_EWC:ID_SWME, ID_PADG = NUMBER, SPANISH_EWC:SPANISH_SWME, SPANISH_PADG = SPANISH, ENGLISH_EWC:ENGLISH_DURR, ENGLISH_PADG = ENGLISH)
glimpse(m5)

# check for duplicates in concepticon id
duplid <- m5 %>% group_by(CONCEPTICON_ID) %>% 
  filter(n()>1)
duplid
# house and maize in matsukawa

# add column that shows in how many lists a concept appears
m6 <- m5 %>% mutate(COVERAGE = (rowSums(!is.na(select(., one_of(c("ID_EWC", "ID_MAT", "ID_JOSS", "ID_DURR", "ID_SWME", "ID_PADG")))))))
glimpse(m6)

table(m6$COVERAGE)
# 325 concepts that are in more than 1 list

# export for manual clean up and inspection
write_csv(m6, "/Users/auderset/Documents/GitHub/mixteca/LexLists/full-list-preproc.csv")






