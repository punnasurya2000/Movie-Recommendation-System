# Load required libraries
if (!requireNamespace("recommenderlab", quietly = TRUE)) {
  install.packages("recommenderlab")
}
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}
library(recommenderlab)
library(dplyr)

# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Please provide the number of recommendations and a comma-separated list of movie titles.")
}

# Extract arguments
top_n <- as.integer(args[2])  # Number of recommendations
movies_input <- strsplit(args[1], ";")[[1]] %>% trimws()  # Movie titles

if (is.na(top_n) || top_n <= 0) stop("Invalid number of recommendations.")
if (length(movies_input) == 0) stop("No movies provided.")

cat("Number of Recommendations:", top_n, "\n")
cat("Input Movies:", paste(movies_input, collapse = ", "), "\n")

# Load the dataset
cat("Loading dataset...\n")
data <- read.csv("stratified_sample.csv")
data <- head(data, 10000)  # Use a subset for efficiency

# Convert to realRatingMatrix
data_filtered <- data %>% select(userId, movieId, rating)
data_matrix <- as(data_filtered, "realRatingMatrix")

# Evaluation Scheme
cat("Creating evaluation scheme...\n")
set.seed(123)
evaluation_scheme <- evaluationScheme(data_matrix, method = "split", train = 0.8, given = 10, goodRating = 4)

# Create UBCF Model
cat("Training User-Based Collaborative Filtering (UBCF) model...\n")
ubcf_model <- Recommender(getData(evaluation_scheme, "train"), method = "UBCF")

# Make predictions and evaluate accuracy
cat("Evaluating UBCF model...\n")
predictions <- predict(ubcf_model, getData(evaluation_scheme, "known"), type = "ratings")
accuracy <- calcPredictionAccuracy(predictions, getData(evaluation_scheme, "unknown"))
cat("UBCF Model Accuracy (RMSE, MAE):\n")
print(accuracy)

# Evaluate Precision and Recall
evaluation_results <- evaluate(evaluation_scheme, method = "UBCF", type = "topNList", n = c(1, 3, 5, 10))
cat("Precision and Recall Metrics:\n")
print(avg(evaluation_results))

# Generate Recommendations for Specific Movies
cat("Generating recommendations for specific movies...\n")
input_movie_ids <- data %>% filter(title %in% movies_input) %>% select(movieId) %>% distinct() %>% pull(movieId)

if (length(input_movie_ids) > 0) {
  recommendations <- predict(ubcf_model, data_matrix[1], n = top_n)
  recommended_movie_ids <- as(recommendations, "list")[[1]]
  recommended_titles <- data %>% filter(movieId %in% recommended_movie_ids) %>% select(movieId, title) %>% distinct()
  cat("Recommendations:\n")
  print(recommended_titles)
  if (!is.null(recommended_titles)) {
    write.csv(recommended_titles, "UBCF_Recommendations.csv", row.names = FALSE)
} else {
    stop("No recommendations generated.")
}
} else {
  cat("None of the input movies were found in the dataset.\n")
}
