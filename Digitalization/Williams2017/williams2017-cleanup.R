# extract verbs from Williams 2017

library(tidyverse)

setwd("/Users/auderset/Documents/GitHub/mixteca/Digitalization/Williams2017")

wl <- read_lines("williams2017_preproc.txt")

# delete spaces between verb classes
wl <- str_remove(wl, "(?<=v\\.|yv\\.|y\\.)\\s(?=i\\.|i\\s|í\\s|£|t\\.|t\\s|cop|recíp)")
wl[4897]

# find max number of "columns" for splitting
max(sapply(strsplit(wl," "),length))
# 247

# make into df with one column
wl.df <- as.data.frame(wl, V1=wl) 

# now split into columns
wl.df1 <- separate(wl.df, wl, paste0("X",1:247), sep=" ")
head(wl.df1)
nrow(wl.df1)

# filter rows that probably contain verbs
wl.df2 <- wl.df1 %>% filter_all(any_vars(str_detect(., "(v\\.|yv\\.|y\\.)(i\\.|i\\s|í\\s|£|t\\.|t\\s|cop|recíp)")))
# add an index for sorting later
wl.df2$Index <- 1:nrow(wl.df2)
# rename X1
wl.df2 <- wl.df2 %>% select(X1:X247, Index)
glimpse(wl.df2)

# split into parts depending on where the verb class is noted
# function for splitting at verb, for some reason rename doesn't work in there
verbsplitting <- function(x) {
  dfout <- wl.df2 %>% filter(str_detect(.[[x]], "^(v\\.|yv\\.|y\\.)(i.|i\\s|í\\s|£|t.|t\\s|cop|recíp)$")) %>% 
    unite("Rest", (x+1):247, sep = " ", na.rm = TRUE) %>% 
    unite("Verb", 1:(x-1))
}

# apply to df
wl.v <- map_df(1:(ncol(wl.df2)-1), verbsplitting)
glimpse(wl.v)
# collate collumns with verb class in them
# reorder first so that all the uniting ones will be adjacent
wl.vf <- wl.v %>% unite("VerbClass", X2:X246, sep = " ", na.rm = TRUE) %>% 
  select(Index, Verb, VerbClass, Rest) %>%
  arrange(Index)
glimpse(wl.vf)
# for some reason, spaces are replaced with _ in one column
wl.vf <- wl.vf %>% mutate(Verb = str_replace_all(Verb, "_", " "))
glimpse(wl.vf)

# split Rest column, so that the bracketed forms are in their own columns
wl.vf1 <- wl.vf %>% separate(Rest, into = c("Rest", "Forms"), sep = "\\[", extra = "merge", fill = "left") %>% 
  separate(Forms, into = c("Verb.IMPF", "Verb.PFV"), sep = ";", extra = "merge", fill = "left") %>%
  separate(Verb.PFV, into = c("Verb.PFV", "Rest2"), sep = "\\]", extra = "merge", fill = "left") %>%
  separate(Rest, into = c("Spanish", "Example"), sep = "(?=[[:upper:]]{1})", extra = "merge", fill = "left")
# remove pres./pas. labels, remove extra white space
wl.vf2 <- wl.vf1 %>% mutate(Verb.IMPF = str_remove(Verb.IMPF, "pres.")) %>%
  mutate(Verb.PFV = str_remove(Verb.PFV, "pas.")) %>%
  mutate_if(is.character, str_trim)
glimpse(wl.vf2)


# export to csv
write_csv(wl.vf2, "williams2007_verbs.csv")







