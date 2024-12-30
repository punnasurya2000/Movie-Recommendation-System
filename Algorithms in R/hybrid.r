# Ensure the required libraries are installed and loaded
if (!requireNamespace("recommenderlab", quietly = TRUE)) {
  install.packages("recommenderlab")
}
if (!requireNamespace("reshape2", quietly = TRUE)) {
  install.packages("reshape2")
}
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}
if (!requireNamespace("proxy", quietly = TRUE)) {
  install.packages("proxy")
}

library(recommenderlab)
library(reshape2)
library(dplyr)
library(proxy)

# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 2) {
  stop("Please provide the number of recommendations and a comma-separated list of movie titles.")
}

# Extract number of recommendations and movie titles
top_n <- as.integer(args[2])
movies_input <- strsplit(args[1], ";")[[1]]
movies_input <- trimws(movies_input)  # Remove extra spaces

if (is.na(top_n) || top_n <= 0) {
  stop("Please provide a valid positive integer for the number of recommendations.")
}

cat("Number of Recommendations:", top_n, "\n")
cat("Input Movies:", paste(movies_input, collapse = ", "), "\n")

# Load the dataset
cat("Loading dataset...\n")
data <- read.csv("stratified_sample.csv")
data <- head(data, 10000)  # Use a subset for faster processing


# Prepare the rating matrix
cat("Preparing rating matrix...\n")
ratings_matrix <- dcast(data, userId ~ movieId, value.var = "rating")
ratings_matrix <- as(as.matrix(ratings_matrix[, -1]), "realRatingMatrix")

# Create collaborative filtering recommender models
cat("Creating recommender models...\n")
collab_ubcf_model <- Recommender(ratings_matrix, method = "UBCF")
collab_ibcf_model <- Recommender(ratings_matrix, method = "IBCF")

# Create content-based filtering using item features
cat("Calculating content similarity...\n")
item_features_matrix <- data %>% 
  select(movieId, genres) %>% 
  distinct() %>% 
  mutate(genres = as.factor(genres))
item_features_matrix <- as.data.frame(model.matrix(~ genres - 1, data = item_features_matrix))
rownames(item_features_matrix) <- item_features_matrix$movieId

content_similarity <- as.matrix(dist(item_features_matrix, method = "cosine"))

# Custom function for content-based recommendations
content_based_recommend <- function(movie_id, top_n = 5) {
  movie_index <- which(rownames(content_similarity) == as.character(movie_id))
  similarity_scores <- content_similarity[movie_index, ]
  recommended_indices <- order(similarity_scores, decreasing = FALSE)[2:(top_n + 1)]
  recommended_movie_ids <- rownames(content_similarity)[recommended_indices]
  return(recommended_movie_ids)
}

# Get movieIds for the input movies
cat("Mapping input movies to IDs...\n")
input_movie_ids <- data %>% 
  filter(title %in% movies_input) %>% 
  select(movieId) %>% 
  distinct() %>% 
  pull(movieId)

if (length(input_movie_ids) == 0) {
  stop("None of the input movies were found in the dataset.")
}

# Find users who rated the input movies
cat("Finding users who rated the input movies...\n")
users_who_rated_input_movies <- data %>% 
  filter(movieId %in% input_movie_ids) %>% 
  select(userId) %>% 
  distinct() %>% 
  pull(userId)

# Generate hybrid recommendations
cat("Generating recommendations...\n")
if (length(users_who_rated_input_movies) >= 5) {
  # Get the first 5 users
  user_ids <- users_who_rated_input_movies[1:5]
  recommendations_list <- list()
  
  for (i in 1:5) {
    user_id <- user_ids[i]
    ubcf_recommendations <- predict(collab_ubcf_model, ratings_matrix[user_id, ], n = top_n)
    ibcf_recommendations <- predict(collab_ibcf_model, ratings_matrix[user_id, ], n = top_n)
    content_recommendations <- content_based_recommend(input_movie_ids[1], top_n = top_n)
    
    # Combine UBCF, IBCF, and content-based recommendations
    hybrid_recommendations <- unique(c(
      as(ubcf_recommendations, "list")[[1]],
      as(ibcf_recommendations, "list")[[1]],
      content_recommendations
    ))
    recommendations_list[[i]] <- hybrid_recommendations
  }
  
  # Find common recommendations across all users
  common_movies <- Reduce(intersect, recommendations_list)
  
  # Final recommendations
  final_recommendation_ids <- c()
  if (length(common_movies) > 0) {
    final_recommendation_ids <- sample(common_movies, min(top_n, length(common_movies)))
  }
  
  if (length(final_recommendation_ids) < top_n) {
    remaining_count <- top_n - length(final_recommendation_ids)
    additional_movies <- unlist(recommendations_list) %>% unique() %>% setdiff(final_recommendation_ids)
    final_recommendation_ids <- c(
      final_recommendation_ids,
      sample(additional_movies, min(remaining_count, length(additional_movies)))
    )
  }
  
  # Get titles of final recommended movies
  final_recommended_titles <- data %>% 
    filter(movieId %in% final_recommendation_ids) %>% 
    select(movieId, title) %>% 
    distinct()
  
  # Print final recommendations
  cat("Final Recommendations:\n")
  print(final_recommended_titles)
  
} else if (length(users_who_rated_input_movies) > 0) {
  # Fallback for fewer than 5 users
  user_id <- users_who_rated_input_movies[1]
  ubcf_recommendations <- predict(collab_ubcf_model, ratings_matrix[user_id, ], n = top_n)
  ibcf_recommendations <- predict(collab_ibcf_model, ratings_matrix[user_id, ], n = top_n)
  content_recommendations <- content_based_recommend(input_movie_ids[1], top_n = top_n)
  
  hybrid_recommendations <- unique(c(
    as(ubcf_recommendations, "list")[[1]],
    as(ibcf_recommendations, "list")[[1]],
    content_recommendations
  ))
  
  recommended_titles <- data %>% 
    filter(movieId %in% hybrid_recommendations) %>% 
    select(movieId, title) %>% 
    distinct()
  
  cat("Fallback Recommendations:\n")
  print(recommended_titles)
  if (!is.null(recommended_titles)) {
    write.csv(recommended_titles, "Hybrid_Recommendations.csv", row.names = FALSE)
} else {
    stop("No recommendations generated.")
}
  
} else {
  cat("No users have rated the input movies. No recommendations can be generated.\n")
}
