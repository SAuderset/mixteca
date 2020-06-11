
library(tidyverse)
library(qlcData)
library(stringi)

# solution adapted from here: https://stackoverflow.com/questions/46299777/add-filename-column-to-table-as-multiple-files-are-read-and-bound

#create a list of the files from your target directory
file_list <- list.files(path="/Users/auderset/Documents/GitHub/mixteca/OrthographyProfiles/PROFILES/")

# read in and combine files, create new columns from file names for variety and source
data = tibble(File = file_list) %>%
  extract(File, into = c("Source", "Variety"), "([[:print:]]+)_([[:alnum:]]+)", remove = FALSE) %>%
  mutate(Data = lapply(File, read_tsv)) %>%
  unnest(Data) %>%
  select(Source:Comments)
glimpse(data)

# unicode normalize
prfs <- data %>% mutate_at(vars(Grapheme, IPA), list(~stri_trans_nfkc(.))) %>%
  mutate_at(vars(Source, Variety), list(~as.factor(.)))
glimpse(prfs)

levels(prfs$Source)

# summarize graphemes per IPA character
graph <- prfs %>% group_by(IPA) %>% 
  summarize(GraphVar = n_distinct(Grapheme)) %>% 
  arrange(desc(GraphVar))
graph
ggplot(graph, aes(x = reorder(IPA, -GraphVar), y = GraphVar)) + geom_bar(stat = "identity")

# consonants only
graph.cons <- prfs %>% filter(Class == "consonant") %>%
  group_by(IPA) %>% 
  summarize(GraphVar = n_distinct(Grapheme)) %>% 
  arrange(desc(GraphVar))
graph.cons
summary(graph.cons)

# vowel and tone only
graph.vt <- prfs %>% filter(Class == "vowel and tone") %>%
  group_by(IPA) %>% 
  summarize(GraphVar = n_distinct(Grapheme)) %>% 
  arrange(desc(GraphVar))
graph.vt
summary(graph.vt)











         
  