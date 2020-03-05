library(tidyverse)
library(reshape2)

inali <- read.csv("/Users/auderset/Desktop/Thesis/inali_scraped.csv", strip.white = TRUE)
glimpse(inali)
head(inali)

# rename columns for easier coding
inali <- inali %>% rename(AUTO = AUTODENOMINACIÓN.DE.LA.VARIANTE.LINGÜÍSTICA.Y.NOMBRE.EN.ESPAÑOL) %>% rename(GEO = REFERENCIA.GEOESTADÍSTICA)

# replace the : with ; after the state name for easier separation
i1 <- as.data.frame(sapply(inali, function(c) gsub("(?<=[[:upper:]])\\:", "\\;", c, perl = TRUE)))
glimpse(i1)
str_count(i1$GEO, ";") # there's one row that has two states in there so we need to separate that out first
which(str_count(i1$GEO, ";")>1) # 78
# split GEO column - multiple states in frontera group; can't use a general function because otherwise it splits off all the states already and we don't want that
i1.part <- i1[78, ] %>% separate_rows(GEO, sep = ";")
i1.part[,2]
# not elegant, but don't know how else to do it
i1.part[2,2] <- paste("OAXACA;", i1.part[2,2])
i1.part[2,2] <- gsub("PUEBLA", "", i1.part[2,2])
i1.part[3,2] <- paste("PUEBLA;", i1.part[3,2])
i1.part <- i1.part[-1, ]
i1.part

# delete original row from main df and add this part on
i1 <- i1[-78, ]
i1a <- rbind.data.frame(i1, i1.part)
glimpse(i1a)
write_csv(i1a, "/Users/auderset/Desktop/Thesis/t1.csv")

# split along states, clean out whitespace
# ATTENTION: don't split along period, some municipality names have one in them
i2 <- i1a %>% separate(GEO, sep = ";", into = c("state", "rest"))
glimpse(i2)
i2 <- as.data.frame(sapply(i2, function(s) gsub("^\\s+|\\s+$", "", s)))
glimpse(i2)
head(i2)
i2[59, ]
write_csv(i2, "/Users/auderset/Desktop/Thesis/t2.csv")
# split GEO column - municipalities into separate rows
sum(str_count(i2$rest, ":")) # there's a total of 181 municipalities, i.e. we should end up with 181 rows
# can't simply split at period, because some municipality names have a period in them, e.g. Juan R. Escudero; so we need to be specific: the period has to be preceded by a lower case character
i3 <- i2 %>% separate_rows(rest, sep = "(?<=[[:lower:]])\\.") 
glimpse(i3) 
# clean out whitespace and rows that have empty 'rest' (created because they all end in periods)
i3 <- as.data.frame(sapply(i3, function(s) gsub("^\\s+|\\s+$", "", s))) %>% filter(rest!="")
glimpse(i3) # 178 - we're missing three, so check why that is
i3[c(29,33,69), 3] # the problem is that here there is a bracket before the period, so we need to run the above again with that adjustment
i3 <- i3 %>% separate_rows(rest, sep = "(?<=[[:lower:]]\\))\\.") 
# clean out whitespace and rows that have empty 'rest' (created because they all end in periods)
i3 <- as.data.frame(sapply(i3, function(s) gsub("^\\s+|\\s+$", "", s))) %>% filter(rest!="")
glimpse(i3) #181 oerfect!

# now separate out municipality
i4 <- i3 %>% separate(rest, sep = ":", into = c("municipality", "village"))
i4 <- as.data.frame(sapply(i4, function(s) gsub("^\\s+|\\s+$", "", s)))
# copy municipality into villages, because they are also villages
i4$villages <- paste(i4$municipality, i4$village, sep = ", ")
glimpse(i4)
# finally split off villages into separate rows; clean out whitespace again
i5 <- i4 %>% separate_rows(villages, sep = ",")
i5 <- as.data.frame(sapply(i5, function(s) gsub("^\\s+|\\s+$", "", s))) %>% distinct()
glimpse(i5)

# now split AUTO column
# find places to split first
i5[1,1] # at exonym first
i6 <- i5 %>% separate(AUTO, sep = "<", into = c("endonyms", "inali_name"))
glimpse(i6)
# split endonyms first into two main parts
i6[50,1] # no unique separator, replace \n\t\t with just \t so I can split at \n; count max number of \n
i6$endonyms <- sapply(i6$endonyms, function(r) gsub("\n\t\t", "\t", r))
max(str_count(i6$endonyms, "\n")) # 2, which means 3 endonyms
i7 <- i6 %>% separate(endonyms, sep = "\n", into = c("endonym1", "endonym2", "endonym3"))
glimpse(i7)
# split endonym columns at \t, delete bracketed content (because redundant)
i8 <- i7 %>% separate(endonym1, sep = "\t", into = c("endonym1_ort", "endonym1_ipa"))
i8$endonym1_ort <- sapply(i8$endonym1_ort, function(d) gsub(" *\\(.*?\\) *", "", d))
# repeat for other two columns
i8 <- i8 %>% separate(endonym2, sep = "\t", into = c("endonym2_ort", "endonym2_ipa"))
i8$endonym2_ort <- sapply(i8$endonym2_ort, function(d) gsub(" *\\(.*?\\) *", "", d))
i8 <- i8 %>% separate(endonym3, sep = "\t", into = c("endonym3_ort", "endonym3_ipa"))
i8$endonym3_ort <- sapply(i8$endonym3_ort, function(d) gsub(" *\\(.*?\\) *", "", d))
glimpse(i8)

# concatenate endonyms again into two columns: one orthography and one IPA
i9 <- i8 %>% unite(inali_endonym_ort, c(endonym1_ort, endonym2_ort, endonym3_ort), sep = " ~ ", remove = TRUE) %>% unite(inali_endonym_ipa, c(endonym1_ipa, endonym2_ipa, endonym3_ipa), sep = " ~ ", remove = TRUE)

# clean out NA from the new column
i9 <- as.data.frame(sapply(i9, function(n) gsub("\\s~\\sNA", "", n)))
glimpse(i9)

# clean up name column
i10 <- as.data.frame(sapply(i9, function(c) gsub(">", "", c, fixed = TRUE)))
# convert state to lower case with capital
i10$state <- as.factor(str_to_sentence(i10$state))
glimpse(i10)

# final clean-up: reorder and rename columns, final whitespace clean-out
i11 <- i10 %>% select(villages, municipality, state, inali_endonym_ort, inali_endonym_ipa, inali_name)
i11 <- as.data.frame(sapply(i11, function(s) gsub("^\\s+|\\s+$", "", s)))
glimpse(i11)
head(i11)
# check for duplicates
anyDuplicated(i11)
# 2, remove duplicates
i11 <- distinct(i11)
anyDuplicated(i11)

# write to file
write_csv(i11, "/Users/auderset/Desktop/Thesis/inali_clean.csv")
