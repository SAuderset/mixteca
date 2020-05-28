# restructuring the SMD verb data base into long format
# last edited: 2019-11-08

library(tidyverse)
library(xlsx) # for reading in excel file, saves the step of converting it to csv each time

# set working directory
setwd("/Users/auderset/Desktop/Thesis/VerbParadigms/RawData/")

# load file
vsmd <- read.xlsx("SMD-Verb_database-Base_de_datos_verbal.xlsx", sheetIndex = 1)
head(vsmd)
glimpse(vsmd)

### data clean up/normalization etc. ###
vsmd.long1 <- vsmd %>% gather(key = features, value = forms, c(PRES:FUT, NEG.PRES:NEG.IMP), factor_key = TRUE) %>% arrange(ID)
head(vsmd.long1)
glimpse(vsmd.long1)

vsmd.long2 <- vsmd.long1 %>% gather(key = label, value = tone, (TONE.IMPF:TONE.IRR))
glimpse(vsmd.long2)

# check for duplicates
anyDuplicated(vsmd.long1)

# clean up
# delete some columns we don't need, reorder
vsmd.long2 <- vsmd.long1 %>% select(ID:English, features, forms, Valence, Morphemes, Glosses, Joss.., preguntas.notas) %>% droplevels()
glimpse(vsmd.long2)

# look into specific columns for adjustments
unique(vsmd.long2$features)


### set up new cldf format file ###
ID <- (1:length(vsmd.long)) # generate verb form ID
Verb_ID <- vsmd.long$ID
Language_ID <- rep(1:length(vsmd.long), "dura11") # add language code
English <- vsmd.long$English
Spanish <- vsmd.long$Español
Feature_ID <- vmsd.long$features
Form <- vsmd.long$forms


