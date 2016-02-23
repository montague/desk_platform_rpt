require 'webrick'
module DeskPlatformRpt
  class Server < WEBrick::HTTPServlet::AbstractServlet
    def do_GET(request, response)
      response.status = 200
      response.content_type = "text/plain"
      response.body = "Hi Mom!"
    end
  end
end
