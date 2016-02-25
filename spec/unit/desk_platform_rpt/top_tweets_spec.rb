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
    it 'returns the top 10 tweets from the last 60 seconds' do
      # Low timestamps that we will assert are missing
      top_tweets.add_tweet(OpenStruct.new(timestamp: 0, hash_tags: %w(#hi #mom)))

      # For each number n, add n tags to the hash_tags array
      # The top tags will be #9, #8, #7...
      hash_tags = (0..9).flat_map { |i| ("#{i}" * (i + 1)).split('') }.map {|i| "##{i}" }
      # Create the tweets w/in the 60 second window
      (1..61).each do |i|
        top_tweets.add_tweet(OpenStruct.new(timestamp: i, hash_tags: hash_tags))
      end
      expected_top_tweets = top_tweets.top_10_tweets_in_last_60_seconds(61)

      expect(expected_top_tweets).to eq %w(#9 #8 #7 #6 #5 #4 #3 #2 #1 #0)
    end
  end
end
