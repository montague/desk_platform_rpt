require 'desk_platform_rpt/version'
require 'desk_platform_rpt/server'
require 'desk_platform_rpt/client'
require 'desk_platform_rpt/twitter_stream_consumer'
require 'desk_platform_rpt/tweet'
require 'desk_platform_rpt/worker_pool'
require 'desk_platform_rpt/top_tweets'

# TODO remove this when finished developing
require 'byebug'

module DeskPlatformRpt
  def self.start
    top_tweets = TopTweets.new
    twitter_stream_consumer = TwitterStreamConsumer.new

    threads = []
    threads << Thread.new do
      start_client!(top_tweets, twitter_stream_consumer)
    end

    threads << Thread.new do
      start_server!(top_tweets)
    end

    threads.each(&:join)
  end

  def self.start_client!(top_tweets, twitter_stream_consumer)
    raw_messages_queue = twitter_stream_consumer.raw_messages_queue
    worker_pool = WorkerPool.new
    client = Client.new(
      twitter_stream_consumer,
      api_key: ENV['TWITTER_API_KEY'],
      api_secret: ENV['TWITTER_API_SECRET'],
      access_token: ENV['TWITTER_TOKEN'],
      access_token_secret: ENV['TWITTER_TOKEN_SECRET']
    )

    threads = []
    threads << Thread.new do
      client.connect_and_consume
    end

    threads << Thread.new do
      worker_pool.consume_tweet_queue!(raw_messages_queue, top_tweets)
    end
    threads.each(&:join)
  end

  def self.start_server!(top_tweets)
    puts "starting server..."
    server = WEBrick::HTTPServer.new(Port: 3000)
    server.mount "/top10", Server, top_tweets
    server.start
    puts "server started: #{server}"

    #Signal.trap("HUP") do
      ## TODO close and reopen twitter stream, reset all stats to zero
    #end

    #Signal.trap("QUIT") do
      ## TODO graceful shutdown. Properly close stream and exit
      #server.shutdown
    #end

    Signal.trap("INT") do
      puts "====received signal int!"
      server.shutdown
    end

    #Signal.trap("TERM") do
      #server.shutdown
    #end

  end

end
