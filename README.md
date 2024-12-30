# Movie Recommendation System

This project implements a **Movie Recommendation System** using collaborative filtering, content-based filtering, and hybrid algorithms to suggest movies based on user preferences. The backend is powered by R scripts, and a Streamlit web app serves as the frontend.

---

## **Overview**

Recommendation systems are critical for platforms like Netflix, Amazon Prime, and YouTube to personalize user experiences. This project combines multiple recommendation techniques to predict movies a user might enjoy based on their viewing history and preferences.

---

## **Features**

1. **Recommendation Algorithms**:
   - **User-Based Collaborative Filtering (UBCF)**:
     - Suggests movies based on user similarities.
   - **Item-Based Collaborative Filtering (IBCF)**:
     - Suggests movies based on movie similarities.
   - **Content-Based Filtering**:
     - Recommends movies with similar attributes (e.g., genres).
   - **Hybrid Recommendation**:
     - Combines UBCF, IBCF, and content-based techniques.

2. **Streamlit Web Interface**:
   - A simple and interactive interface for input and output.
   - Allows users to select algorithms, enter movie names, and specify the number of recommendations.

3. **Dynamic Outputs**:
   - Displays recommendations directly in the app.
   - Saves outputs as CSV files for offline analysis.

---

## **Dataset Information**

### **Dataset Source**
The dataset used in this project is available on the [UCI Machine Learning Repository](https://archive.ics.uci.edu/ml/datasets/movies). It contains anonymized data about user demographics, movie ratings, and genres.

### **Dataset Structure**
- **Users**:
  - Includes demographic details like age and gender.
- **Movies**:
  - Includes metadata such as genre, release year, and title.
- **Ratings**:
  - User ratings on a 1–5 scale for various movies.

### **Features**
| **Feature**      | **Description**                                  |
|-------------------|--------------------------------------------------|
| `user_id`         | Unique identifier for users                     |
| `movie_id`        | Unique identifier for movies                    |
| `rating`          | Rating given by the user (1–5 scale)            |
| `timestamp`       | Date and time of the rating                     |
| `genres`          | Genre(s) of the movie                           |
| `title`           | Movie title                                     |

---

## **Setup Instructions**

### **1. Prerequisites**
- **Python** (>= 3.7) and **R** (>= 4.3.3).
- Install Python libraries:
  ```bash
  pip install streamlit pandas
  
### **2. Install R libraries**
- install.packages(c("recommenderlab", "dplyr", "reshape2", "proxy"))
  
### **3. Run the index.py**
- streamlit run index.py
