require 'desk_platform_rpt/version'
require 'desk_platform_rpt/server'
require 'desk_platform_rpt/client'
require 'desk_platform_rpt/twitter_stream_consumer'
require 'desk_platform_rpt/tweet'
require 'desk_platform_rpt/worker_pool'
require 'desk_platform_rpt/top_tweets'

module DeskPlatformRpt
  class Runner
    Signal.trap :INT do
      puts "Later..."
      exit
    end

    Signal.trap :TERM do
      puts "Byeeeeee..."
      exit
    end

    Signal.trap :HUP do
      puts "Closing and reopening twitter stream, resetting stats..."
      restart_client
    end

    Signal.trap :QUIT do
      puts "Shutting down gracefully..."
      stop_service
      exit
    end

    # Entrypoint
    def self.start_service
      ensure_credentials!
      @@top_tweets = TopTweets.new
      @@twitter_stream_consumer = TwitterStreamConsumer.new
      @@workers = WorkerPool.new

      @@client = Client.new(
        @@twitter_stream_consumer,
        @@credentials
      )

      @@threads = [
        Thread.new { start_client },
        Thread.new { start_server }
      ]
      @@threads.map(&:join)
    end

    def self.stop_service
      stop_client
      stop_server
    end

    def self.restart_client
      stop_client # close connection
      @@workers.stop
      @@twitter_stream_consumer.reset
      @@top_tweets.reset
      @@client_threads.map(&:terminate)
      Thread.new { start_client }.run
    end

    def self.start_client
      raw_messages_queue = @@twitter_stream_consumer.raw_messages_queue
      @@client_threads = []
      @@client_threads << Thread.new do
        @@client.connect_and_consume
      end

      @@client_threads << Thread.new do
        @@workers.consume_tweet_queue!(raw_messages_queue, @@top_tweets)
      end
      @@client_threads.each(&:join)
    end

    def self.stop_client
      @@client.close
    end

    def self.start_server
      @@server = WEBrick::HTTPServer.new(Port: 3000)
      @@server.mount "/top10", Server, @@top_tweets
      @@server.start
    end

    def self.stop_server
      @@server.stop
    end

    def self.ensure_credentials!
      @@credentials = {
        api_key: ENV['TWITTER_API_KEY'],
        api_secret: ENV['TWITTER_API_SECRET'],
        access_token: ENV['TWITTER_TOKEN'],
        access_token_secret: ENV['TWITTER_TOKEN_SECRET']
      }
      @@credentials.each do |key, value|
        if value && value.strip.empty?
          # TODO collect missing keys and list all missing instead
          # of forcing the user to track down one key at a time
          raise "Config key '#{key}' is missing and is required."
        end
      end
    end
  end
end
