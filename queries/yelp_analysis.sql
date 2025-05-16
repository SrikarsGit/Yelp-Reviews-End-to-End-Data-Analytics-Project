--20 Business Questions 

--view tables
SELECT * FROM yelp_reviews LIMIT 100;
SELECT * FROM yelp_businesses LIMIT 100;


--1. Find number of businesses in each category 

--splitting the categories column into corresponding rows & grouping the newly created Category column
--to find number of businesses in each category

SELECT TRIM(value) AS category, COUNT(business_id) AS num_businesses
FROM yelp_businesses, LATERAL split_to_table(REPLACE(categories, ', &', ','), ',')
GROUP BY category
ORDER BY num_businesses DESC


--2. Find the top 10 users who have reviewed the most businesses in the "Restaurants" category

SELECT yr.user_id, COUNT(DISTINCT yr.business_id) AS num_reviewed_businesses  
FROM yelp_reviews yr INNER JOIN yelp_businesses yb
     ON yr.business_id = yb.business_id
WHERE yb.categories ILIKE '%restaurant%'
GROUP BY yr.user_id
ORDER BY num_reviewed_businesses DESC
LIMIT 10


--3. Find the most popular categories of businesses (based on the number of reviews)

WITH business_categories AS(
    SELECT business_id, business_name, TRIM(value) AS category
    FROM yelp_businesses, LATERAL split_to_table(REPLACE(categories, ', &', ','), ',')
)
SELECT category, COUNT(*) AS number_of_reviews
FROM   yelp_reviews yr INNER JOIN business_categories bc
       ON yr.business_id  = bc.business_id
GROUP BY category
ORDER BY number_of_reviews DESC


--4. Find the top 3 most recent reviews for each business.

WITH recent_reviews AS(
    SELECT yr.business_id, yb.business_name, yr.review_date, yr.review_text,
           ROW_NUMBER() OVER(PARTITION BY yr.business_id ORDER BY yr.review_date DESC) AS top_recent_reviews 
    FROM yelp_reviews yr INNER JOIN yelp_businesses yb
           ON yr.business_id = yb.business_id  
)
SELECT business_id, business_name, review_date, review_text 
FROM recent_reviews
WHERE top_recent_reviews <= 3
ORDER BY business_name

--5 Find the month with the highest number of reviews

SELECT MONTHNAME(review_date) AS month, COUNT(*) AS number_of_reviews
FROM yelp_reviews
GROUP BY month
ORDER BY number_of_reviews DESC

--6. Find the percentage of 5-star reviews for businesses with atleast 100 reviews

SELECT yr.business_id, yb.business_name, 
       ROUND(SUM(CASE WHEN yr.review_stars  = 5 THEN 1 ELSE 0 END) * 100 / COUNT(*), 3) AS five_star_review_percentage
FROM yelp_reviews yr INNER JOIN yelp_businesses yb
       ON yr.business_id = yb.business_id
GROUP BY yr.business_id, yb.business_name
HAVING COUNT(*) >= 100
ORDER BY five_star_review_percentage ASC
LIMIT 100
--7 Find the top 5 most reviewed businesses in each city

WITH city_wise_business_reviews AS(
    SELECT yb.city, yr.business_id, yb.business_name, COUNT(*) AS total_reviews
    FROM yelp_reviews yr INNER JOIN yelp_businesses yb
           ON yr.business_id = yb.business_id
    GROUP BY 1, 2, 3
)

SELECT city, business_id, business_name, total_reviews
FROM   city_wise_business_reviews
QUALIFY ROW_NUMBER() OVER(PARTITION BY city ORDER BY total_reviews DESC) <= 5 


--8. Find the average rating of businesses that have atleast 100 reviews.

SELECT yr.business_id, yb.business_name, 
       AVG(yr.review_stars) AS average_rating
FROM yelp_reviews yr INNER JOIN yelp_businesses yb
     ON yr.business_id = yb.business_id
GROUP BY yr.business_id, yb.business_name
HAVING COUNT(*) >= 100
ORDER BY yr.business_id, yb.business_name


--9. List the top 10 users who have written the most reviews, along with the businesses they reviewed.

