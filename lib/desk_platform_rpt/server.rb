require 'webrick'
require 'json'
module DeskPlatformRpt
  class Server < WEBrick::HTTPServlet::AbstractServlet

    def initialize(server, top_tweets)
      super server
      @top_tweets = top_tweets
    end

    def do_GET(request, response)
      response.status = 200
      response.content_type = "application/json"
      response.body = JSON.generate(top_tweets: @top_tweets.top_10_tweets_in_last_60_seconds)
    end
  end
end
