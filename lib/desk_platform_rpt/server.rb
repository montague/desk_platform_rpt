require 'webrick'
require 'json'
module DeskPlatformRpt
  class Server < WEBrick::HTTPServlet::AbstractServlet
    def do_GET(request, response)
      response.status = 200
      response.content_type = "application/json"
      response.body = JSON.generate(content: "hi mom")
    end
  end
end
