
library(tidyverse)
setwd("/Users/auderset/Documents/GitHub/mixteca/Digitalization/Pensinger1974/")

pens <- read_lines(file = "pensinger_chayuco1974_extract.txt")
head(pens)
class(pens)

# make into df with one column
pensdf <- as.data.frame(pens)

# delete empy rows, delete rows with letter head
pensdf <- pensdf %>% filter(pens!="") %>% filter(str_detect(pens, "[^[[:upper:]]\\s]"))
pensdf[1:20, ]
glimpse(pensdf)


# delete line breaks where there is no () to separate entries
pensdf1 <-pensdf %>% separate(pens, into = c("entry", "rest"), sep = "(?<=\\))", fill = "right")
glimpse(pensdf1)
head(pensdf1)

# move the description info to the second column
pensdf2 <- pensdf1 %>% mutate(rest = if_else(is.na(rest), paste(entry), paste(rest))) %>% mutate(entry = ifelse(entry==rest, " ", paste(entry)))

# split further, split off word class
max(sapply(strsplit(pensdf2$rest,"."),length))
pensdf3 <- pensdf2 %>% separate(rest, into = paste0("X",1:66), sep = "(?<=\\.)") %>%
  separate(entry, into = c("entry", "wordclass"), sep = "(?=\\()")

# export for manual clean-up
write_csv(pensdf3, "pensinger_preproc.csv")








pensdf1 <- pensdf %>% mutate(pens = paste(pens, collapse = "$"))
pens2 <- paste(pens, collapse = "$")
head(pens2)



# now split into columns
gtdf1 <- separate(gtdf, gt, paste0("X",1:66), sep=" ")
head(gtdf1)

# filter rows that probably contain verbs
gtdf2 <- gtdf1 %>% filter_all(any_vars(str_detect(., "^[yv][^aeo]$")))
unique(gtdf2$X2)

verbsplitting <- function(x) {
  dfout <- gtdf2 %>% filter(str_detect(.[[x]], "^[yv][^aeo]$")) %>% 
    unite("Description", (x+1):66, sep = " ", na.rm = TRUE) %>% 
    unite("Verb", 1:(x-1)) 
}

# apply to df
v <- map_df(1:(ncol(gtdf2)-1), verbsplitting)
glimpse(v)
# collate collumns with verb class in them
vf <- v %>%  unite("VerbClass", X2:X65, sep = "", na.rm = TRUE) %>%
  select(Verb, VerbClass, Description)
glimpse(vf)

# export to csv
write_csv(vf, "/Users/auderset/Documents/GitHub/mixteca/Dictionaries/Good1978/good1979_verbs.csv")



