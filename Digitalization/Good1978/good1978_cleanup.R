
library(tidyverse)

gt <- read_lines(file = "/Users/auderset/Documents/GitHub/mixteca/Dictionaries/Good1978/good1978_preproc.txt")
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

verbsplitting <- function(x) {
  dfout <- gtdf2 %>% filter(str_detect(.[[x]], "^[yv][^aeo]$")) %>% 
    unite("Description", (x+1):66, sep = " ", na.rm = TRUE) %>% 
    unite("Verb", 1:(x-1)) 
}

# apply to df
v <- map_df(1:(ncol(gtdf2)-1), verbsplitting)
glimpse(v)
# collate collumns with verb class in them
vf <- v %>%  unite("VerbClass", X2:X65, sep = "", na.rm = TRUE) %>%
  select(Verb, VerbClass, Description)
glimpse(vf)

# export to csv
write_csv(vf, "/Users/auderset/Documents/GitHub/mixteca/Dictionaries/Good1978/good1979_verbs.csv")



