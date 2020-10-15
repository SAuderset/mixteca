# combine and clean up Josserand data from RAs

library(tidyverse)
library(stringi)

# read in raw data
setwd("/Users/auderset/Documents/GitHub/mixteca/Digitalization/Josserand1983/")

joss <- list.files(pattern = "\\w+_raw.csv$") %>% map_df(~read_csv(.))
glimpse(joss)
head(joss)
sort(unique(joss$ID))

# delete last empty column
joss <- select(joss, -X1, -X2)
glimpse(joss)

# transpose
joss.t <- joss %>% slice(-c(1:2)) %>% 
  pivot_longer(`1`:`188`, names_to = "IDjoss", values_to = "VALUE")
head(joss.t)
glimpse(joss.t)
unique(joss.t$ID)
# add the glosses back
eng <- slice(joss, 2)
spa <- slice(joss, 1)
joss.t$GLOSS_E <- rep(as.character(eng[ ,-1]), 120)
joss.t$GLOSS_S <- rep(as.character(spa[, -1]), 120)
glimpse(joss.t)
head(joss.t)

# rename and reorder columns
joss.f <- joss.t %>% select(IDjoss, GLOSS_E, GLOSS_S, VALUE, DOCULECT = ID)
glimpse(joss.f)

# export to file
write_csv(joss.f, "josserand1983_long.csv")


### create version to merge with the comparative list ###
# read in my list
tmpl <- read_csv("/Users/auderset/Documents/GitHub/mixteca/ComparativeList/LISTS/template.csv")
# select relevant cols
tmpl <- tmpl %>% select(IDlist, GLOSS, GLOSS_1)
glimpse(tmpl)

# extract concepts from josserand
joss.cpt <- slice(joss.f, 1:188) %>% select(IDjoss:GLOSS_S)
# merge with my list
joss.tmpl <- left_join(joss.cpt, tmpl, by = c("GLOSS_S" = "GLOSS"))
joss.tmpl2 <- left_join(joss.tmpl, tmpl, by = c("GLOSS_E" = "GLOSS_1"))
glimpse(joss.tmpl2)
# coaleasce list numbers into one column
joss.tmpl3 <- joss.tmpl2 %>% mutate(IDlist = coalesce(IDlist.x, IDlist.y)) %>% select(IDjoss, IDlist, everything())
glimpse(joss.tmpl3)
# export for manual correction
write_csv(joss.tmpl3, "josserand-list-merge.csv")

# read back in
jl <- read_csv("josserand-list-merge.csv")
glimpse(jl)
# add to main df
joss.f$IDlist <- rep(as.character(jl$IDlist), 120)
joss.f$GLOSS_EL <- rep(as.character(jl$GLOSS_1), 120)
joss.f$GLOSS_SL <- rep(as.character(jl$GLOSS), 120)
glimpse(joss.f)
#

# filter, reorder for export and manual clean-up
joss.e <- joss.f %>% filter(!is.na(IDlist)) %>% 
  filter(DOCULECT!="Spanish") %>%
  filter(DOCULECT!="English") %>%
  filter(!is.na(VALUE)) %>%
  select(IDlist, GLOSS_EL, GLOSS_E, GLOSS_SL, GLOSS_S, VALUE, DOCULECT, IDjoss) %>% mutate(IDlist = as.double(IDlist)) %>%
  arrange(IDlist)
glimpse(joss.e)

# export to file
write_csv(joss.e, "josserand_complist.csv")


