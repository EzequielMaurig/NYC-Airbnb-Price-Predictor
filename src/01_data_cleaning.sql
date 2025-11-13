-- File: 01_data_cleaning.sql
-- Purpose: Initial data cleaning of the Airbnb dataset for subsequent use in R.
-- We assume the original CSV has been loaded into a table named 'airbnb_raw'.

-- 1. Creation of a clean table to store processed data.
-- Define the correct data type (REAL/FLOAT) for monetary variables.
CREATE TABLE airbnb_clean (
    id INT,
    name VARCHAR(255),
    host_id INT,
    neighbourhood_group VARCHAR(50),
    latitude REAL,
    longitude REAL,
    room_type VARCHAR(50),
    construction_year REAL,
    nightly_price REAL,       -- Price converted to numeric
    service_fee REAL,         -- Service fee converted to numeric
    minimum_nights REAL,
    number_of_reviews REAL,
    reviews_per_month REAL,
    availability_365 REAL
);

-- 2. Data insertion with cleaning of monetary columns.
INSERT INTO airbnb_clean
SELECT
    CAST(id AS INT),
    NAME AS name,
    CAST("host id" AS INT) AS host_id,
    "neighbourhood group" AS neighbourhood_group,
    CAST(lat AS REAL) AS latitude,
    CAST(long AS REAL) AS longitude,
    "room type" AS room_type,
    CAST("Construction year" AS REAL) AS construction_year,

    -- Cleaning: Remove '$' and ',' from the 'price' column and cast to numeric.
    CAST(REPLACE(REPLACE(price, '$', ''), ',', '') AS REAL) AS nightly_price,

    -- Cleaning: Apply the same process to 'service fee'.
    CAST(REPLACE(REPLACE("service fee", '$', ''), ',', '') AS REAL) AS service_fee,

    CAST("minimum nights" AS REAL) AS minimum_nights,
    CAST("number of reviews" AS REAL) AS number_of_reviews,
    CAST("reviews per month" AS REAL) AS reviews_per_month,
    CAST("availability 365" AS REAL) AS availability_365
FROM
    airbnb_raw
-- 3. Filtering key Outliers before insertion (e.g., unrealistic prices or minimum nights).
WHERE
    CAST(REPLACE(REPLACE(price, '$', ''), ',', '') AS REAL) > 10 AND -- Filter out very low prices/errors
    CAST("minimum nights" AS REAL) < 366; -- Filter out stays longer than a year;

-- 4. Aggregation Query (Example of analysis handled well by SQL)
-- Calculate the average price per neighbourhood group (borough).
SELECT
    neighbourhood_group,
    AVG(nightly_price) AS average_price,
    COUNT(id) AS total_listings
FROM
    airbnb_clean
GROUP BY
    neighbourhood_group
ORDER BY
    average_price DESC;