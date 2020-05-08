library(tidyverse)

pdt <- read_delim("/Users/auderset/Desktop/Padgett-2014-98.tsv", delim = "\t", col_names = FALSE)
glimpse(pdt)

# wide to long
pdt1 <- gather(pdt, key = "col1" , value = "col2", X1:X2)
glimpse(pdt1)

# split col2
pdt2 <- pdt1 %>% separate(col2, into = c("NUMBER", "SPANISH", "ENGLISH"), sep = " ", extra = "merge") 
glimpse(pdt2)
head(pdt2)

# delet col1, change types
pdt3 <- pdt2 %>% select(NUMBER:ENGLISH) %>%
  mutate_at("NUMBER", as.integer) %>%
  mutate_at(c("SPANISH","ENGLISH"), as.factor)
glimpse(pdt3)

write_delim(pdt3, "/Users/auderset/Desktop/Padgett-2014-98-extracted.tsv", delim = "\t")
