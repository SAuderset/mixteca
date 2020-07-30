# convert Durr database to IPA

library(tidyverse)
library(rlist)
library(qlcData)
library(stringi)

# read in long durr db
durr <- read_csv("/Users/auderset/Desktop/testing/durr-1987-long-clean.csv")
glimpse(durr)

# replace doculect labels with my code ids
unique(durr$Doculect)
durr <- durr %>% mutate_if(is.character, as.factor) %>%
  mutate(Doculect = recode_factor(Doculect, Diu = "diux11", Pe = "peno11", Coa = "coat11", Mol = "moli11", Oco = "ocot11", Ata = "atat11", SM = "gran11", Cac = "caca11", Xay = "xaya11", Ay = "ayut11", Ala = "alac11", Met = "metl11", Cah = "cahu11", Mix = "mixt11", Sil = "prog12", Jic = "jica11", Jam = "chay11"))
glimpse(durr)

# normalize unicode in Forms
durrn <- durr %>% mutate(Form = stri_trans_nfkc(as.character(Form)))
glimpse(durrn)


durrprof <- write.profile(durrn$Form)
# export for manual clean up and adding ipa representation

write_csv(durrprof, "/Users/auderset/Desktop/testing/durr-1987-profiledraft.csv")

# check for graphemes I don't know the IPA
look <- durrn %>% filter(str_detect(Form, "d"))
look


# further clean up db for conversion
# remove brackets, remove !, make a separate column indicating tone modification (M), remove ', remove whitespace
charrem <- c("'|’| ̀|\\(|\\)|\\!")
durrf <- durrn %>% mutate(Form = str_remove_all(Form, charrem)) %>%
  mutate(ToneMod = if_else(str_detect(Form, "\\sM"), "yes", "no")) %>%
  mutate(Form = str_remove_all(Form, "\\sM")) %>%
  mutate_all(list(~str_remove_all(., "\\s+"))) 
glimpse(durrf)

# read in profile
profdurr <- read_csv("/Users/auderset/Desktop/testing/durr-1987-profile.csv")

# add column with tokenized forms and one with just transliteration
t <- tokenize(durrf$Form, profile = profdurr, transliterate = "IPA")
t

durrf <- durrf %>% mutate(IPAtok = t$strings$transliterated) %>%
  mutate(IPA = str_remove_all(t$strings$transliterated, "\\s+"))
glimpse(durrf)


