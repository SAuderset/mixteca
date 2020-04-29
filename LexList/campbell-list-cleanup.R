

library(tidyverse)


ewc <- read.csv("/Users/auderset/Desktop/campbell_list.csv")
glimpse(ewc)

# delete empty columns and emtpy rows
ewc1 <- ewc %>% select(X., Glosa.Gloss) %>% filter(Glosa.Gloss!="") %>% droplevels()
glimpse(ewc1)
# split eng and spa glosses
ewc2 <- ewc1 %>% separate(Glosa.Gloss, sep = "\\(", into = c("English", "Spanish"))
glimpse(ewc2)
# clean out whitespace, brackets
ewc3 <- ewc2 %>% mutate(English = str_remove(English, "\\s+")) %>%
  mutate(Spanish = str_remove(Spanish, "\\s+")) %>%
  mutate(Spanish = str_remove(Spanish, "\\)")) %>%
  mutate_if(is.character, as.factor) 
  
#%>% 
 # str_remove(ewc2$Spanish, "\\s+") %>% 
  #str_remove(ewc2$Spanish, "\\)") %>%
  #str_remove(ewc2$Spanish, "\\,")

glimpse(ewc3)
head(ewc3)

# write for manual clean up

