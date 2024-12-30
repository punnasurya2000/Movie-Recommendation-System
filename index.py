import streamlit as st
import subprocess
import pandas as pd

# Streamlit App Title
st.title("Movie Recommendation System")

# Dropdown for algorithm choice
algorithm = st.selectbox(
    "Choose a recommendation algorithm:",
    [
        "User-Based Collaborative Filtering (UBCF)",
        "Item-Based Collaborative Filtering (IBCF)",
        "Content-Based Filtering",
        "Hybrid Recommendation System (Recommended)"
    ],
    index=3
)

# Input for movie name and number of recommendations
movie_name = st.text_input("Enter the movie names: (seperated with semicolon)")
top_n = st.number_input("Number of recommendations:", min_value=1, max_value=20, value=5)

if st.button("Get Recommendations"):
    movie_name=';'.join([i.strip() for i in movie_name.split(';')])
    print(movie_name)
    if not algorithm:
        st.warning("Please select a recommendation algorithm.")
    else:
        try:
            # Map selected algorithm to corresponding R script and output file
            if algorithm == "User-Based Collaborative Filtering (UBCF)":
                script_name = "ubcf_2.R"
                output_file = "UBCF_Recommendations.csv"
            elif algorithm == "Item-Based Collaborative Filtering (IBCF)":
                script_name = "ibcf_2.R"
                output_file = "IBCF_Recommendations.csv"
            elif algorithm == "Content-Based Filtering":
                script_name = "content_based.R"
                output_file = "ContentBased_Recommendations.csv"
            elif algorithm == "Hybrid Recommendation System":
                script_name = "hybrid.R"
                output_file = "Hybrid_Recommendations.csv"
            else:
                st.error("Invalid algorithm selection.")
                raise ValueError("Invalid algorithm selection.")
            print(["C:\\Program Files\\R\\R-4.3.3\\bin\\Rscript.exe", script_name, str(movie_name), str(top_n)])
            # Call the R script with arguments
            result = subprocess.run(
                ["C:\\Program Files\\R\\R-4.3.3\\bin\\Rscript.exe", script_name, movie_name, str(top_n)],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            # Check for errors
            if result.returncode != 0:
                st.error(f"Error running {algorithm}: {result.stderr}")
            else:
                # Read and display the recommendations
                recommendations = pd.read_csv(output_file)
                st.write(f"Recommendations from {algorithm}:")
                st.write(result)
                st.table(recommendations)
        except Exception as e:
            st.error(f"An exception occurred: {e}")
