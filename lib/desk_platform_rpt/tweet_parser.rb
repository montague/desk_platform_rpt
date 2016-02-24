require 'json'
require 'time'

module DeskPlatformRpt
  class TweetParser
    def parse_tweet(payload)
      JSON.parse(payload)
    end

    def parse_created_at(tweet_json)
      Time.parse(tweet_json['created_at'])
    end
  end
end
