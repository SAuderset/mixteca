# prepare SMD verb paradigms for use with Qumin
# last edit: 14/05/2020

library(tidyverse)
library(rlist)
library(qlcData)

smd <- read.csv("/Users/auderset/Desktop/testing/verbs-SMD-raw.csv")
glimpse(smd)

# concatenate the first two columns to fit Qumin format
smdq <- smd %>% unite(lexeme, ID:IRR_TL, sep = "_") %>% mutate(lexeme = as.factor(lexeme))
glimpse(smdq)

# convert each column to ipa
# read orthography profile
smd.ort <- read_tsv("/Users/auderset/Desktop/testing/Qumin/auderset-hernandez2020-1.csv")
glimpse(smd.ort)

# use profile to tokenize
s <- smdq %>% select(-lexeme) %>% mutate_all(list(~str_replace_all(.," ", "")))
# define function to only keep transliterated forms
trforms <- function(x){
 y <- tokenize(x, profile = smd.ort, transliterate = "IPA", regex = TRUE)
 return(y$strings$transliterated)
  }
# apply
vipa <- sapply(s, function(t) trforms(t))
vipa <- as.data.frame(vipa)
head(vipa)

# add lexeme column back
vipa$LEXEME <- smdq$lexeme
# reorder
vipa <- select(vipa, LEXEME, everything())

# remove spaces
vipa_new <- vipa %>% mutate_all(list(~str_remove_all(., "\\s+"))) 
glimpse(vipa_new)

# ku -> kw before vowel, then convert to factor
vipa2 <- vipa_new %>% mutate_all(list(~str_replace_all(., pattern="ku\\d(?=[aei])", replacement="kʷ"))) %>% 
  mutate_if(is.character, as.factor)
# check
vipa2[42, ]
glimpse(vipa2)

# check for problems
summary(vipa2)

# clean out questions marks
vipa3 <- vipa2 %>% mutate(PFV = replace(PFV, PFV=="⁇⁇⁇", NA))
summary(vipa3)


# write to file
write_csv(vipa3, "/Users/auderset/Desktop/testing/Qumin/paradigms_smd.csv", na = "#DEF#")


# create separate segment and tone files for further analysis
vipa_char <- vipa_new %>% 
  mutate_at(c("IMPF", "PFV", "IRR"), as.character)
glimpse(vipa_char)

vipa_seg <- vipa_char %>% mutate(IMPF = str_remove_all(IMPF, pattern = "[:digit:]"), PFV = str_remove_all(PFV, pattern = "[:digit:]"), IRR = str_remove_all(IRR, pattern = "[:digit:]")) %>% 
  mutate(PFV = replace(PFV, PFV=="⁇⁇⁇", NA)) %>%
  mutate_if(is.character, as.factor)
glimpse(vipa_seg)

# write to file
write_csv(vipa_seg, "/Users/auderset/Desktop/testing/Qumin/paradigms-seg_smd.csv", na = "#DEF#")

# tones
vipa_tone <- vipa_char %>% mutate(IMPF = gsub("\\D+", "", vipa_char$IMPF), PFV = gsub("\\D+", "", vipa_char$PFV), IRR = gsub("\\D+", "", vipa_char$IRR)) #%>% mutate_if(is.character, as.factor)
glimpse(vipa_tone)

# write to file
write.table(vipa_tone, "/Users/auderset/Desktop/testing/Qumin/paradigms-tone_smd.csv", 
            na = "#DEF#", 
            quote = TRUE, 
            sep = ",",
            row.names = TRUE,
            col.names = TRUE)


