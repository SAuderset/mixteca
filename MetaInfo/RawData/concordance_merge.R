# last modified: 18.02.2020

library(tidyverse)
library(stringi)

inali <- read.csv("/Users/auderset/Desktop/Thesis/inali_clean.csv")
glimpse(inali)

joss <- read.csv("/Users/auderset/Desktop/Thesis/jossglottmtree.csv")
glimpse(joss)

geo <- read.csv("/Users/auderset/Desktop/Thesis/geonamesMX.csv", sep = "\t")
glimpse(geo)
# clean up, i.e. remove all unneeded information
levels(geo$geonames_featureclass) # exclude all rows with: H (bodies of water), L (landscape), R (roads), S (other stuff), T (mountains), U (undersea), V (forest)
geo1 <- geo %>% filter(geonames_featureclass=="P" | geonames_featureclass=="A") %>% droplevels()
glimpse(geo1)
levels(geo1$geonames_featureclass)
unique(geo1$geonames_featurecode)
# ADM1 = state, ADM2 = municipality, ADM3 = some presidencias-delete!, ADMD delete, LTER delete!, PCLI delete, PPLA also state?, PPLA2 municipality seat, PPLA5 delete, PPLC delete, PPLF villages, PPLL villages, PPLQ delete, PPLS villages, PPLW delete, PPLX delete, ZN delete
geo2 <- geo1 %>% filter(geonames_featurecode=="PPL" | geonames_featurecode=="PPLA" | geonames_featurecode=="PPLA2" | geonames_featurecode=="PPLF" | geonames_featurecode=="PPLL" | geonames_featurecode=="PPLS" | geonames_featurecode=="") %>% droplevels()
glimpse(geo2)
# split off df with just villages
geov <- geo2 %>% filter(geonames_featureclass=="P") %>% droplevels()
glimpse(geov)
summary(geov$geonames_featurecode)
# clean out now irrelevant column
geov <- select(geov, -geonames_featureclass)

  
# create new name columns without accents, diacritics, spaces, and capitalization since they might applied inconsistently and then the merge will not work well
inali$village_norm <- tolower(stri_trans_general(inali$village, id = "Latin-ASCII"))
inali$village_norm <- stri_replace_all_charclass(inali$village_norm, "\\p{WHITE_SPACE}", "")

joss$village_norm <- tolower(stri_trans_general(joss$village_name, id = "Latin-ASCII"))
joss$village_norm <- stri_replace_all_charclass(joss$village_norm, "\\p{WHITE_SPACE}", "")

geov$geonames_norm <- tolower(stri_trans_general(geov$geonames_nameutf8, id = "Latin-ASCII"))
geov$geonames_norm <- stri_replace_all_charclass(geov$geonames_norm, "\\p{WHITE_SPACE}", "")

glimpse(inali)
glimpse(joss)
glimpse(geov)
tail(geov)


# merge by normalized village name
mxmerge1 <- full_join(joss, inali, by = "village_norm")
anyDuplicated(mxmerge1)
glimpse(mxmerge1)
head(mxmerge1)

# merge with geonames
mxmerge2 <- full_join(mxmerge1, geov, by = c("village_norm" = "geonames_norm"))
glimpse(mxmerge2)
head(mxmerge2)

# reorder, delete columns
mxmerge.clean <- mxmerge %>% select(ID, village, village_name, municipality, state, latitude, longitude, glottocode, isocode, glottolog_name, glottolog_level:glottolog_group, josserand_group:josserand_code, inali_name, inali_endonym_ort, inali_endonym_ipa, egland_name:village_norm)
glimpse(mxmerge.clean)

write_csv(mxmerge.clean, "/Users/auderset/Desktop/Thesis/mixtec_conc.csv")

