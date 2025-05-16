create or replace function analyze_sentiment(text STRING)
returns STRING
language PYTHON
runtime_version = '3.8'
packages = ('vaderSentiment')
handler = 'sentiment_analyzer'
as 
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