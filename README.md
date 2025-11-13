🏙️ NYC Airbnb Price Predictor: An End-to-End Data Science Pipeline

This project demonstrates a complete Data Science workflow, showcasing key skills in Data Engineering (SQL), Exploratory Data Analysis (R/ggplot2), and Predictive Modeling (R/Random Forest) using a large dataset of Airbnb listings in New York City.

The core objective is to identify the most significant factors driving listing prices and build a robust model to predict the nightly price.

⚙️ Project Architecture and Data Flow

The project is structured to separate concerns, mimicking a production environment:

ETL (SQL): The raw CSV is ingested into an in-memory SQLite database (orchestrated by R). A dedicated SQL script (src/01_data_cleaning.sql) handles data cleaning, type conversion (removing $, ,), and initial outlier filtering.

Analysis (R): The clean data is loaded back into R. The src/02_model_analysis.R script performs EDA, advanced visualization, and Machine Learning.

File

Language

Purpose

src/01_data_cleaning.sql

SQL

Data Cleaning, Type Conversion, and Outlier Filtering.

src/02_model_analysis.R

R

Data Orchestration, EDA, Visualization, Random Forest Model, and Evaluation.

final_report.md

Markdown

Executive summary, key findings, and interpretation of model results.

🔑 Key Findings & Model Performance

The predictive model (Random Forest) was optimized for speed using a 20,000-row sample.

1. Variable Importance (%IncMSE)

The model conclusively identified Location as the dominant factor for price prediction, outweighing all other features.

Feature

Importance Score

Interpretation

Longitude

24.98%

The single most important factor, reflecting proximity to high-value areas (e.g., central Manhattan).

Latitude

24.01%

Reinforces the importance of precise geographical location.

Number of Reviews

20.99%

A key indicator of property quality and demand; highly predictive of the price baseline.

Minimum Nights

14.95%

Reflects host strategy, influencing price predictability.

Room Type

14.72%

Fundamental categorization (e.g., Entire Home vs. Private Room).

Neighbourhood Group

7.53%

Lower importance, as the latitude and longitude variables already capture this geographical information with more granularity.

2. Model Evaluation (RMSE)

RMSE on Test Data: $XX.XX
(Please insert the actual RMSE value from your R script here.)

🛠 How to Reproduce

Clone the Repository and place the Airbnb_Open_Data.csv file in the main directory.

Open src/02_model_analysis.R in RStudio or VS Code.

Run the script, which will automatically:

Install and load all required packages (dplyr, RSQLite, randomForest, etc.).

Connect to SQLite and execute the SQL cleaning commands.

Run EDA (generating 3 plots).

Train the Random Forest model and print the final RMSE.
