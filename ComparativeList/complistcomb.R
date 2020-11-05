 
# export to tsv for further processing
write_tsv(wl3, "/Users/auderset/Documents/GitHub/mixteca/ComparativeList/mixt_complist.tsv")

# to know where to continue IDs
max(wl3$ID, na.rm = TRUE)
# 21000


### export single sheets for orthography profiles
# make named list
group_names <- wl3 %>% group_keys(DOCULECT) %>% pull(1)
docugroups <- wl3 %>% group_split(DOCULECT) %>% set_names(group_names)
# solution from here: https://martinctc.github.io/blog/vignette-write-and-read-multiple-excel-files-with-purrr/
# Step 1
# Define a function for exporting csv with the desired file names and into the right path
profiles_tsv <- function(data, names){ 
  folder_path <- "/Users/auderset/Documents/GitHub/mixteca/ComparativeList/ProfileLists/"
  write_tsv(data, paste0(folder_path, "profile-basis-", names, ".tsv"))
}
# Step 2
list(data = docugroups,
     names = names(docugroups)) %>% pmap(profiles_tsv)

