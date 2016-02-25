require 'spec_helper'
require 'ostruct'

describe DeskPlatformRpt::TopTweets do
  let(:top_tweets) { DeskPlatformRpt::TopTweets.new }

  describe '#add_tweet' do
    it 'adds a tweet to the tweets_hash' do
      tweet = OpenStruct.new(timestamp: 1234, hash_tags: %w(#hi #mom))
      top_tweets.add_tweet(tweet)

      expect(top_tweets.tweets_hash.size).to eq 1
      expect(top_tweets.tweets_hash[tweet.timestamp]).to match_array %w(#hi #mom)
    end
  end

  describe '#top_10_tweets_in_last_60_seconds' do
    it 'returns the top 10 tweets from the last 60 seconds'
  end
end
