print("preprocessing of focus clinic @11")

# applying a filter to restrict our data to the core sample
focus_11 = focus_11 %>% filter(in_core == 1 | is.na(in_core))

# retrieving the labels of all variables in child_completed and focus_11 datasets
all_labels_focus_11 = get_labels(focus_11)

# retrieving the levels of all variables in the child_completed and focus_11 dataset
all_levels_focus_11 = get_levels(focus_11)

# creating a new dataframe for the cleaned dataset
focus_11_clean = focus_11

# using zap_labels to remove value labels (from labelled class objects)
# lapply() to apply the zap_labels to each element 
focus_11_clean = lapply(focus_11_clean, zap_labels)
# the output of lapply is a list, so converting the list to dataframe
focus_11_clean = as.data.frame(focus_11_clean)

duplicates <- duplicated(focus_11_clean$cidB4303) | duplicated(focus_11_clean$cidB4303, fromLast = TRUE)

focus_11_clean <- focus_11_clean[!duplicates,]


