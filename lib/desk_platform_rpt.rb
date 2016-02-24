require 'desk_platform_rpt/version'
require 'desk_platform_rpt/server'
require 'desk_platform_rpt/client'
require 'desk_platform_rpt/tweet_stream_consumer'

# TODO remove this when finished developing
require 'byebug'

module DeskPlatformRpt
  def self.start
    # TODO clean this up
    #start_server!
    start_client!
  end

  def self.start_client!
    client = Client.new(
      api_key: ENV['TWITTER_API_KEY'],
      api_secret: ENV['TWITTER_API_SECRET'],
      access_token: ENV['TWITTER_TOKEN'],
      access_token_secret: ENV['TWITTER_TOKEN_SECRET']
    )
    client.connect_and_write_contents
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
