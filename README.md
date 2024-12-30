# Movie Recommendation System

This project is designed to recommend movies to users using a combination of advanced recommendation algorithms. It implements User-Based Collaborative Filtering (UBCF), Item-Based Collaborative Filtering (IBCF), and Hybrid Recommendation Systems to predict user preferences and recommend movies accordingly. A web interface built with Streamlit enables users to interact with the system effortlessly.

---

## **Overview**

Recommendation systems are essential for personalization in applications like movie streaming platforms. This project uses collaborative filtering, content-based filtering, and hybrid models to suggest movies based on user preferences, past interactions, and movie features.

The project includes:
- **Backend**: R scripts for recommendation logic.
- **Frontend**: A Streamlit web app for user interaction.

---

## **Features**

1. **Recommendation Algorithms**:
   - **User-Based Collaborative Filtering (UBCF)**:
     - Suggests movies based on user similarity.
   - **Item-Based Collaborative Filtering (IBCF)**:
     - Suggests movies similar to those already watched.
   - **Hybrid Recommendation**:
     - Combines UBCF, IBCF, and content-based techniques.
   - **Content-Based Filtering**:
     - Recommends movies with similar attributes (e.g., genres).

2. **Streamlit Web Interface**:
   - User-friendly interface for input and output.
   - Allows users to select algorithms, input movie names, and specify the number of recommendations.

3. **Dynamic Outputs**:
   - Recommendations are displayed in the app and saved as CSV files.

---

## **Folder Structure**

```plaintext
.
├── index.py                # Main Streamlit app
├── hybrid.R                # Hybrid recommendation logic
├── ibcf_2.R                # Item-Based Collaborative Filtering logic
├── ubcf_2.R                # User-Based Collaborative Filtering logic
├── stratified_sample.csv   # Movie dataset (not provided here)
├── README.md               # Documentation
