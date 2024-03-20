# applying a filter to restrict our data to the core sample
mother_based = mother_based %>% filter(preg_in_core == 1 | is.na(preg_in_core))

# retrieving the labels of all variables in the mother dataset
all_labels_mother = get_labels(mother_based)

# retrieving the levels of all variables in the mother dataset
all_levels_mother = get_levels(mother_based)

# creating a new dataframe for the cleaned dataset
mother_clean = mother_based
print(head(mother_clean))

# using zap_labels to remove value labels (from labelled class objects)
# lapply() to apply the zap_labels to each element 
mother_clean = lapply(mother_clean, zap_labels)
# the output of lapply is a list, so converting the list to dataframe
mother_clean = as.data.frame(mother_clean)

# finding columns with -9999 value which represents Consent withdrawn
cols_with_minus9999 = mother_clean %>% summarize_all(function(x) any(x == -9999, na.rm = TRUE)) %>%
     gather(key = "column", value = "contains_minus9999") %>%
     filter(contains_minus9999) %>%
     pull(column)
print(cols_with_minus9999)

# replacing values -3 with NA for all columns
# replacing values -1,-4,-7 with NA for all columns except for the column dw040 : residual weight
# replacing values -2 with NA for all columns except for the columns dw040 and mz005m
# mz005m : Multiple pregnancy identifier for Mothers with >1 pregnancy in ALSPAC , where -2 represents Mother only has 1 pregnancy in ALSPAC sample
# So, for 'dw040', it keeps -1, -2, -4, and -7, while 'mz005m' only keeps -2.
# For the rest of the columns, all these values (-1, -2, -3, -4, -7, -10, -11) are replaced with NA.

for (colname in names(mother_clean)) {
  if (colname != 'dw040' && colname != 'mz005m') {
    mother_clean[[colname]] <- ifelse(mother_clean[[colname]] %in% c(-1, -2, -3, -4, -7, -10, -11), NA, mother_clean[[colname]])
  } else if (colname == 'mz005m') {
    mother_clean[[colname]] <- ifelse(mother_clean[[colname]] %in% c(-1, -3, -4, -7, -10, -11), NA, mother_clean[[colname]])
  } else if (colname == 'dw040') {
    mother_clean[[colname]] <- ifelse(mother_clean[[colname]] %in% c(-3, -10, -11), NA, mother_clean[[colname]])
  }
}

# replacing value 9 with NA for the following columns
# label of 9 in these columns is "DK/Don't Know
cols_to_replace_9 <- c("b004", "b681", "dw034", "d385", "d395", paste0("d", 510:539), paste0("d", 560:589), "d704", "d711")
for (colname in cols_to_replace_9) {
   mother_clean[[colname]] <- ifelse(mother_clean[[colname]] == 9, NA, mother_clean[[colname]])
}

# replacing value 99 with NA for the column d791
# d791 : PTNR provides emotional support needed, 
# labels and values: 0 - Other; 1 - Exactly feel; 2 - Often feel; 3 - SMTS feel; 4 - Never feel; 99 - DK/Don't Know
mother_clean$d791 <- ifelse(mother_clean$d791 == 99, NA, mother_clean$d791) 

# identifying binary columns by checking the unique values:
# if a column has exactly three unique values (1, 2, and NA), it is considered a binary variable
binary_var_cols <- vector()
for (colname in names(mother_clean)) {
  if (length(unique(mother_clean[[colname]])) == 3 && all(sort(unique(mother_clean[[colname]], na.rm = TRUE)) %in% c(1, 2))) {
    binary_var_cols <- c(binary_var_cols, colname)
  }
}

# loop through each binary column
for (colname in binary_var_cols) {
  # convert to factor and label levels
  mother_clean[[colname]] <- factor(mother_clean[[colname]], 
                                    levels = c(1, 2))
}

mother_clean$preg_in_alsp <- as.factor(mother_clean$preg_in_alsp)
mother_clean$preg_in_core <- as.factor(mother_clean$preg_in_core)
mother_clean$preg_enrol_status <- as.factor(mother_clean$preg_enrol_status)
print("before nominal list")
print(dim(mother_clean))
# creating nominal_list for the nominal variables
# Variables with simple structure
nominal_list <- c(paste0("mz", c("013", "014")),
                  paste0("b", c("001", "024", "322", "323", "326", "327", "505", "510", "529", "663", 
                  "665", "667", "679", "683", "690", "724", "840")),
                  paste0("X._merge_", c("b_4f", "d_4b")),
                  paste0("dw", c("003", "033")),
                  paste0("d", c("001", "011", "032", "042", "080", "083", "086", "089", "092", "095", 
                        "098", "101", "104", "107", "110", "113", "116", "119", "122", "125", "128", 
                        "252", "254", "255", "2720", "389", "411", "490", "612", "810", "811", "812", "813")),
                  paste0("d", sprintf("%03d", 150:173)),   # For d150 to d173
                  paste0("d", sprintf("%03d", 274:277)),   # For d274 to d277
                  paste0("d", sprintf("%03d", 470:483)),   # For d470 to d483
                  paste0("d", sprintf("%03d", 590:602), "a"))  # For d590a to d602a


# converting the variables into factors and then creating binary variables for each level
#for (var in nominal_list) {
#  mother_clean[[var]] <- as.factor(mother_clean[[var]])
#  new_binary_vars = model.matrix(~mother_clean[[var]] - 1)
  
  # Extract the factor levels from the variable
