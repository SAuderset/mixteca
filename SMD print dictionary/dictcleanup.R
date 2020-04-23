# SMD data base editions for print version
# 22.04.2020

library(tidyverse)
library(readxl)

?read_excel


# load data sets
lex <- read_xlsx("/Users/auderset/Documents/GitHub/mixtec-collections/SMD\ print\ dictionary/SMD-Base_de_datos_lexica.xlsx")
vb <- read_xlsx("/Users/auderset/Documents/GitHub/mixtec-collections/SMD\ print\ dictionary/SMD-Base_de_datos_verbal.xlsx")
lsort <- read.csv("/Users/auderset/Documents/GitHub/mixtec-collections/SMD\ print\ dictionary/smd_sortorder.csv", header = FALSE)
sortvec <- as.character(lsort$V2)

glimpse(lex)
glimpse(vb)
glimpse(lsort)

# subset and recode to factors
lex1 <- lex %>% select(ID:ClasePalabra) %>% 
  filter(Spanish!="?", English!="?") %>%  
  mutate_if(is.character, as.factor) %>% 
  droplevels()
glimpse(lex1)

vb1 <- vb %>% 
  select(ID:English) %>% 
  mutate_if(is.character, as.factor) %>% 
  droplevels()
glimpse(vb1)


?order