WITH top10_users_with_most_reviews AS(
    SELECT user_id, COUNT(*) total_reviews
    FROM yelp_reviews 
    GROUP BY user_id
    ORDER BY total_reviews DESC
    LIMIT 10
),
businesses_reviewed AS(
    SELECT DISTINCT yr.user_id, yr.business_id, yb.business_name
    FROM yelp_reviews yr INNER JOIN yelp_businesses yb
           ON yr.business_id = yb.business_id
    WHERE yr.user_id IN (SELECT user_id FROM top10_users_with_most_reviews)
)
SELECT br.user_id, br.business_id,br.business_name, ur.total_reviews
FROM businesses_reviewed br INNER JOIN top10_users_with_most_reviews ur
       ON br.user_id = ur.user_id
ORDER BY ur.total_reviews DESC

--10. Find the top 10 businesses with highest positive sentiment reviews

SELECT yr.business_id, yb.business_name, 
       COUNT(*) AS total_reviews,
       SUM(CASE WHEN yr.sentiment = 'Positive' THEN 1 ELSE 0 END) AS positive_sentiment_reviews,
       ROUND(positive_sentiment_reviews * 100 / total_reviews, 2) AS positive_sentiment_percentage
FROM yelp_reviews yr INNER JOIN yelp_businesses yb
       ON yr.business_id = yb.business_id
GROUP BY yr.business_id, yb.business_name
ORDER BY positive_sentiment_reviews DESC
LIMIT 10


--11. Find the top 50 businesses with highest negative sentiment review percentage

SELECT yr.business_id, yb.business_name, 
       SUM(CASE WHEN yr.sentiment = 'Negative' THEN 1 ELSE 0 END) AS total_negative_reviews,
       COUNT(*) AS total_reviews,
       ROUND(total_negative_reviews * 100 / total_reviews, 2) AS negative_sentiment_percentage
FROM yelp_reviews yr INNER JOIN yelp_businesses yb
       ON yr.business_id = yb.business_id
GROUP BY yr.business_id, yb.business_name
ORDER BY negative_sentiment_percentage DESC
LIMIT 50

--12. Identify businesses with the most consistent ratings with atleast 100 reviews (lowest variance in review stars)

SELECT yr.business_id, yb.business_name, 
       VARIANCE(yr.review_stars) AS variance_in_ratings
FROM yelp_reviews yr INNER JOIN yelp_businesses yb
       ON yr.business_id = yb.business_id
GROUP BY yr.business_id, yb.business_name
HAVING COUNT(*) >= 100
ORDER BY variance_in_ratings ASC
LIMIT 100


--13. Determine the average words in reviews per category

WITH business_categories AS(
    SELECT business_id, business_name, TRIM(value) AS category,
    FROM yelp_businesses, LATERAL split_to_table(REPLACE(categories, ', &', ','), ',')
)
SELECT bc.category,
       COUNT(*) AS total_reviews,
       ROUND(AVG(ARRAY_SIZE(SPLIT(TRIM(yr.review_text), ' '))), 2) AS average_review_length_words   
FROM business_categories bc INNER JOIN yelp_reviews yr
       ON bc.business_id = yr.business_id
GROUP BY bc.category


-- 14. Find cities with the most 1-star reviews

SELECT yb.city, 
       SUM(CASE WHEN yr.review_stars = 1 THEN 1 ELSE 0 END) AS total_1star_reviews
FROM yelp_reviews yr INNER JOIN yelp_businesses yb
       ON yr.business_id = yb.business_id
GROUP BY yb.city
ORDER BY total_1star_reviews DESC


-- 15.  Find businesses with high average rating but very few reviews, i.e, 20 to 25 reviews (potential "hidden gems")

SELECT yr.business_id, yb.business_name, ROUND(AVG(yr.review_stars), 2) as avg_rating
FROM yelp_reviews yr INNER JOIN yelp_businesses yb
       ON yr.business_id = yb.business_id
GROUP BY yr.business_id, yb.business_name
HAVING COUNT(*) BETWEEN 20 AND 25 AND ROUND(AVG(yr.review_stars), 2) >= 4.8
ORDER BY avg_rating DESC 


-- 16. Are there users who gave increasingly negative reviews to a specific business?

WITH scored_reviews AS(
    SELECT user_id, business_id, review_date,
           CASE 
                WHEN sentiment = 'Positive' THEN 1 
                WHEN sentiment = 'Neutral' THEN 0
                ELSE -1 
           END 
           AS sentiment_score
    FROM yelp_reviews
),
review_sequence AS (
    SELECT user_id, business_id, review_date, sentiment_score,
           ROW_NUMBER() OVER(PARTITION BY  user_id, business_id ORDER BY review_date) AS rn
    FROM scored_reviews
),
trend_analysis AS (
    SELECT user_id, business_id,
           CORR(rn, sentiment_score) AS correlation,
           COUNT(*) AS total_reviews
    FROM review_sequence
    GROUP BY user_id, business_id
    HAVING CORR(rn, sentiment_score) < 0 AND COUNT(*) > 3
)

