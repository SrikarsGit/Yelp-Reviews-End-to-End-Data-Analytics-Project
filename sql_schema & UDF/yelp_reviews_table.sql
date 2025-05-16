create or replace table yelp_reviews_json (review_text variant)

select COUNT(*) from yelp_reviews_json 

select * from yelp_reviews_json limit 10

create or replace table yelp_reviews as
select review_text:business_id::string as business_id,
       review_text:date::date as review_date,
       review_text:user_id::string as user_id,
       review_text:stars::number as review_stars,
       review_text:text::string as review_text,
       analyze_sentiment(review_text:text::string) as sentiment
from yelp_reviews_json

select count(*) from yelp_reviews

select * from yelp_reviews limit 10