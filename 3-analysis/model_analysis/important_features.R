# Clinic Dropout Important Features

model_clinic = readRDS("3-analysis/RData_files/model_clinic.rds")

print(model_clinic)

# Extract the random forest model
rf_model_clinic <- model_clinic$finalModel

importance_measures_clinic <- measure_importance(rf_model_clinic)

print(head(importance_measures_clinic))

important_by_gini_clinic <- importance_measures_clinic[order(-importance_measures_clinic$gini_decrease), ]

print(head(important_by_gini_clinic))

# Sort by mean_min_depth
important_by_depth_clinic <- importance_measures_clinic[order(importance_measures_clinic$mean_min_depth), ]

# Compare the top variables by gini_decrease and mean_min_depth
top_by_gini_clinic <- head(important_by_gini_clinic$variable)
top_by_depth_clinic <- head(important_by_depth_clinic$variable)

# Check the overlap
overlap_clinic <- intersect(top_by_gini_clinic, top_by_depth_clinic)
print(overlap_clinic)

# Convert the 'variable' column to a factor with levels in the current order
important_by_gini_clinic$variable <- factor(important_by_gini_clinic$variable, levels = important_by_gini_clinic$variable)

# Add a new column 'group' based on the starting letters
important_by_gini_clinic$group <- ifelse(grepl("^(b)", important_by_gini_clinic$variable), "Group B",
                                  ifelse(grepl("^(d)", important_by_gini_clinic$variable), "Group D",
                                  ifelse(grepl("^(m)", important_by_gini_clinic$variable), "Group M", "Others")))

# Subset the data for the top 100 variables
top_100_important_by_gini_clinic <- important_by_gini_clinic[1:100, ]

# Questionnaire Dropout Important features
model_questionnaire = readRDS("3-analysis/RData_files/model_questionnaire.rds")

print(model_questionnaire)

# Extract the random forest model
rf_model_questionnaire <- model_questionnaire$finalModel

importance_measures_questionnaire <- measure_importance(rf_model_questionnaire)

print(head(importance_measures_questionnaire))

important_by_gini_questionnaire <- importance_measures_questionnaire[order(-importance_measures_questionnaire$gini_decrease), ]

print(head(important_by_gini_questionnaire))

# Sort by mean_min_depth
important_by_depth_questionnaire <- importance_measures_questionnaire[order(importance_measures_questionnaire$mean_min_depth), ]

# Compare the top variables by gini_decrease and mean_min_depth
top_by_gini_questionnaire <- head(important_by_gini_questionnaire$variable)
top_by_depth_questionnaire <- head(important_by_depth_questionnaire$variable)

# Check the overlap
overlap_questionnaire <- intersect(top_by_gini_questionnaire, top_by_depth_questionnaire)
print(overlap_questionnaire)

# Convert the 'variable' column to a factor with levels in the current order
important_by_gini_questionnaire$variable <- factor(important_by_gini_questionnaire$variable, levels = important_by_gini_questionnaire$variable)

# Add a new column 'group' based on the starting letters
important_by_gini_questionnaire$group <- ifelse(grepl("^(b)", important_by_gini_questionnaire$variable), "Group B",
                                  ifelse(grepl("^(d)", important_by_gini_questionnaire$variable), "Group D",
                                  ifelse(grepl("^(m)", important_by_gini_questionnaire$variable), "Group M", "Others")))

# Subset the data for the top 100 variables
top_100_important_by_gini_questionnaire <- important_by_gini_questionnaire[1:100, ]

# Merge the important features by Gini decrease for clinic and questionnaire
combined_importance <- merge(important_by_gini_clinic[, c("variable", "gini_decrease")],
                             important_by_gini_questionnaire[, c("variable", "gini_decrease")],
                             by = "variable",
                             suffixes = c("_clinic", "_questionnaire"))

# Define custom labels for the groups
group_labels <- c("Group B" = "b_4f: Having a baby and your home and Lifestyle",
                  "Group M" = "mz_6a: Mother cohort profile",
                  "Group D" = "d_4b: About yourself",
                  "Others" = "Others")

# Creating the scatter plot for all the combined importance features
plot_gini_comparison <- ggplot(combined_importance, aes(x = gini_decrease_clinic, y = gini_decrease_questionnaire)) +
  geom_point(aes(color = ifelse(grepl("^(b)", variable), "Group B",
                                  ifelse(grepl("^(d)", variable), "Group D",
                                  ifelse(grepl("^(m)", variable), "Group M", "Others"))))) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "black") +
  labs(title = "Comparison of Importance by Gini Decrease (Clinic vs Questionnaire)",
       x = "Gini Decrease (Clinic)",
       y = "Gini Decrease (Questionnaire)") +
       scale_color_manual(name = "Group", values = c("Group B" = "blue", "Group D" = "red", "Group M" = "green", "Others" = "grey"), 
       labels = group_labels) +
       theme(legend.text = element_text(size = 8))

