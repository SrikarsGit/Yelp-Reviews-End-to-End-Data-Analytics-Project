# ![Yelp Logo](https://retailwire.com/wp-content/uploads/Yelp-Mojahid_Mottakin-Depositphotos.com_-1536x993.jpg) Yelp Reviews Sentiment & Behavior Analysis




## **Table Of Contents:**
1. [Project Overview](#project-overview)
2. [Tech Stack](#tech-stack)
3. [Dataset Description](#dataset-description)
4. [Entity Relationship Diagram](#entity-relationship-diagram)
5. [Schema & UDF Setup](#schema--udf-setup)
6. [Project Workflow](#project-workflow)
7. [Key Business Questions Solved](#key-business-questions-solved)
8. [Key Insights Generated](key-insights-generated)
9. [Skills Demonstrated](#skills-demonstrated)
10. [Screenshots](#screenshots)
11. [Conclusion](#conclusion)


## Project Overview

Analyzed over **7 million Yelp reviews** to uncover patterns in customer sentiment, user behavior, business performance, and regional trends — all using **SQL** and **Snowflake**. This project is built to demonstrate large-scale data analysis, UDF-based sentiment scoring, and behavioral trend discovery.


## Tech Stack

- **Python** – Splitting large JSON files for upload
- **Snowflake SQL** – Data modeling, transformation, and analysis
- **Snowflake UDF** – Python-based sentiment analysis with VADER
- **Draw.io** – Project workflow design


## Dataset Description

### `yelp_reviews`
- `business_id`, `user_id`, `review_date`, `review_text`, `review_stars`, `sentiment`

### `yelp_businesses`
- `business_id`, `business_name`, `city`, `state`, `postal_code`, `address`, `categories`, `stars`, `review_count`


## Entity Relationship Diagram
![image](https://github.com/user-attachments/assets/f261de94-7a38-4fe3-852d-0e2f95079465)


## Schema & UDF Setup

This project uses two main Snowflake tables created from raw JSON files:

### `yelp_reviews` Table

#### Source
- Raw review data was stored in a JSON file and uploaded into a Snowflake staging table named `yelp_reviews_json`.

#### Transformation
- The JSON structure was flattened using dot notation (`review_text:field`) and cast to appropriate types.
- A custom Snowflake UDF was used to assign sentiment labels based on review text.

#### Final Table: 
```sql
CREATE OR REPLACE TABLE yelp_reviews AS
SELECT 
  review_text:business_id::STRING AS business_id,
  review_text:date::DATE AS review_date,
  review_text:user_id::STRING AS user_id,
  review_text:stars::NUMBER AS review_stars,
  review_text:text::STRING AS review_text,
  analyze_sentiment(review_text:text::STRING) AS sentiment
FROM yelp_reviews_json;
```


### `yelp_businesses` Table

#### Source
- Business metadata was stored as JSON and uploaded to a staging table named yelp_businesses_json.

#### Transformation
- Each field was extracted from the business_text object and converted into appropriate types.

#### Final Table:
```sql
CREATE OR REPLACE TABLE yelp_businesses AS
SELECT 
  business_text:business_id::STRING AS business_id,
  business_text:name::STRING AS business_name,
  business_text:city::STRING AS city,
  business_text:postal_code::STRING AS postal_code,
  business_text:state::STRING AS state,
  business_text:address::STRING AS address,
  business_text:review_count::NUMBER AS review_count,
  business_text:stars::NUMBER AS stars,
  business_text:categories::STRING AS categories
FROM yelp_businesses_json;
```
### UDF Setup in Snowflake

A Python-based UDF was created inside Snowflake to assign sentiment (Positive, Neutral, Negative) to each review using VADER sentiment analysis.

![image](https://github.com/user-attachments/assets/4cbd10d4-5a6a-49d9-984a-845f0d4dae91)

This UDF was invoked directly inside the yelp_reviews table creation query.    


## Project Workflow

![project_workflow drawio (1)_page-0001](https://github.com/user-attachments/assets/d596133a-3bd6-43cc-baeb-1bfae0ec76bc)

| Step                 | Description                                                                               |
| -------------------- | ----------------------------------------------------------------------------------------- |
| **1. Raw Data**      | A large Yelp dataset (5GB JSON) containing reviews and businesses metadata.                 |
| **2. Preprocessing** | Python is used to split the data into 25 smaller files (200MB each) for easier ingestion. |
| **3. Upload**        | Data is loaded into Snowflake staging tables using the `VARIANT` type.                    |
| **4. Flattening**    | JSON fields are extracted and cast to appropriate SQL data types using `::`.              |
| **5. Final Tables**  | Two structured tables are created: `yelp_reviews` and `yelp_businesses`.                  |
| **6. Sentiment UDF** | A Snowflake UDF uses VADER to assign sentiment to each review.                            |
| **7. SQL Analysis**  | 20 analytical questions are answered using advanced SQL techniques and actionable insights are generated                   |


## Key Business Questions Solved

1. **Find the number of businesses in each category** 

2. **Identify the top 10 users who have reviewed the most businesses** in the "Restaurants" category.

3. **Determine the most popular business categories** based on the total number of reviews.

4. **Extract the top 3 most recent reviews for each business** using window functions.

5. **Find the month with the highest number of reviews** using date-based aggregation.

6. **Calculate the percentage of 5-star reviews for each business** to assess excellence.

7. **List the top 5 most reviewed businesses in each city** 

8. **Find businesses with at least 100 reviews and show their average rating** for reliability assessment.

9. **List the top 10 users with the most reviews** and show the businesses they reviewed.

10. **Identify the top 10 businesses with the highest number of positive sentiment reviews**.

11. **Find the top 50 businesses with the highest percentage of negative sentiment reviews**.

12. **Detect businesses with the most consistent ratings** by calculating the variance of review stars (with at least 100 reviews).

13. **Compute the average number of words per review for each business category** to analyze engagement depth.

14. **List cities with the most 1-star reviews** to identify areas of poor customer satisfaction.

15. **Identify “hidden gem” businesses** with high average ratings (≥ 4.8) and low review volume (20–25 reviews).

16. **Detect users who gave increasingly negative reviews to specific businesses** using correlation analysis over time.

17. **Compare sentiment distribution between weekdays and weekends** to understand behavior patterns.

18. **Analyze if users post longer reviews when they are unhappy**, comparing review lengths by sentiment.

19. **Find the top 10 states with the highest number of reviews**, and list the top 3 most popular business categories in each.

20. **Identify businesses that had great ratings initially but are now in decline**, based on yearly correlation of average ratings.


## Key Insights Generated

- The platform is heavily dominated by **Restaurants**, which make up over **52,000 businesses** — nearly **double** that of the second most saturated category, **Food** (**27.8K** businesses). Other saturated categories include **Shopping** (**24.4K**), **Home Services** (**14.4K**), and **Beauty & Spas** (**14.3K**), indicating strong competition in lifestyle-related sectors.
  
- Yelp user engagement is overwhelmingly concentrated in **food** and **entertainment**, with the **Restaurants** category alone accounting for over **4.7 million** reviews, followed by **Food**, **Nightlife**, and **Bars**, making up the majority of user activity across the platform.

- Yelp reviews peak during the summer months, with **July** leading at **65.4K** reviews, followed by August and June, indicating heightened customer engagement during vacation and travel seasons. In contrast, **November** and **December** see the fewest reviews, likely due to holiday distractions.

- Among businesses with at least **100** reviews, some achieve near-perfect customer satisfaction, with top performers like **Walls Jewelry Repairing** and **ella & louie flowers** having **100% five-star review** percentages, and others such as **Sustainable Wine Tours** and **Burgundy Blue Photography** exceeding **99%**. This highlights a segment of businesses excelling in delivering exceptional customer experiences. Conversely, some businesses rank at the bottom with five-star review percentages near zero, including **International Medical Group** and **City Place Hotel**, reflecting areas for significant service improvement. This wide variance underscores the importance of monitoring five-star review percentages as a critical customer satisfaction metric for business growth and reputation management.

- The top 10 businesses with the highest number of positive sentiment reviews demonstrate exceptionally strong customer satisfaction, with positive review percentages ranging from approximately **79%** to nearly **90%**. For example, **Luke and Commander's Palace** lead with around **89% positive sentiment** among thousands of reviews. This suggests that these businesses not only attract high volumes of reviews but also maintain consistently positive customer experiences, which can significantly enhance their brand reputation and customer loyalty.

- The top 100 businesses with the lowest variance in ratings have variances close to **0.00**, showing extremely consistent reviews—some even with zero variance (e.g.,**ella & louie flowers, Walls Jewelry Repairing**). This means customers almost always agree on the quality of these businesses. On the other hand, the bottom 100 businesses show variances as high as around **3.78**, indicating a wide spread in customer ratings and mixed experiences. Many of these are large service providers or dealerships where opinions vary greatly (e.g., **Apple Repair Shop with variance 3.78, Napleton Hyundai of Carmel with 3.68**).

- A total of **700+** businesses have received exceptionally high average ratings **(≥4.8)** from a limited number of reviews **(20–25)**. These may represent **“hidden gems”** — consistently delivering great experiences but still flying under the radar due to low visibility.

- It is discovered that negative reviews average **137.64 words—27.7%** longer than positive reviews (107.04 words) and **69.2%** longer than neutral reviews (81.32 words). This quantitative insight reveals customers invest significantly more effort explaining negative experiences, creating data-rich feedback opportunities. The **56-word** difference between negative and neutral reviews provides businesses with detailed, actionable information for targeted experience improvements.

- Identified **138** high-rated businesses with statistically significant rating decline using time-series SQL analysis; **22.5%** were restaurants, with notable regional clusters in **New Orleans (8.7%)** and **Tampa (6.5%)**, enabling early detection of service deterioration for targeted intervention.


## Skills Demonstrated

#### Technical Skills:

- **Advanced SQL (Window Functions, CTEs, Aggregations)**: Leveraged multi-layered SQL logic to conduct temporal trend analysis and identify declining performers.

- **UDF Development in Snowflake (VADER NLP)**: Built a custom User-Defined Function using VADER sentiment analysis directly within Snowflake to score and analyze review sentiment at scale—integrating natural language processing into cloud-based SQL pipelines.

- **Correlation & Trend Analysis**: Measured statistical relationships between time and star ratings to detect meaningful performance drops.

- **Data Cleaning & Transformation**: Pre-processed and structured unrefined Yelp review data for high-confidence insights.

- **Performance Optimization**: Ensured high-efficiency query performance across large datasets with minimal latency.

- **Predictive Modeling (Rule-Based)**: Engineered logic to flag businesses likely to face future reputation damage, enabling proactive resolution strategies.

 #### Analytical & Domain Skills:
 
- **Customer Sentiment Analysis**: Evaluated polarity shifts in customer language using VADER scores to complement numerical rating trends.

- **Time-Series Decomposition**: Separated historical performance into time-sensitive components to pinpoint periods of decline.

- **Segmented Market Insights**: Identified sector-specific (e.g., 22.5% restaurants) and geo-specific (e.g., 8.7% New Orleans) risk concentrations.

- **Root Cause Hypothesis Generation**: Combined rating and sentiment trend data to infer likely causes behind declining customer satisfaction.


## Screenshots 

This section provides the screenshots of few queries and the output generated by them in Snowflake

Query: 
![image](https://github.com/user-attachments/assets/2db6cc99-648a-4e61-b60c-d5777f01e2e0)

Output:
![image](https://github.com/user-attachments/assets/e105b367-12fd-4ef1-a870-ab1a480449cd)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Query:
![image](https://github.com/user-attachments/assets/cfa59f8a-9f28-4af1-9ed8-97e2490ba533)

Output:
![image](https://github.com/user-attachments/assets/8b456024-b7fa-4e04-b4d4-1b9b4be5f575)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Query: 
![image](https://github.com/user-attachments/assets/0010505e-5a8d-4452-84ed-a900582fdf14)

Output:
![image](https://github.com/user-attachments/assets/3849a71f-24d8-485f-b3ef-dc989ad71ba6)


## Conclusion

This project was a deep dive into uncovering meaningful business insights from Yelp’s review dataset using Snowflake. From building sentiment analysis UDFs with VADER to performing advanced SQL operations involving window functions, correlation analysis, and CTE chaining, I was able to identify reputation trends, regional patterns, and hidden gems across industries.

The most rewarding part was designing a scalable framework for detecting early signs of reputation decline—something that can be automated for real-time alerts. Equally satisfying was surfacing businesses with excellent ratings and low visibility, offering data-backed suggestions for potential market focus.

This end-to-end analysis not only sharpened my technical command of Snowflake and SQL but also strengthened my data storytelling and analytical thinking—skills I look forward to applying in business intelligence and analytics roles.






