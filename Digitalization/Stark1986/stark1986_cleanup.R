# prepare Stark et.al. 1986 dictionary for further processing

library(tidyverse)

setwd("/Users/auderset/Documents/GitHub/mixteca/Digitalization/Stark1986")

st <- read_lines(file = "stark1986_preproc.txt")
head(st)
class(st)

# find max number of "columns" for splitting
max(sapply(strsplit(st," "),length))
# 161

# make into df with one column
stdf <- as.data.frame(st, V1=st) 

# now split into columns
stdf1 <- separate(stdf, st, paste0("X",1:161), sep=" ")
head(stdf1)
nrow(stdf1)

# filter rows that probably contain verbs
# verb abbreviations: v aux (the aux will end up in different column) vc ve vi vt
stdf2 <- stdf1 %>% filter_all(any_vars(str_detect(., "^v[ceit]$|aux")))
# add an index for sorting later
stdf2$Index <- 1:nrow(stdf2)
glimpse(stdf2)

# split into parts depending on where the verb class is noted
# function for splitting at verb, for some reason rename doesn't work in there
verbsplitting <- function(x) {
    dfout <- stdf2 %>% filter(str_detect(.[[x]], "^v[ceit]$|aux")) %>% 
    unite("Description", (x+1):161, sep = " ", na.rm = TRUE) %>% 
    unite("Verb", 1:(x-1)) 
}

# apply to df
v <- map_df(2:(ncol(stdf2)-1), verbsplitting)
glimpse(v)
# collate collumns with verb class in them
# reorder first so that all the uniting ones will be adjacent
vf <- v %>% select(Index, Verb, X2, X3:X160, Description) %>%
  unite("VerbClass", X2:X160, sep = "", na.rm = TRUE) %>% 
  arrange(Index)
glimpse(vf)
# for some reason, spaces are replaced with _ in one column
vf <- vf %>% mutate(Verb = str_replace_all(Verb, "_", " "))
glimpse(vf)

# split Verb columns, so that the bracketed forms are in their own column, split out square bracket forms, split out translation
vf <- vf %>% separate(Verb, into = c("Verb", "Verb.IMPF"), sep = "\\(", extra = "merge", fill = "left") %>% 
  separate(Description, into = c("Ex", "Forms"), sep = "\\[", extra = "merge", fill = "left") %>% 
  separate(Forms, into = c("Verb.IRR", "Verb.PFV"), sep = ",", extra = "merge", fill = "left") %>%
  separate(Ex, into = c("Spanish", "Example"), sep = "(?=\\s[[:upper:]])", extra = "merge", fill = "left")
# remove brackets, remove extra white space
vf <- vf %>% mutate(Verb.IMPF = str_remove(Verb.IMPF, "\\)")) %>%
  mutate(Verb.PFV = str_remove(Verb.PFV, "\\]")) %>%
  mutate_if(is.character, str_trim)
glimpse(vf)

# select and arrange columns for export
vf1 <- vf %>% select(Index, Verb.IMPF, VerbClass, Spanish, Example, Verb.IRR, Verb.PFV)
glimpse(vf1)

# export to csv
write_csv(vf1, "stark1986_verbs.csv")


