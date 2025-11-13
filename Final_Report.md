📋 Project Final Report: NYC Airbnb Price Predictor

🎯 Executive Summary

This project successfully implemented an end-to-end Data Science pipeline, connecting an ETL phase (SQL) with an analysis and modeling phase (R). The objective was to predict the Nightly Price of NYC Airbnb listings. The results confirm that Location (Latitude and Longitude) is, by a significant margin, the strongest predictor of price, followed closely by the listing's Popularity/Demand (Number of Reviews).

🚀 Data Strategy and ETL (SQL Phase)

The ETL process was designed to simulate data preparation in a relational database before analysis:

Ingestion: The raw CSV was loaded into a temporary SQLite table (airbnb_raw).

Cleaning (SQL - 01_data_cleaning.sql): This script handled:

Data Type Conversion: Crucially, removing $ and , from the price and service fee columns to convert them to numerical format (REAL).

Outlier Filtering: Filtering out errors, such as prices below $10 and minimum stay requirements exceeding one year.

Loading: The resulting clean data (airbnb_clean) was loaded back into R for downstream processing.

📊 Key Exploratory Data Analysis (EDA) Insights

The visualization step confirmed strong geographical and categorical dependencies on price.

4.1. Price Distribution by Borough (Boxplot)

[Aquí va la imagen del gráfico Boxplot de la distribución logarítmica del precio por distrito (Borough)]

Insight Clave: La distribución de precios muestra un sesgo significativo. Manhattan presenta la mediana más alta, validando su valor inmobiliario premium. La escala logarítmica es esencial para visualizar la distribución debido a los altos outliers.

4.2. Geographic Distribution and Price Map

[Aquí va la imagen del gráfico de Dispersión Geográfica de Precios (Latitud vs. Longitud)]

Insight Clave: La concentración de los puntos más caros (rojo intenso) se localiza principalmente en el centro de Manhattan, con una densidad más baja de precios altos en Brooklyn (zonas cercanas a Manhattan). Esto confirma visualmente que la ubicación es el principal impulsor del precio.

4.3. Price vs. Reviews by Room Type (Value-Added Insight)

![number_of_reviews](image.png)

Key Insight: A positive and significant correlation is observed for 'Entire home/apt' (entire apartments). Its trend line is the steepest, indicating that for the most expensive listings, greater popularity (more reviews) directly translates into a higher and more predictable price. The other room types show a nearly flat relationship.

🧠 Predictive Modeling and Interpretation (Random Forest)

To ensure rapid execution and stability for the portfolio presentation, the Random Forest model was trained on a 20,000-row sample of the cleaned data.

Metric

Value

Interpretation

Model

Random Forest (ntree=50)

A robust, non-linear model chosen for its high predictive power and ability to output feature importance.

Training Sample

20,000 Listings

A strategic subset used to ensure fast training time.

RMSE (Test Data)

$332.61

This dollar value represents the average prediction error on unseen data.

Analysis of High RMSE ($332.61)

The high RMSE value is primarily due to the extreme skewness and presence of high-value outliers (luxury listings, apartments with prices far exceeding the median) in the price distribution. Since the median price is much lower, a $332.61 error indicates that while the model captures the general trend, it struggles with the tail end of the distribution.

Improvement Note: A production-ready model would require additional feature engineering (e.g., transforming the price using a log scale for the model input) or filtering out the extreme price outliers to achieve a lower error rate.

Detailed Feature Importance (%IncMSE)

![rf_model](image-1.png)

Key Insight: The chart confirms that Longitude and Latitude are the variables with the highest %IncMSE (longest bar), meaning the model loses significant accuracy if geographic information is removed. Location is by far the most crucial factor.

Feature

%IncMSE (Impact on Error)

Interpretation & Business Implication

longitude

24.98%

Dominant Factor. A precise measure of east-west location is the single most important variable, highlighting that distance from key city centers dictates price.

latitude

24.01%

Highly Critical. Confirms the two geographical coordinates are the backbone of the price model.

number_of_reviews

20.99%

High Impact. Strong evidence that market demand and proven track record (popularity) play a vital role in pricing and price confidence.

minimum_nights

14.95%

Significant. Captures pricing strategies related to short-term versus extended stays.

room_type

14.72%

Essential Category. Defines the fundamental product offering (entire unit vs. single room).

neighbourhood_group

7.53%

Less Influential. The general borough information is superseded by the specific latitude and longitude values.

Next Steps for Improvement:
To minimize the RMSE further, future iterations should involve extensive hyperparameter tuning (e.g., mtry and ntree values) and experimentation with more performant algorithms, such as XGBoost, ideally on a distributed computing framework to handle the full dataset size efficiently.
