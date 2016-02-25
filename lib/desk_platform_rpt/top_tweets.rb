module DeskPlatformRpt
  class TopTweets

    def initialize
      @tweets_hash = Hash.new([])
      @lock = Mutex.new
    end

    def add_tweet(tweet)
      @lock.synchronize do
        @tweets_hash[tweet.timestamp] << tweet.hash_tags
        puts "========top tweet hash tags!!"
      end
    end

    def top_10_tweets_in_last_60_seconds
      @tweets_hash
    end
  end
end
