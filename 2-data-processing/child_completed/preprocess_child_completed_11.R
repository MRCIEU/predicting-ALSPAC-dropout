print("preprocessing of child_completed")
child_completed_11 = child_completed[, grepl("ccj", colnames(child_completed)) |
                                     !grepl("ccj|ccs|cp|YPD", colnames(child_completed))]

# applying a filter to restrict our data to the core sample
child_completed_11 = child_completed_11 %>% filter(in_core == 1 | is.na(in_core))

# retrieving the labels of all variables in child_completed and focus_11 datasets
all_labels_child_completed_11 = get_labels(child_completed_11)

# retrieving the levels of all variables in the child_completed and focus_11 dataset
all_levels_child_completed_11 = get_levels(child_completed_11)

# creating a new dataframe for the cleaned dataset
child_completed_11_clean = child_completed_11

# using zap_labels to remove value labels (from labelled class objects)
# lapply() to apply the zap_labels to each element 
child_completed_11_clean = lapply(child_completed_11_clean, zap_labels)
# the output of lapply is a list, so converting the list to dataframe
child_completed_11_clean = as.data.frame(child_completed_11_clean)

duplicates <- duplicated(child_completed_11_clean$cidB4303) | duplicated(child_completed_11_clean$cidB4303, fromLast = TRUE)
child_completed_11_clean <- child_completed_11_clean[!duplicates,]


# replacing -1, -2, -10 with NA; as they represent No response, Not completed, Not known, Questionnaire not sent
for (colname in names(child_completed_11_clean)) {
  child_completed_11_clean[[colname]] <- ifelse(child_completed_11_clean[[colname]] 
                                          %in% c(-1, -2, -10), NA, child_completed_11_clean[[colname]])
}

# identifying binary columns by checking the unique values:
# if a column has exactly three unique values (1, 2, and NA), it is considered a binary variable
binary_var_cols <- vector()
for (colname in names(child_completed_11_clean)) {
  if (length(unique(child_completed_11_clean[[colname]])) == 3 && all(sort(unique(child_completed_11_clean[[colname]], na.rm = TRUE)) %in% c(1, 2))) {
    binary_var_cols <- c(binary_var_cols, colname)
  }
}

# loop through each binary column
for (colname in binary_var_cols) {
  # convert to factor and label levels
  child_completed_11_clean[[colname]] <- factor(child_completed_11_clean[[colname]],
                                    levels = c(1, 2))
}

child_completed_11_clean = child_completed_11_clean %>% 
                           mutate_at(vars(ccj001, ccj007a), ~factor(., levels = c(1, 2)))

print("before nominal list")
print(dim(child_completed_11_clean))

# creating nominal_list for the nominal variables
# Variables with simple structure
nominal_list = c("ccj005", "ccj910", "ccj990c")

# Initialize an empty vector to hold the names of the new variables
new_var_names <- c()

# converting the variables into factors and then creating binary variables for each level
for (var in nominal_list) {
  child_completed_11_clean[[var]] <- as.factor(child_completed_11_clean[[var]])
  new_binary_vars = model.matrix(~child_completed_11_clean[[var]] - 1)

  # Extract the factor levels from the variable
  factor_levels <- levels(child_completed_11_clean[[var]])

  # Change column names of new_binary_vars to include the original variable name and the factor level
  colnames(new_binary_vars) <- paste0(var, "_", factor_levels)

  # Append the new variable names to the vector
  new_var_names <- c(new_var_names, colnames(new_binary_vars))

  if (nrow(new_binary_vars) < nrow(child_completed_11_clean)) {
    missing_rows <- nrow(child_completed_11_clean) - nrow(new_binary_vars)
    new_binary_vars = rbind(new_binary_vars, matrix(rep(NA, missing_rows * ncol(new_binary_vars)), nrow = missing_rows))
  }
  child_completed_11_clean = cbind(child_completed_11_clean, new_binary_vars)
}

for (col in new_var_names) {
  child_completed_11_clean[[col]] <- factor(child_completed_11_clean[[col]], levels = c(0, 1))
}

rownames(child_completed_11_clean) <- 1:nrow(child_completed_11_clean)

# Now, we will remove the original variables from 'nominal_list'
child_completed_11_clean <- child_completed_11_clean[, setdiff(colnames(child_completed_11_clean), nominal_list)]

print("After nominal")
print(dim(child_completed_11_clean))

# creating the ordinal list
ordinal_list <- c("ccj210","ccj230", "ccj990b",
                  paste0("ccj", sprintf("%03d", 100:107)), 
                  paste0("ccj", sprintf("%03d", 110:117)), 
                  paste0("ccj", sprintf("%03d", 120:123)), 
                  paste0("ccj", sprintf("%03d", 130:133)), 
                  paste0("ccj", sprintf("%03d", 140:147)), 
                  paste0("ccj", sprintf("%03d", 150:152)), 
                  paste0("ccj", sprintf("%03d", 160:164)), 
                  paste0("ccj", sprintf("%03d", 220:228)))

# using the ordered() to make the ordinal variables in the dataset
for (var in ordinal_list) {
  if(var %in% names(child_completed_11_clean)) {
    child_completed_11_clean[[var]] <- ordered(child_completed_11_clean[[var]])
  } else {
    print(paste("Variable", var, "is not present in the dataset."))
  }
}

print(unique(child_completed_11_clean$ccj101))

child_completed_11_clean = child_completed_11_clean %>% mutate_at(vars(paste0("ccj", 240:249), "X._merge_ccj_r1b", "ccj251", "ccj253", 
                                                                       paste0("ccj", 260), paste0("ccj", 262:265)), ~factor(.))

# making the month variables into ordered variables
# ccj990a: Date of completion of questionnaire - month
month_levels <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
child_completed_11_clean$ccj990a <- ordered(factor(child_completed_11_clean$ccj990a, levels = 1:12, labels = month_levels),
                             levels = month_levels)
save(child_completed_11_clean,file = "2-data-processing/RData_files/cleandatasets.RData")

