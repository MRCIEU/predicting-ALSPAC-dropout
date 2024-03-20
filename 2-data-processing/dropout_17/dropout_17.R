print("Defining the outcome variable for dropout at age 17")
# Defining the outcome variable for dropout at age 17 using the child_completed at age 17 and focus_17 datasets

child_completed_17 = child_completed[, grepl("ccs", colnames(child_completed)) |
                                     !grepl("ccj|ccs|cp|YPD", colnames(child_completed))]

# applying a filter to restrict our data to the core sample
child_completed = child_completed %>% filter(in_core == 1 | is.na(in_core))
focus_17 = focus_17 %>% filter(in_core == 1 | is.na(in_core))

# retrieving the labels of all variables in child_completed and focus_11 datasets
all_labels_child_completed_17 = get_labels(child_completed_17)
all_labels_focus_17 = get_labels(focus_11)

# retrieving the levels of all variables in the child_completed and focus_11 dataset
all_levels_child_completed_17 = get_levels(child_completed_17)
all_levels_focus_17 = get_levels(focus_17)


# defining the outcome variable for child_completed_17 dataset using "ccs007"
# ccs0007 (Questionnaire completed (as of 10/11/09)) has values 1,2,-2, 9999
# 1: Questionnaire Completed - Yes; 
# 2: Questionnaire Completed - No; 
# -2: Questionnaire not sent; -9999 : consent withdrawn

# outcome variable "questionnaire_dropout" is 0 refers to questionnaire completed(No Dropout)
# 1 refers to questionnaire not completed(dropout)
child_completed_17$questionnaire_dropout <- ifelse(child_completed_17$ccs0007 == 1, 0, 1)
child_completed_17$questionnaire_dropout <- factor(child_completed_17$questionnaire_dropout,
                                        levels = c(0, 1),
                                        labels = c("No_Dropout", "Dropout"))


# defining outcome variable for F17 Clinic visit dataset using "FJ001c"
# FJ001c(Attended F17 clinic)
# outcome variable "clinic_dropout" is 0  refers to attended clinic(No dropout), 
# 1 refers to not attended the clinic(dropout)

focus_17 <- focus_17 %>% 
  mutate(clinic_dropout = ifelse(is.na(FJ001c), 1, ifelse(FJ001c == 1, 0, 1)))

focus_17$clinic_dropout = factor(focus_17$clinic_dropout,
                                 levels = c(0, 1),
                                 labels = c("No_Dropout", "Dropout"))

# Select only "cidB4303" and "questionnaire_dropout" from child_completed_17
child_completed17_subset = child_completed_17[, c("cidB4303", "questionnaire_dropout")]
# removing any duplicates
child_completed17_subset = child_completed17_subset[!duplicated(child_completed17_subset$cidB4303), ]

# Select only "cidB4303" and "clinic_dropout" from focus_17
focus_17_subset = focus_17[, c("cidB4303", "clinic_dropout")]
# removing any duplicates
focus_17_subset = focus_17_subset[!duplicated(focus_17_subset$cidB4303), ]

# merging the datasets
merged_data_17 <- merge(child_completed17_subset, focus_17_subset, by = "cidB4303")
print("dim of child_completed17_subset")
print(dim(child_completed17_subset))

print("dim of focus_17_subset")
print(dim(focus_17_subset))

print("dim of merged_data_17")
print(dim(merged_data_17))

# merging the predictors datasets
predictors_17 = merge(mother_clean, child_completed_11_clean, by = "cidB4303")
print("dim of mother_clean")
print(dim(mother_clean))

print("dim of completed_11_clean")
print(dim(child_completed_11_clean))

print("dim of predictors 17")
print(dim(predictors_17))

# creating a dataset for predicting the dropout variables at age 17 and using the mother_based and child_completed_11 data as predictors
dropout_17 = merge(merged_data_17, predictors_17)

print("dim of dropout 17")
#print(head(dropout_17))
print(dim(dropout_17))


save(mother_clean,child_completed_11_clean, dropout_17, file = "2-data-processing/RData_files/cleandatasets.RData")

