require "desk_platform_rpt/version"
require "desk_platform_rpt/server"
require "desk_platform_rpt/client"

module DeskPlatformRpt
  def self.start
    # TODO clean this up
    if ENV.key?('DO')
      puts "Environment variables loaded successfully: #{ENV['DO']}"
    end

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
