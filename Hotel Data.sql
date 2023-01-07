-- Merging FACT tables 2018, 2019, 2020 into one table (hotels) by creating a CTE 

with hotels AS (
SELECT * FROM dbo.[2018]
UNION
SELECT * FROM dbo.[2019]
UNION
SELECT * FROM dbo.[2020])

SELECT * FROM hotels

-- Calculating the Revenue per reservation by adding stays_in_weekend_nights and stays_in_week_nights then multiply the outcome with adr

with hotels AS (
SELECT * FROM dbo.[2018]
UNION
SELECT * FROM dbo.[2019]
UNION
SELECT * FROM dbo.[2020])

SELECT (stays_in_weekend_nights + stays_in_week_nights)* adr AS Revenue 
FROM hotels

-- Calculating Revenue per Year by hotel

with hotels AS (
SELECT * FROM dbo.[2018]
UNION
SELECT * FROM dbo.[2019]
UNION
SELECT * FROM dbo.[2020])

SELECT arrival_date_year, hotel, 
ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights)* adr),2) AS Revenue 
FROM hotels
GROUP BY arrival_date_year, hotel;

-- Joining hotels table with the market_segment and meal_cost tables

with hotels AS (
SELECT * FROM dbo.[2018]
UNION
SELECT * FROM dbo.[2019]
UNION
SELECT * FROM dbo.[2020])

SELECT * FROM hotels
LEFT JOIN dbo.market_segment
ON hotels.market_segment = market_segment.market_segment
LEFT JOIN dbo.meal_cost
ON meal_cost.meal = hotels.meal