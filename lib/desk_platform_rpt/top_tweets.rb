module DeskPlatformRpt
  class TopTweets

    def initialize
      @tweets_hash = {}
      @lock = Mutex.new
    end

    def add_tweet(tweet)
      @lock.synchronize do
        unless @tweets_hash.key?(tweet.timestamp)
          @tweets_hash[tweet.timestamp] = []
        end
        @tweets_hash[tweet.timestamp] << tweet.hash_tags
        puts "========top tweet hash tags!!"
        @tweets_hash
      end
    end

    def top_10_tweets_in_last_60_seconds
      @tweets_hash
    end
  end
end
