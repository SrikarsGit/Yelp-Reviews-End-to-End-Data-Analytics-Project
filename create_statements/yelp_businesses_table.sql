create or replace table yelp_businesses_json (business_text variant)

select business_text from yelp_businesses_json limit 10

select COUNT(*) from yelp_businesses_json

select * from yelp_businesses_json limit 10

create or replace table yelp_businesses as
select business_text:business_id::string as business_id,
       business_text:name::string as business_name,
       business_text:city::string as city,
       business_text:postal_code::string as postal_code,
       business_text:state::string as state,
       business_text:address::string as address,
       business_text:review_count::number as review_count,
       business_text:stars::number as stars,
       business_text:categories::string as categories
from   yelp_businesses_json

select count(*) from yelp_businesses

select * from yelp_businesses limit 10
       