#  factor_levels <- levels(mother_clean[[var]])
  
  # Change column names of new_binary_vars to include the original variable name and the factor level
#  colnames(new_binary_vars) <- paste0(var, "_", factor_levels)
  
#  if (nrow(new_binary_vars) < nrow(mother_clean)) {
#    missing_rows <- nrow(mother_clean) - nrow(new_binary_vars)
#    new_binary_vars = rbind(new_binary_vars, matrix(rep(NA, missing_rows * ncol(new_binary_vars)), nrow = missing_rows))
#  }
  
#  mother_clean = cbind(mother_clean, new_binary_vars)
#}
#rownames(mother_clean) <- 1:nrow(mother_clean)

# Initialize an empty vector to hold the names of the new variables
new_var_names <- c()

# converting the variables into factors and then creating binary variables for each level
for (var in nominal_list) {
  mother_clean[[var]] <- as.factor(mother_clean[[var]])
  new_binary_vars = model.matrix(~mother_clean[[var]] - 1)

  # Extract the factor levels from the variable
  factor_levels <- levels(mother_clean[[var]])

  # Change column names of new_binary_vars to include the original variable name and the factor level
  colnames(new_binary_vars) <- paste0(var, "_", factor_levels)
  
  # Append the new variable names to the vector
  new_var_names <- c(new_var_names, colnames(new_binary_vars))

  if (nrow(new_binary_vars) < nrow(mother_clean)) {
    missing_rows <- nrow(mother_clean) - nrow(new_binary_vars)
    new_binary_vars = rbind(new_binary_vars, matrix(rep(NA, missing_rows * ncol(new_binary_vars)), nrow = missing_rows))
  }
  mother_clean = cbind(mother_clean, new_binary_vars)
}

for (col in new_var_names) {
  mother_clean[[col]] <- factor(mother_clean[[col]], levels = c(0, 1))
}

rownames(mother_clean) <- 1:nrow(mother_clean)


# Now, we will remove the original variables from 'nominal_list'
mother_clean <- mother_clean[, setdiff(colnames(mother_clean), nominal_list)]

#head(mother_clean)
print("After nominal")
print(dim(mother_clean))
# creating the ordinal list
ordinal_list <- c("b029", "b031","b130", "b160","b310", "b320", "b321", "b502","b612", "b619", "b636","b652", "b658","b685", "b692","b730", "b801", "b803", 
               paste0("b", sprintf("%03d", 40:42)), paste0("b", sprintf("%03d", seq(43, 67, by=2))),
               paste0("b", sprintf("%03d", seq(71, 83, by=2))), paste0("b", seq(100, 128, by=2)), 
               paste0("b", seq(170, 174)),paste0("b", seq(301, 303)),paste0("b", seq(328, 350)),
               paste0("b", seq(360, 369)),paste0("b", seq(375, 381)),paste0("b", seq(386, 392)),
               paste0("b", seq(397, 403)),paste0("b", seq(408, 414)),paste0("b", seq(517, 522)),
               paste0("b", seq(525, 527)),paste0("b", seq(570, 610)),paste0("b", seq(630, 633)),
               paste0("b", seq(640, 644)),paste0("b", seq(669, 671)),paste0("b", seq(700, 702)),
               paste0("b", seq(706, 713)),paste0("b", seq(720, 723)),paste0("b", seq(810, 819)),
               paste0("b", seq(822, 831)),paste0("b", seq(850, 861)),paste0("b", seq(880, 915)),
               "d010a", "d022", "dw034","d250", "d251", "d260", "d261","d376","d614","d755","d770", "d771","d815",
               paste0("d", seq(200, 208)),paste0("d", seq(360, 368)),
               paste0("d", seq(400, 405)),paste0("d", seq(700, 712)), 
               paste0("d", seq(750, 753)),paste0("d", seq(760, 763)), 
               paste0("d", seq(773, 779)),paste0("d", seq(790, 799)))

# using the ordered() to make the ordinal variables in the dataset
for (var in ordinal_list) {
  if(var %in% names(mother_clean)) {
    mother_clean[[var]] <- ordered(mother_clean[[var]])
  } else {
    print(paste("Variable", var, "is not present in the dataset."))
  }
} 

print(unique(mother_clean$b031))


# making the month variables into ordered variables
# b922 : month of questionnaire completion 
# d992 : month of questionnaire completion 

# Creating ordered factor for months
month_levels <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

mother_clean$b922 <- ordered(factor(mother_clean$b922, levels = 1:12, labels = month_levels), 
                             levels = month_levels)

mother_clean$d992 <- ordered(factor(mother_clean$d992, levels = 1:12, labels = month_levels), 
                             levels = month_levels)

# making the year variable into 19XX format
# b923 : year of questionnaire completion
# d993 : year of questionnaire completion
# Adding 1900 to transform the year variables
# updating the non-NA values in b923 and d993 that are greater than or equal to 90

# For b923
non_na_b923 <- !is.na(mother_clean$b923)
mother_clean$b923[non_na_b923 & mother_clean$b923 >= 90] <- mother_clean$b923[non_na_b923 & mother_clean$b923 >= 90] + 1900

# For d993
non_na_d993 <- !is.na(mother_clean$d993)
mother_clean$d993[non_na_d993 & mother_clean$d993 >= 90] <- mother_clean$d993[non_na_d993 & mother_clean$d993 >= 90] + 1900
print("after all the preprocessing")
print(dim(mother_clean))

save(mother_clean,file = "2-data-processing/RData_files/cleandatasets.RData") 
