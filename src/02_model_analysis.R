# Purpose: DATA ORCHESTRATION (In-memory SQL with RSQLite), EDA, visualization, and predictive modeling (Random Forest).

# --- 1. PACKAGE CONFIGURATION AND INSTALLATION ---

# List of all necessary packages
packages_needed <- c("readr", "dplyr", "ggplot2", "tidyr", "randomForest", "DBI", "RSQLite", "magrittr")

# Robust function to install and load the package
install_if_missing <- function(p) {
  # Check if the package is not installed
  if (!require(p, character.only = TRUE)) {
    message(paste("Installing package:", p))
    install.packages(p, dependencies = TRUE)
  }
}

# 1.1 Execute package installation if missing
invisible(sapply(packages_needed, install_if_missing))

# 1.2 Load all installed packages at once
message("Loading all necessary packages...")
invisible(sapply(packages_needed, library, character.only = TRUE))


# --- 2. DATA ORCHESTRATION (ETL Simulation with RSQLite) ---

# Connect to a temporary in-memory SQLite database
conn <- dbConnect(RSQLite::SQLite(), ":memory:")
print("In-memory SQLite connection established (BD server simulation).")

# 2.1 Load the original CSV into R and then into the SQLite database
file_path <- "../Airbnb_Open_Data.csv" 
df_raw <- suppressMessages(read_csv(file_path))

# The raw CSV table is loaded into the 'airbnb_raw' table in SQLite
dbWriteTable(conn, "airbnb_raw", df_raw, overwrite = TRUE)
print("Raw data loaded into the 'airbnb_raw' SQLite table.")

# 2.2 Execute the SQL cleaning and transformation script (01_data_cleaning.sql logic)
# The SQL script content is executed directly on the SQLite database.
dbExecute(conn, "
    CREATE TABLE airbnb_clean AS
    SELECT
        CAST(id AS INTEGER) AS id,
        NAME AS name,
        CAST(\"host id\" AS INTEGER) AS host_id,
        \"neighbourhood group\" AS neighbourhood_group,
        CAST(lat AS REAL) AS latitude,
        CAST(long AS REAL) AS longitude,
        \"room type\" AS room_type,
        CAST(\"Construction year\" AS REAL) AS construction_year,
        CAST(REPLACE(REPLACE(price, '$', ''), ',', '') AS REAL) AS nightly_price,
        CAST(REPLACE(REPLACE(\"service fee\", '$', ''), ',', '') AS REAL) AS service_fee,
        CAST(\"minimum nights\" AS REAL) AS minimum_nights,
        CAST(\"number of reviews\" AS REAL) AS number_of_reviews,
        CAST(\"reviews per month\" AS REAL) AS reviews_per_month,
        CAST(\"availability 365\" AS REAL) AS availability_365
    FROM
        airbnb_raw
    WHERE
        CAST(REPLACE(REPLACE(price, '$', ''), ',', '') AS REAL) > 10 AND
        CAST(\"minimum nights\" AS REAL) < 366;
")

print("ETL Phase (SQL) completed. 'airbnb_clean' table created in SQLite.")

# 2.3 Load clean data from the database into R
query_select_all <- "SELECT * FROM airbnb_clean;"
df_clean <- dbGetQuery(conn, query_select_all)

# Disconnect from the database
dbDisconnect(conn)
print("SQLite Disconnection. Clean Data Frame loaded into R.")

# --- 3. FINAL PREPROCESSING IN R ---

# Convert categorical variables to factors for the model
df_clean <- df_clean %>%
  # Impute NAs in 'reviews_per_month' with 0 (if any remain)
  replace_na(list(reviews_per_month = 0)) %>% 
  # Convert categorical variables to factors
  mutate(
    neighbourhood_group = as.factor(neighbourhood_group),
    room_type = as.factor(room_type)
  )

print("Summary of key variables after cleaning:")
print(summary(df_clean$nightly_price))

# --- 4. EXPLORATORY DATA ANALYSIS (EDA) AND VISUALIZATION ---

# A. Price Distribution by Neighbourhood Group (Borough)
print("Generating Plot: Price Distribution by Borough")
ggplot(df_clean, aes(x = neighbourhood_group, y = nightly_price, fill = neighbourhood_group)) +
  geom_boxplot() +
  scale_y_log10() + # Use log scale to handle price skewness
  labs(
    title = "Logarithmic Price Distribution by NYC Borough",
    x = "Borough",
    y = "Nightly Price (Log Scale)"
  ) +
  theme_minimal()

# B. Geographic Price Map (Sampling for performance)
print("Generating Plot: Geographic Distribution of Listings")
df_sample_geo <- sample_n(df_clean, 10000) # Sample 10k points for faster plotting

ggplot(df_sample_geo, aes(x = longitude, y = latitude, color = nightly_price)) +
  geom_point(alpha = 0.5) +
  scale_color_gradient(low = "yellow", high = "red") +
  labs(
    title = "Geographic Distribution and Price of Airbnb in NYC",
    x = "Longitude",
    y = "Latitude",
    color = "Price"
  ) +
  theme_void()

# C. VALUE-ADDED PLOT: Relationship between Reviews and Price, colored by Room Type
print("Generating Plot: Price vs. Reviews by Room Type")
# Use a smaller sample for this detailed scatter plot
df_sample_reviews <- sample_n(df_clean, 5000) 

ggplot(df_sample_reviews, aes(x = number_of_reviews, y = nightly_price, color = room_type)) +
  geom_point(alpha = 0.5) +
  scale_y_log10() +
  geom_smooth(method = "lm", se = FALSE) + # Add simple linear trend line
  labs(
    title = "Price vs. Reviews: Impact of Room Type",
    x = "Number of Reviews",
    y = "Nightly Price (Log Scale)",
    color = "Room Type"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

# --- 5. PREDICTIVE MODELING (RANDOM FOREST) ---

# STRATEGY FOR SPEED: Sample the clean data for faster model training
# We use 20,000 observations for model stability and speed, instead of the full dataset.
df_model_sample <- sample_n(df_clean, 20000)

# Selection of variables for the model
features <- df_model_sample %>%
  select(nightly_price, latitude, longitude, room_type, neighbourhood_group, minimum_nights, number_of_reviews)

# Final handling of NAs (if any remain, they are removed for the simple model)
features <- na.omit(features)

# Data Split into Training (80%) and Test (20%) sets
set.seed(42) # For reproducibility
train_index <- sample(nrow(features), 0.8 * nrow(features))
train_data <- features[train_index, ]
test_data <- features[-train_index, ]

print(paste("Training Random Forest model on a sample of", nrow(train_data), "observations..."))

# Training the Random Forest model
# 'ntree=50' is used for speed; in production, higher values would be used
rf_model <- randomForest(
  nightly_price ~ latitude + longitude + room_type + neighbourhood_group + minimum_nights + number_of_reviews,
  data = train_data,
  ntree = 50, # Reduced trees for speed
  mtry = 3,
  importance = TRUE
)

# 6. MODEL EVALUATION
predictions <- predict(rf_model, test_data)

# Calculate RMSE (Root Mean Squared Error)
rmse <- sqrt(mean((predictions - test_data$nightly_price)^2))

print("--- MODEL RESULTS ---")
cat(sprintf("RMSE (Root Mean Squared Error) on test data: $%.2f\n", rmse))

# Variable Importance Visualization
print("Variable Importance in Prediction:")
print(importance(rf_model))
varImpPlot(rf_model)