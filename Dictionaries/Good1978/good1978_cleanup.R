
library(tidyverse)

gt <- read_lines(file = "/Users/auderset/Desktop/good1979_preproc.txt")
head(gt)
class(gt)

# find max number of "columns" for splitting
max(sapply(strsplit(gt," "),length))
# 66

# make into df with one column
gtdf <- as.data.frame(gt, V1=gt) 

# now split into columns
gtdf1 <- separate(gtdf, gt, paste0("X",1:66), sep=" ")
head(gtdf1)

# filter rows that probably contain verbs
gtdf2 <- gtdf1 %>% filter_all(any_vars(str_detect(., "^[yv][^aeo]$")))
unique(gtdf2$X2)

# split into parts depending on where the verb class is noted
v1 <- gtdf2 %>% filter(str_detect(X2, "^[yv][^aeo]$")) %>% 
  unite("Description", X3:X66, sep = " ", na.rm = TRUE) %>% 
  rename(Verb = X1, VerbClass = X2)
v2 <- gtdf2 %>% filter(str_detect(X3, "^[yv][^aeo]$")) %>% 
  unite("Description", X4:X66, sep = " ", na.rm = TRUE) %>% 
  unite("Verb", X1:X2) %>% 
  rename(VerbClass = X3)

# merge together
gdverbs <- bind_rows(v1, v2)
gdverbs <- arrange(gdverbs, Verb)

# export to csv
write_csv(gdverbs, "/Users/auderset/Desktop/good1979_verbs.csv")



