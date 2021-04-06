# combine and clean up Josserand data from RAs

library(tidyverse)
library(stringi)

# read in raw data
setwd("/Users/auderset/Desktop/Thesis/mixteca/Digitalization/Josserand1983/")

joss <- list.files(pattern = "\\w+_raw.csv$") %>% map_df(~read_csv(.))
glimpse(joss)

# delete last empty column
# the Spanish, English and P-Mx will be listed for each df, delete
# joss <- select(joss, -X2) %>% distinct()
glimpse(joss)
head(joss)
sort(unique(joss$ID))
# 123 varieties plus Spanish, English, Pmx

# transpose
joss.t <- joss %>% slice(-c(1:2)) %>% 
  pivot_longer(`1`:`188`, names_to = "IDjoss", values_to = "VALUE")
head(joss.t)
glimpse(joss.t)
unique(joss.t$ID)
# add the glosses back
eng <- slice(joss, 2)
spa <- slice(joss, 1)
joss.t$GLOSS_E <- rep(as.character(eng[ ,-1]), (nrow(joss.t)/188))
joss.t$GLOSS_S <- rep(as.character(spa[, -1]), (nrow(joss.t)/188))
glimpse(joss.t)
head(joss.t)
sort(unique(joss.t$ID))

# rename and reorder columns
joss.f <- joss.t %>% select(IDjoss, GLOSS_E, GLOSS_S, VALUE, DOCULECT = ID)
glimpse(joss.f)


### create version to merge with the comparative list ###
# read in my list
tmpl <- read_tsv("/Users/auderset/Desktop/Thesis/mixteca/ComparativeList/LISTS/template.csv")
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
# combine the IDlist columns
joss.tmpl3 <- joss.tmpl3 %>% mutate(IDlist = coalesce(IDlist.x, IDlist.y)) %>% select(-IDlist.x, -IDlist.y)
# export for manual correction
write_csv(joss.tmpl3, "josserand-merge-out.csv")

# read back in
jl <- read_csv("josserand-merge-in.csv")
glimpse(jl)
# add to main df
joss.f$IDlist <- rep(as.character(jl$IDlist), (nrow(joss.f)/188))
joss.f$GLOSS_EL <- rep(as.character(jl$GLOSS_1), (nrow(joss.f)/188))
joss.f$GLOSS_SL <- rep(as.character(jl$GLOSS), (nrow(joss.f)/188))
glimpse(joss.f)

# add the doculects with my identifiers
# read in concordance file
conc <- read_tsv("/Users/auderset/Desktop/Thesis/mixteca/MetaInfo/mixtecan_concordance.tsv")
conc <- conc %>% mutate(Josserand_Code = stri_trans_nfkc(Josserand_Code))
glimpse(conc)

sort(unique(joss.f$DOCULECT))
# subset just id and josserand_code
conc.sub <- conc %>% select(ID, Josserand_Code) %>% 
  filter(!is.na(Josserand_Code)) %>%
  separate_rows(Josserand_Code, sep = ",")

# add to new column via lookup, convert to lowercase first
joss.m <- joss.f %>% mutate(DOCULECT = tolower(DOCULECT)) %>% mutate(DOCULECT = stri_trans_nfkc(DOCULECT))
glimpse(joss.m)
joss.m <- left_join(joss.m, conc.sub, by = c("DOCULECT"="Josserand_Code"))

# split cells with / into two rows
# clean out leading and trailing spaces, delete spaces before and after =,
joss.m <- joss.m %>% 
  mutate(VALUE = str_remove_all(VALUE, "\\*")) %>%
  mutate(VALUE = str_replace_all(VALUE, " =", "=")) %>%
  mutate(VALUE = str_replace_all(VALUE, "= ", "=")) %>%
  mutate(VALUE = str_replace_all(VALUE, " /", "/")) %>%
  mutate(VALUE = str_replace_all(VALUE, "/ ", "/")) %>%
  separate_rows(VALUE, sep = "/") %>%
  mutate(VALUE = trimws(VALUE, which = "both"))
glimpse(joss.m)

# clean up
joss.mexp <- joss.m %>% select(IDjoss, CODEjoss = DOCULECT, GLOSSenglish = GLOSS_E, GLOSSspanish = GLOSS_S, VALUE)

# export to file
write_csv(joss.mexp, "josserand1983_long.csv")

# further clean up for my use
# remove [] from entries, remove asterisk from protoforms
#  convert other spaces to -
joss.f2 <- joss.m %>% 
  mutate(VALUE = str_remove_all(VALUE, "\\[")) %>%
  mutate(VALUE = str_remove_all(VALUE, "\\]")) %>%
  mutate(VALUE = str_replace_all(VALUE, " ", "-"))

# filter, reorder for export and manual clean-up
joss.e <- joss.f2 %>% filter(!is.na(IDlist)) %>% 
  filter(DOCULECT!="Spanish") %>%
  filter(DOCULECT!="English") %>%
  filter(!is.na(VALUE)) %>%
  select(IDlist, GLOSS_EL, GLOSS_E, GLOSS_SL, GLOSS_S, VALUE, DOCULECT = ID, IDjoss, CODEjoss = DOCULECT) %>% mutate(IDlist = as.double(IDlist)) %>%
  distinct() %>%
  arrange(IDlist)
glimpse(joss.e)
sort(unique(joss.e$DOCULECT))

# export to file
write_csv(joss.e, "josserand_complist-out.csv")


