# Defining the outcome variable for dropout at age 11 using the child_completed and focus_11 datasets

# applying a filter to restrict our data to the core sample
child_completed = child_completed %>% filter(in_core == 1 | is.na(in_core))
focus_11 = focus_11 %>% filter(in_core == 1 | is.na(in_core))	

# retrieving the labels of all variables in child_completed and focus_11 datasets
all_labels_child_completed = get_labels(child_completed)
all_labels_focus_11 = get_labels(focus_11)

# retrieving the levels of all variables in the child_completed and focus_11 dataset
all_levels_child_completed = get_levels(child_completed)
all_levels_focus_11 = get_levels(focus_11)

# defining the outcome variable for child_completed dataset using "ccj007"
# ccj007(Questionnaire completed (as of 30/04/08)) has values 1,2,-2, 9999
# 1: Questionnaire Completed; 
# 2: Questionnaire not completed; 
# -2: Questionnaire not sent; -9999 : consent withdrawn

# outcome variable "questionnaire_dropout" is 0 refers to questionnaire completed(No Dropout)
# 1 refers to questionnaire not completed(dropout)
child_completed$questionnaire_dropout <- ifelse(child_completed$ccj007 == 1, 0, 1) 
child_completed$questionnaire_dropout <- factor(child_completed$questionnaire_dropout, 
                                        levels = c(0, 1), 
                                        labels = c("No_Dropout", "Dropout"))

# defining outcome variable for F11 Clinic visit dataset using "fe002"
# fe002(Year of F11+ Visit)
# outcome variable "clinic_dropout" is 0  refers to attended clinic(No dropout), 
# 1 refers to not attended the clinic(dropout)
focus_11$clinic_dropout = ifelse(!is.na(focus_11$fe002), 0, 1)
focus_11$clinic_dropout <- factor(focus_11$clinic_dropout, 
                                  levels = c(0, 1), 
                                  labels = c("No_Dropout", "Dropout"))

# Select only "cidB4303" and "questionnaire_dropout" from child_completed
child_completed_subset = child_completed[, c("cidB4303", "questionnaire_dropout")]
# removing any duplicates
child_completed_subset = child_completed_subset[!duplicated(child_completed_subset$cidB4303), ]

# Select only "cidB4303" and "clinic_dropout" from focus_11
focus_11_subset = focus_11[, c("cidB4303", "clinic_dropout")]
# removing any duplicates
focus_11_subset = focus_11_subset[!duplicated(focus_11_subset$cidB4303), ]

# merging the datasets
merged_data <- merge(child_completed_subset, focus_11_subset, by = "cidB4303")

## creating a dataset for predicting the dropout variable at age 11 and using the mother_based data as predictors

# merging with mother_clean 
dropout_11 = merge(merged_data, mother_clean , by = "cidB4303")

print(head(dropout_11))
print(dim(dropout_11))

# Building and Evaluating the Rabdom forest model to predict the study dropout at age 11

# Identify zero-variance predictors
zero.var.features =  nearZeroVar(dropout_11, saveMetrics= TRUE)

# Print the zero variance features
print(zero.var.features[zero.var.features$zeroVar == TRUE, ])

# if the zero variance is TRUE it means all the values are same
# such values donot add any informative value for a predictive model, 
#as they don't contribute to the variance in the dependent variable. 
#Therefore, they can be removed from the dataset before further analysis or modelling.
# Find names of zero-variance variables
zero_var_names <- rownames(zero.var.features[zero.var.features$zeroVar == TRUE, ])

dropout_11_clean = dropout_11[, !names(dropout_11) %in% zero_var_names]

# imputing missing values by median and mode with na.roughfix()
dropout_11_roughfix = na.roughfix(dropout_11_clean)
dropout_11_clean = dropout_11_roughfix
sum(is.na(dropout_11_clean))

save(mother_clean, dropout_11,dropout_11_clean, file = "2-data-processing/RData_files/cleandatasets.RData")
