predictors <- names(dropout_11_clean)[!names(dropout_11_clean) %in% c( "questionnaire_dropout", "clinic_dropout")]

# Randomly sample 100 predictors from the potential predictors
set.seed(123)  # for reproducibility

# Define the outcome
outcome <- "questionnaire_dropout"

# Cross-validation control
control <- trainControl(method="cv",
                        number=10,
                        classProbs=TRUE,
                        summaryFunction=twoClassSummary,
                        savePredictions = "final")
metric <- "ROC"

# set the timestamp
start.time <- Sys.time()

print(paste("Model for", outcome))

# Make sure the outcome is a factor
dropout_11_clean[[outcome]] <- as.factor(dropout_11_clean[[outcome]])

# Combine predictors and outcome to create the formula
formula <- as.formula(paste(outcome, "~", paste(predictors, collapse="+")))
print("model building start")

# Train the model using the training set
model_questionnaire <- train(formula, data=dropout_11_clean, method="rf", metric=metric, trControl=control)

# Print the results
print(model_questionnaire)
print("model building completed")

# Save the model
saveRDS(model_questionnaire, file="3-analysis/RData_files/model_questionnaire.rds")

# Plotting the ROC curve
prob_list <- model_questionnaire$pred$Dropout
true_list <- model_questionnaire$pred$obs
fold_indices <- split(seq_along(model_questionnaire$pred$Resample), model_questionnaire$pred$Resample)
# Define the path to the PDF file
figure_path <- file.path(res_dir, "figures", "dropout_11", "roc_curve", paste("ROC_Curves_for_", outcome, ".pdf", sep = ""))

all_roc_coords <- data.frame()

# Loop over the folds
for (i in seq_along(fold_indices)) {
    indices <- fold_indices[[i]]
    fold_probs <- prob_list[indices]
    fold_obs <- true_list[indices]
    fold_roc <- roc(fold_obs, fold_probs, positive = "Dropout")
    fold_auc <- auc(fold_roc)

    # Extract the coordinates of the ROC curve
    fold_roc_coords <- data.frame(Specificity = fold_roc$specificities,
                                   Sensitivity = fold_roc$sensitivities,
                                   Fold = paste("Fold", i, "AUC:", round(fold_auc, 2)))

    # Append to the overall data frame
     all_roc_coords <- rbind(all_roc_coords, fold_roc_coords)
    # Print the ROC and AUC values for the i-th fold
     print(paste("ROC for fold", i, ":"))
     print(fold_roc)
     print(paste("AUC for fold", i, ":", fold_auc))
}

# Create a single plot for all folds
gg_all_folds <- ggplot(all_roc_coords, aes(x = 1 - Specificity, y = Sensitivity, color = Fold)) +
     geom_line() +
     labs(title = paste("ROC Curve for All Folds of", outcome), x = "1 - Specificity", y = "Sensitivity") +
     geom_abline(intercept = 0, slope = 1, linetype = "dashed") # Reference line

# Open the PDF graphics device
pdf(figure_path, width = 7, height = 7)

# Print the plot to the PDF file
print(gg_all_folds)

# Close the PDF graphics device
dev.off()


print("Resampling Information")

# Loop over the folds
for (i in seq_along(fold_indices)) {
    indices <- fold_indices[[i]]

    # Print the fold number
    print(paste("Fold", i, ":"))

    # Print summary statistics for this fold
    print(summary(dropout_11_clean[indices, "questionnaire_dropout"])) # Replace with the column name for the dropout outcome

    # Print the actual data points for this fold (optional)
    # print(dropout_11_clean[indices, ])
}

# Check for overlaps between folds (optional)
for (i in seq_along(fold_indices)) {
    for (j in seq_along(fold_indices)) {
        if (i != j) {
            overlap <- intersect(fold_indices[[i]], fold_indices[[j]])
            if (length(overlap) > 0) {
                print(paste("Overlap between fold", i, "and fold", j, ":", paste(overlap, collapse = ", ")))
            }
        }
    }
}

end.time <- Sys.time()
time.taken <- end.time - start.time
print(time.taken)


