# combine and clean up Josserand data from RAs

library(tidyverse)
library(stringi)

# read in raw data
setwd("/Users/auderset/Documents/GitHub/mixteca/Digitalization/Josserand1983")

joss <- list.files(pattern = "*_raw.csv") %>% map_df(~read_csv(.))
glimpse(joss)

# delete last empty column
joss <- select(joss, -X2)
glimpse(joss)
# transpose
joss.t <- joss %>% rownames_to_column() %>%
  pivot_longer(-rowname, 'variable', 'value') %>%
  pivot_wider(variable, rowname)
glimpse(joss.t)
head(joss.t)
# convert to long format - assign first column as names, delete first row because it creates duplicates
joss.l <- joss.t %>% 
  pivot_longer(`4`:`113`, names_to = "name", values_to = "values", values_drop_na = TRUE) 
glimpse(joss.l)
head(joss.l)

?pivot_longer