SELECT ta.user_id, ta.business_id, yb.business_name, total_reviews, ta.correlation 
FROM trend_analysis ta LEFT JOIN yelp_businesses yb 
     ON ta.business_id = yb.business_id
WHERE ta.correlation < -0.5
ORDER BY ABS(ta.correlation) DESC


-- 17. Do users post more positive reviews on weekends and more negative ones on weekdays?

WITH weekly_review_analysis AS (
    SELECT 
        DAYOFWEEK(review_date) AS day_of_week,
        DAYNAME(review_date) AS day_name,
        CASE
            WHEN day_of_week BETWEEN 1 AND 5 THEN 'weekday'
            ELSE 'weekend'
        END AS week_type,
        sentiment
    FROM yelp_reviews
)

SELECT week_type,
       SUM(CASE WHEN sentiment = 'Positive' THEN 1 ELSE 0 END) AS positive_sentiment_count,
       SUM(CASE WHEN sentiment = 'Negative' THEN 1 ELSE 0 END) AS negative_sentiment_count,
       ROUND(positive_sentiment_count / negative_sentiment_count, 2) AS positive_to_negative_sentiment_ratio 
FROM weekly_review_analysis
GROUP BY week_type


--18. Do users post longer reviews when they’re unhappy?

SELECT sentiment, ROUND(AVG(ARRAY_SIZE(SPLIT(TRIM(review_text), ' '))), 2) as avg_no_of_words
FROM yelp_reviews
GROUP BY sentiment


--19. What are the top 10 states with the highest number of reviews, and the top 3 most popular business categories in each of those states?

WITH regional_hotspots AS (
    SELECT business_id, state, TRIM(value) AS category
    FROM yelp_businesses, LATERAL split_to_table(REPLACE(categories, ', &', ','), ',')
),
 state_wise_review_volume AS (
    SELECT rh.state, COUNT(*) AS total_reviews, 
    FROM yelp_reviews yr INNER JOIN regional_hotspots rh
         ON yr.business_id = rh.business_id
    GROUP BY rh.state
),
top10_states_by_review_volume AS (
    SELECT *,  ROW_NUMBER() OVER(ORDER BY total_reviews DESC) AS rn
    FROM state_wise_review_volume
    QUALIFY rn <= 10
 ),
state_wise_categories AS (
    SELECT rh.state, rh.category, COUNT(*) AS total_reviews_per_category
    FROM yelp_reviews yr INNER JOIN regional_hotspots rh
         ON yr.business_id = rh.business_id
    GROUP BY rh.state, rh.category
    ORDER BY rh.state
)

SELECT s.state, s.category, s.total_reviews_per_category 
FROM state_wise_categories s INNER JOIN top10_states_by_review_volume ts
     ON s.state = ts.state
QUALIFY DENSE_RANK() OVER(PARTITION BY s.state ORDER BY s.total_reviews_per_category DESC) <= 3
ORDER BY ts.rn


--20. Find businesses that used to have great ratings but are now declining in review quality (reputation slipping over time) 

-- Thresholds: avg rating - 4.5, min reviews- 80 


WITH yearly_avg_rating AS (
    SELECT business_id, YEAR(review_date) AS review_year, AVG(review_stars) as avg_rating, COUNT(*) AS total_reviews
    FROM yelp_reviews
    GROUP BY business_id, review_year
    HAVING COUNT(*) > 80
),
 business_yearly_analysis AS (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY business_id ORDER BY review_year) AS year_index
    FROM yearly_avg_rating
 ),
 highly_rated_businesses_inititally AS (
    SELECT * FROM business_yearly_analysis
    WHERE avg_rating >= 4.5 AND year_index = 1
 ),
 declining_review_quality AS (
    SELECT business_id,  
           CORR(year_index, avg_rating) AS correlation
    FROM business_yearly_analysis
    WHERE business_id IN (SELECT business_id FROM highly_rated_businesses_inititally)
    GROUP BY business_id
    HAVING correlation < 0
 )
 SELECT drq.business_id, yb.business_name 
 FROM declining_review_quality drq LEFT JOIN yelp_businesses yb
      ON drq.business_id = yb.business_id




