# modify list for cldf 

library(tidyverse)
library(stringi)

# read list
wl <- read_tsv("mixt_complist.tsv")

# read modified list
wl_mod <- read_tsv("../src/lexibank_mixteca/raw/mixt_complist_clean.tsv")

# language list
lang <- read_tsv("../src/lexibank_mixteca/etc/languages.tsv")

# concept list
conc <- read_tsv("../src/lexibank_mixteca/etc/concepts.tsv")

# concordance
cord <- read_tsv("../MetaInfo/mixtecan_concordance.tsv")


# add new lang identifiers and move codes to new column
wl_new1 <- left_join(wl, cord, by = c("DOCULECT" = "ID"))
glimpse(wl_new1)
wl_new2 <- wl_new1 %>% unite(DOCULECTNEW, c("Village_Name", "Subgroup"), sep = "") %>% mutate(DOCULECTNEW = stri_trans_general(DOCULECTNEW, "latin-ascii")) %>% mutate(DOCULECTNEW = str_remove_all(DOCULECTNEW, "\\sde\\s|\\sdel\\s|\\sde\\slas\\s")) %>% mutate(DOCULECTNEW = str_remove_all(DOCULECTNEW, "\\s"))
wl_new2 <- select(wl_new2, ID:DOCULECTNEW)
glimpse(wl_new2)

# add concepts with glosses etc.
glimpse(conc)
wl_new3 <- left_join(wl_new2, conc, by = c("GLOSS" = "SPANISH"), keep = TRUE)
conc <- conc %>% mutate(ENGLISHlow = tolower(ENGLISH))
wl_new4 <- left_join(wl_new3, conc, by = c("GLOSS" = "ENGLISHlow"), keep = TRUE)
glimpse(wl_new4)


# rename and rearrange for manual cleanup
wl_new5 <- wl_new4 %>% unite(ENGLISH, c("ENGLISH.x", "ENGLISH.y"), sep = "", na.rm = TRUE, remove = TRUE) %>% unite(ENGLISH_NEW, c("ENGLISH_NEW.x", "ENGLISH_NEW.y"), sep = "", na.rm = TRUE, remove = TRUE) %>% unite(CONCEPTICON_ID, c("CONCEPTICON_ID.x", "CONCEPTICON_ID.y"), sep = "", na.rm = TRUE, remove = TRUE) %>% unite(CONCEPTICON_GLOSS, c("CONCEPTICON_GLOSS.x", "CONCEPTICON_GLOSS.y"), sep = "", na.rm = TRUE, remove = TRUE) %>% unite(NUMBER, c("NUMBER.x", "NUMBER.y"), sep = "", na.rm = TRUE, remove = TRUE) %>% unite(SPANISH, c("SPANISH.x", "SPANISH.y"), sep = "", na.rm = TRUE, remove = TRUE)
glimpse(wl_new5)


wl_new6 <- wl_new5 %>% select(ID, DOCULECT = DOCULECTNEW, CONCEPT = ENGLISH, SPANISH_GLOSS = SPANISH, GLOSS, VALUE, FORM, IDlist, CONCEPTICON_ID, LOAN, LOAN_SOURCE, SOURCE, FLOATTONE, VARIETY_CODE = DOCULECT)
glimpse(wl_new6)
glimpse(wl_mod)

# export
write_tsv(wl_new6, "mixt_complist_addons.tsv")


# unicode normalization of finished list
clean_list <- read_tsv("/Users/auderset/Documents/GitHub/mixteca/src/lexibank_mixteca/raw/mixt_complist_clean.tsv")
glimpse(clean_list)
# normalize all character columns
clean_list <- clean_list %>% mutate_if(is.character, stri_trans_nfc)
glimpse(clean_list)
# write back to file, make sure to set NA to empty!
write_tsv(clean_list, "/Users/auderset/Documents/GitHub/mixteca/src/lexibank_mixteca/raw/mixt_complist_clean.tsv", na = "")

ortho <- read_tsv("/Users/auderset/Documents/GitHub/mixteca/src/lexibank_mixteca/etc/orthography.tsv")
ortho_clean <- ortho %>% mutate_if(is.character, stri_trans_nfc)
write_tsv(ortho_clean, "/Users/auderset/Documents/GitHub/mixteca/src/lexibank_mixteca/etc/orthography.tsv", na = "")

