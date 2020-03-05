library(tidyverse)
library(xml2)

mtree <- read_xml("/Users/auderset/Desktop/Thesis/10716.xml")

mtree_name_eng <- xml_text(xml_find_all(mtree, "//pri-name"), trim = TRUE)
head(mtree_name_eng)

mtree_name_spa <- xml_text(xml_find_all(mtree, '//alt-names'), trim = TRUE)
head(mtree_name_spa) # there's actually no difference here, except calling Mixtec Mixteco plus typos and missing data, i.e. won't need this part

mtree_code <- xml_text(xml_find_all(mtree, '//codes'), trim = TRUE)
head(mtree_code)

mtree_codealt <- xml_text(xml_find_all(mtree, '//other-codes'), trim = TRUE)
head(mtree_codealt)

mtree_level<- xml_text(xml_find_all(mtree, '//node-type'), trim = TRUE)
unique(mtree_level) # not needed, only has Language and Subgroup

mtree_geo <- xml_text(xml_find_all(mtree, '//geography'), trim = TRUE)
head(mtree_geo)
# split and restructure later

mtree_comments<- xml_text(xml_find_all(mtree, '//pub-comments'), trim = TRUE)
head(mtree_comments)

mtree.df <- data.frame(mtree_name_eng, mtree_code, mtree_codealt, mtree_geo, mtree_comments)
glimpse(mtree.df)
mtree.df[0:50, ] # Mixtec starts at row 14 and ends at 28, so delete everything before/after that

# restructure and clean up df
mtree.df1 <- mtree.df[14:28, ]
mtree.df1 <- droplevels(mtree.df1)
glimpse(mtree.df1)
# separate geo column
mtree.df2 <- mtree.df1 %>% separate(mtree_geo, sep = ";", into = c("del", "mtree_latitude", "mtree_longitude"))
glimpse(mtree.df2)
# keep only the numbers from the lat and long columns
mtree.df2$mtree_latitude <- sapply(mtree.df2$mtree_latitude, function(n) 
  gsub(".*:","", n))
mtree.df2$mtree_longitude <- sapply(mtree.df2$mtree_longitude, function(n) 
  gsub(".*:","", n))

# clean up name column
levels(mtree.df2$mtree_name_eng)
# keep only text between parentheses
mtree.df2$mtree_name <- unlist(str_extract_all(mtree.df2$mtree_name_eng, "(?<=\\().+?(?=\\))"))
glimpse(mtree.df2)

# clean out spaces and delete left-over columns
mtree.df3 <- as.data.frame(sapply(mtree.df2, function(s) gsub("^\\s+|\\s+$", "", s))) %>% select(-del, -mtree_name_eng)
# convert long and lat to numeric
mtree.df3$mtree_latitude <- as.numeric(as.character(mtree.df3$mtree_latitude))
mtree.df3$mtree_longitude <- as.numeric(as.character(mtree.df3$mtree_longitude))
glimpse(mtree.df3)

# write to csv
write_csv(mtree.df3, "/Users/auderset/Desktop/Thesis/multitree.csv")



### Ethnologue Tree ###
mtree2 <- read_xml("/Users/auderset/Desktop/Thesis/14192.xml")

mtree2_name <- xml_text(xml_find_all(mtree2, "//pri-name"), trim = TRUE)
head(mtree2_name)

mtree2_code <- xml_text(xml_find_all(mtree2, '//codes'), trim = TRUE)
head(mtree2_code)


mtree2.df <- data.frame(mtree2_name, mtree2_code)
glimpse(mtree2.df)
mtree2.df[87:172, ] # Mixtec starts at row 87 and ends at 172, so delete everything before/after that

# restructure and clean up df
mtree2.df1 <- mtree2.df[87:172, ]
mtree2.df1 <- droplevels(mtree2.df1)
glimpse(mtree2.df1)


# clean out spaces and delete left-over columns
mtree2.df3 <- as.data.frame(sapply(mtree2.df1, function(s) gsub("^\\s+|\\s+$", "", s)))
glimpse(mtree2.df3)

# write to csv
write_csv(mtree2.df3, "/Users/auderset/Desktop/Thesis/multitree_ethnologue.csv")



