module DeskPlatformRpt
  class TopTweets

    attr_reader :tweets_hash

    def initialize
      @tweets_hash = {}
      @lock = Mutex.new
    end

    def reset
      @tweets_hash.clear
    end

    def add_tweet(tweet)
      @lock.synchronize do
        unless @tweets_hash.key?(tweet.timestamp)
          @tweets_hash[tweet.timestamp] = []
        end
        @tweets_hash[tweet.timestamp] += tweet.hash_tags
      end
    end

    def top_10_tweets_in_last_60_seconds(now = Time.now.to_i)
      last_60_seconds = now - 60
      counts = {}
      # From 60 seconds back in time to now,
      # grab each entry in the tweets hash and tally them up.
      (last_60_seconds..now).each do |timestamp|
        @tweets_hash.fetch(timestamp, []).each do |hash_tag|
          if counts.key?(hash_tag)
            counts[hash_tag] += 1
          else
            counts[hash_tag] = 1
          end
        end
      end
      counts.sort_by{ |k,v| -v }.slice(0,10).map{ |k,v| k }
    end
  end
end
