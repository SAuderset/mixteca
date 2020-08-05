
library(tidyverse)
library(readODS)
library(stringi)

setwd("/Users/auderset/Documents/GitHub/mixteca/OrthographyProfiles")

# read each tab in with name
path <- "OrthographyProfiles.ods"
sheets <- list_ods_sheets(path)
oplist <- map(seq_along(sheets), read_ods, path = path) %>%
  set_names(sheets)

# normalize unicode
# oplist <- oplist %>% map(~mutate(., IPA = stri_trans_nfkc(IPA)))

# export each df to a tsv
setwd("./PROFILES")
mapply(write_tsv, oplist, path = paste0(names(oplist), ".tsv"))
