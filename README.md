# ![Apple Logo](https://retailwire.com/wp-content/uploads/Yelp-Mojahid_Mottakin-Depositphotos.com_-1536x993.jpg) Yelp Reviews Sentiment & Behavior Analysis 

**Table Of Contents:**
1. [Project Overview](#project-overview)
2. [Tech Stack](#tech-stack)
3. [Dataset Description](#dataset-description)
4. [Entity Relationship Diagram](#entity-relationship-diagram)
5. [Schema & UDF Setup](#schema--udf-setup)
6. [Key Business Questions Solved](#key-business-questions-solved)
7. [Skills Demonstrated](#skills-demonstrated)
8. [Screenshots](#screenshots)
9. [Conclusion](#conclusion)


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

```sql
CREATE OR REPLACE FUNCTION analyze_sentiment(text STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('vaderSentiment')
HANDLER = 'sentiment_analyzer'
AS
$$
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
analyzer = SentimentIntensityAnalyzer()

def sentiment_analyzer(text):
    compound_score = analyzer.polarity_scores(text)['compound']
    if compound_score >= 0.6:
        return 'Positive'
    elif compound_score <= -0.6:
        return 'Negative'
    else:
        return 'Neutral'
$$;
```
This UDF was invoked directly inside the yelp_reviews table creation query.    









