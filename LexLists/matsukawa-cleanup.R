
library(tidyverse)

setwd("/Users/auderset/Desktop/")

# read in without breaks
ptr <- read_delim("matsukawa-2005-extracted.csv", delim = "\n", col_names = FALSE)

head(ptr)

# start breaking into columns
# with // because most salient breaking point
ptr1 <- ptr %>% separate(X1, sep = "//", into = c("p1", "p2"), extra = "merge")
head(ptr1)
glimpse(ptr1)
# split p1 at period, then split at Capital letter
ptr2 <- ptr1 %>% 
  separate(p1, sep = "\\.", into = c("p1", "English"), extra = "merge") %>% 
  separate(p1, sep = "(?=[[:upper:]])", into = c("ProtoTriqui", "WordClass"))
glimpse(ptr2)
# split 2 at period
ptr2 <- ptr2 %>% separate(p2, sep = "\\.", into = c("Spanish", "p2"), extra = "merge")
# split lang data
ptr3 <- ptr2 %>% 
  separate(p2, sep = "(Ch.)", into = c("Chic", "p3"), extra = "merge") %>% 
  separate(p3, sep = "(Co.)", into = c("Copa", "other"), extra = "merge")
# split Chic further
ptr4 <- ptr3 %>% separate(Chic, sep = "<", into = c("ChicIPA", "ChicOrth"), extra = "merge")
glimpse(ptr4)

# clean up for export
# clean out white space, delete brackets, and periods, convert to factors
ptr5 <- ptr4 %>% mutate_all(list(~str_remove_all(., "[<>//(//)//.//*]"))) %>% 
  mutate_all(trimws) %>% 
  mutate_if(is.character, as.factor)
# add an ID column
ptr5$ID <- seq_len(nrow(ptr5))
# make first column
ptr5 <- select(ptr5, ID, everything())
glimpse(ptr5)
head(ptr5)

# write to file
write_csv(ptr5, "matsukawa-2005-preproc.csv")


