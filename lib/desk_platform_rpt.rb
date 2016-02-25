require 'desk_platform_rpt/version'
require 'desk_platform_rpt/server'
require 'desk_platform_rpt/client'
require 'desk_platform_rpt/twitter_stream_consumer'
require 'desk_platform_rpt/tweet_parser'
require 'desk_platform_rpt/worker_pool'

# TODO remove this when finished developing
require 'byebug'

module DeskPlatformRpt
  def self.start
    # TODO clean this up
    #start_server!
    start_client!
  end

  def self.start_client!
    twitter_stream_consumer = TwitterStreamConsumer.new
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
      worker_pool.perform_work!(raw_messages_queue)
    end
    threads.map(&:join)
  end

  def self.start_server!
    puts "starting server..."
    server = WEBrick::HTTPServer.new(Port: 3000)
    server.mount "/top10", Server
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
