# Building and Evaluating the Rabdom forest model to predict the study dropout at age 17

# Identify zero-variance predictors
zero.var.features =  nearZeroVar(dropout_17, saveMetrics= TRUE)

# Print the zero variance features
print(zero.var.features[zero.var.features$zeroVar == TRUE, ])

# if the zero variance is TRUE it means all the values are same
# such values donot add any informative value for a predictive model, 
#as they don't contribute to the variance in the dependent variable. 
#Therefore, they can be removed from the dataset before further analysis or modelling.
# Find names of zero-variance variables
zero_var_names <- rownames(zero.var.features[zero.var.features$zeroVar == TRUE, ])

dropout_17_clean = dropout_17[, !names(dropout_17) %in% zero_var_names]

# imputing missing values by median and mode with na.roughfix()
dropout_17_roughfix = na.roughfix(dropout_17_clean)
dropout_17_clean = dropout_17_roughfix
sum(is.na(dropout_17_clean))

# We have questionnaire_dropout and clinic_dropout as the response and all the other variables in the mother_clean as predictors
# Omit specific predictors
predictors <- names(dropout_17_clean)[!names(dropout_17_clean) %in% c("questionnaire_dropout", "clinic_dropout")]

set.seed(123)  # for reproducibility

outcomes <- c("questionnaire_dropout", "clinic_dropout")

# Cross-validation control
control <- trainControl(method="cv",
                        number=10,
                        classProbs=TRUE,
                        summaryFunction=twoClassSummary,
                        savePredictions = "final")
metric <- "ROC"
# Initialize a list to hold the average Shapley values for both outcomes
avg_shapley_values_list <- list()

# set the timestamp
start.time <- Sys.time()

for(outcome in outcomes) {
  print(paste("Model for", outcome))

  # Make sure the outcome is a factor
  dropout_17_clean[[outcome]] <- as.factor(dropout_17_clean[[outcome]])

  # Combine predictors and outcome to create the formula
  formula <- as.formula(paste(outcome, "~", paste(predictors, collapse="+")))
  
  print("model building start")
  # Train the model using the training set
  model <- train(formula, data=dropout_17_clean, method="rf", metric=metric, trControl=control)

  # Print the results
  print(model)
  print("model building completed")

  print("plotting the ROC curve")

  # Collect probabilities and true outcomes from each fold
  prob_list <- lapply(model$pred, function(x) x[, outcome])
  true_list <- lapply(model$pred, function(x) x$obs)

  # Plot each fold's ROC curve
  gg <- ggplot()
  for (i in seq_along(prob_list)) {
    # Create a ROC curve for the i-th fold
    fold_roc <- roc(true_list[[i]], prob_list[[i]], positive = "0")

    # Compute the AUC for the i-th fold
    fold_auc <- auc(fold_roc)

    # Print the ROC and AUC values for the i-th fold
    print(paste("ROC for fold", i, ":"))
    print(fold_roc)
    print(paste("AUC for fold", i, ":", fold_auc))

    # Add the ROC curve to the plot
    gg <- gg + geom_line(data = as.data.frame(fold_roc),
                         aes(x = 1 - Specificity, y = Sensitivity, color = paste("Fold", i, "AUC:", round(auc(fold_roc), 2))),
                         linetype = i)

    # Optional: Add a point and label for the sensitivity and specificity at the optimal threshold
    coords <- coords(fold_roc, "best")
    gg <- gg + geom_point(aes(x = 1 - coords["specificity"], y = coords["sensitivity"]), size = 3)
    gg <- gg + annotate("text", x = 1 - coords["specificity"], y = coords["sensitivity"],
               label = paste("Sens:", round(coords["sensitivity"], 2), "Spec:", round(coords["specificity"], 2)),
               hjust = -0.1, vjust = 1.5, size = 3)
  }
 
  # Add labels and reference line
  gg <- gg + labs(title = paste("ROC Curves for", outcome), x = "False Positive Rate", y = "True Positive Rate", color = "Fold")
  gg <- gg + geom_abline(intercept = 0, slope = 1, linetype = "dashed") # Reference line

  # Save the plot
  figure_path <- file.path(res_dir, "figures", "dropout_17","roc_curve", paste("ROC_Curves_for_", outcome, ".pdf", sep = ""))
  ggsave(figure_path, gg)
 
  print("Resampling Information")
  # Extract the resampling information
  resamples_info <- model$control$index

  # Extract and print the actual data points for each fold
  for (i in seq_along(resamples_info)) {
    cat("Data for Fold", i, ":\n")
    fold_data <- dropout_11_clean[resamples_info[[i]], ]
    print(summary(fold_data))
  } 

  # Compute Shapley values for each fold
  print("computing shapley values for each fold")

  shapley_values_list <- lapply(seq_along(model$pred), function(i) {
    fold_pred <- model$pred[model$pred$Resample == unique(model$pred$Resample)[i], ]
    predictor <- Predictor$new(model$finalModel, data = fold_pred[, predictors, drop=FALSE], y = fold_pred$obs)
    explainer <- Shapley$new(predictor)
    shapley_values <- explainer$explain(fold_pred[, predictors, drop=FALSE])

    # Print the Shapley values for the current fold
    print(paste("Shapley values for fold", i))
    print(shapley_values)

   # Plot Shapley values for the current fold
    shapley_plot <- plot(shapley_values)

    # Define the path to save the plot
    shapley_plot_path <- file.path(res_dir, "figures", "dropout_17", "shapley_values",
                                   paste("Shapley_Values_for_Fold_", i, "_", outcome, ".pdf", sep = ""))

    # Save the plot
    ggsave(shapley_plot_path, shapley_plot)


    return(shapley_values)
  })
  # Average the Shapley values across folds
  avg_shapley_values <- Reduce('+', shapley_values_list) / length(shapley_values_list)

  # Inside your loop over outcomes, save the average Shapley values to the list
  avg_shapley_values_list[[outcome]] <- avg_shapley_values

  # Plot the averaged Shapley values
  avg_shapley_plot <- plot(avg_shapley_values)

  # Define the path to save the plot
  avg_shapley_plot_path <- file.path(res_dir, "figures", "dropout_17","shapley_values_avg",
                                     paste("Shapley_Values_for_", outcome, ".pdf", sep = ""))

  # Save the plot
  ggsave(avg_shapley_plot_path, avg_shapley_plot)

}

# create a plot to compare the average Shapley values
avg_questionnaire_shapley <- avg_shapley_values_list[["questionnaire_dropout"]]
avg_clinic_shapley <- avg_shapley_values_list[["clinic_dropout"]]

# Combine the two sets of Shapley values into a single data frame
comparison_data <- data.frame(
  Feature = names(avg_questionnaire_shapley),
  Questionnaire = unlist(avg_questionnaire_shapley),
  Clinic = unlist(avg_clinic_shapley)
)

# Plot the comparison
ggplot(comparison_data, aes(x = Questionnaire, y = Clinic)) +
  geom_point() +
  geom_text(aes(label = Feature), vjust = -1) +
  labs(x = "Questionnaire Dropout Shapley Values",
       y = "Clinic Dropout Shapley Values",
       title = "Comparison of Average Shapley Values")

# Define the path to save the plot
comparison_plot_path <- file.path(res_dir, "figures", "dropout_17","shapley_values_avg",
                                  "Shapley_Values_Combined.pdf")
# Save the plot
ggsave(comparison_plot_path, comparison_plot)

end.time <- Sys.time()
time.taken <- end.time - start.time
print(time.taken)