# save the plot
figure_path_comparison <- file.path(res_dir, "figures", "plots_imp", "Comparison_Importance_Gini.pdf")
ggsave(filename = figure_path_comparison, plot = plot_gini_comparison, width = 10, height = 10)

# order the combined_importance by gini decrease using both clinic and questionnaire
combined_importance_ordered <- combined_importance[order(-combined_importance$gini_decrease_clinic,
 -combined_importance$gini_decrease_questionnaire),]
print(head(combined_importance_ordered))

# top 10% of the predictors based on Gini decrease values.
# Calculate the 90th percentile threshold for both clinic and questionnaire Gini decrease values
threshold_clinic <- quantile(combined_importance_ordered$gini_decrease_clinic, 0.9)
threshold_questionnaire <- quantile(combined_importance_ordered$gini_decrease_questionnaire, 0.9)

# Filter the combined importance data frame to retain only the features above the thresholds
top_10_percent_predictors <- combined_importance_ordered[
  combined_importance_ordered$gini_decrease_clinic > threshold_clinic &
  combined_importance_ordered$gini_decrease_questionnaire > threshold_questionnaire,]

# Print the top 10% of predictors
print(top_10_percent_predictors)

# Calculate the number of top 10% features for each model
top_n_clinic <- ceiling(nrow(important_by_gini_clinic) * 0.1)
top_n_questionnaire <- ceiling(nrow(important_by_gini_questionnaire) * 0.1)

# Filter the top 10% of important features by Gini decrease for both models
top_by_gini_clinic_10percent <- head(important_by_gini_clinic, top_n_clinic)
top_by_gini_questionnaire_10percent <- head(important_by_gini_questionnaire, top_n_questionnaire)

# Merge the top 10% important features by Gini decrease for clinic and questionnaire
combined_importance_10percent <- merge(top_by_gini_clinic_10percent[, c("variable", "gini_decrease")],
                                       top_by_gini_questionnaire_10percent[, c("variable", "gini_decrease")],
                                       by = "variable",
                                       suffixes = c("_clinic", "_questionnaire"))

# Creating the scatter plot for top 10% important features
plot_gini_comparison_10percent <- ggplot(combined_importance_10percent, 
                                         aes(x = gini_decrease_clinic, y = gini_decrease_questionnaire)) +
  geom_point(aes(color = ifelse(grepl("^(b)", variable), "b_4f: Having a baby and your home and Lifestyle",
                                  ifelse(grepl("^(d)", variable), "d_4b: About yourself",
                                  ifelse(grepl("^(m)", variable), "mz_6a: Mother cohort profile", "Others"))))) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "black") +
  labs(title = "Comparison of Top 10% Important Features by Gini Decrease (Clinic vs Questionnaire)",
       x = "Gini Decrease (Clinic)",
       y = "Gini Decrease (Questionnaire)") +
  scale_color_manual(name = "Category",
                     values = c("b_4f: Having a baby and your home and Lifestyle" = "blue",
                                "d_4b: About yourself" = "red",
                                "mz_6a: Mother cohort profile" = "green",
                                "Others" = "grey")) +
  theme(legend.text = element_text(size = 8))

# Show the plot
print(plot_gini_comparison_10percent)

# save the plot
figure_path_comparison <- file.path(res_dir, "figures", "plots_imp", "Comparison_Importance_Gini_10percent.pdf")
ggsave(filename = figure_path_comparison, plot = plot_gini_comparison_10percent, width = 10, height = 6)


# Correlation Test
cor_test <- cor.test(combined_importance$gini_decrease_clinic, combined_importance$gini_decrease_questionnaire)
print(cor_test)

# Paired t-test
paired_t_test <- t.test(combined_importance$gini_decrease_clinic,
                         combined_importance$gini_decrease_questionnaire,
                         paired = TRUE)
print(paired_t_test)

logit_model_clinic = glm(clinic_dropout ~ b023 + d994 + mz028b + d290, data = dropout_11_clean, family = binomial)
summary(logit_model_clinic)

logit_model_questionnaire = glm(questionnaire_dropout ~ b023 + d994 + mz028b + d375 + b925, data = dropout_11_clean, family = binomial)
summary(logit_model_questionnaire)


