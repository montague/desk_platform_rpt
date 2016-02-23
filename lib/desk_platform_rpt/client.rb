require 'net/http'
require 'oauth'

module DeskPlatformRpt
  class Client
    def initialize(credentials)
      @credentials = credentials
    end

    def connect_and_write_contents
      uri = URI('https://stream.twitter.com/1.1/statuses/sample.json?delimited=length')
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        params = {
          api_key: @api_key, api_secret: @api_secret,
          access_token: @access_token, access_token_secret: @access_token_secret
        }
        sign_request(request, @credentials)
        http.request(request) do |response|
          File.open('sample.txt', 'w') do |io|
            response.read_body do |chunk|
              #puts ("=" * 50) + "BEGIN CHUNK"
              #byebug
              #puts chunk
              io.write(chunk)
              #puts ("=" * 50) + "END CHUNK"
            end
          end
        end
      end
    end

    # From Platform Challenge PDF
    def sign_request(req, params)
      consumer = OAuth::Consumer.new(params.fetch(:api_key), params.fetch(:api_secret),
                                     { :site => "https://stream.twitter.com", :scheme => :header })
      # now create the access token object from passed values
      token_hash = { :oauth_token => params.fetch(:access_token),
                     :oauth_token_secret => params.fetch(:access_token_secret) }
      access_token = OAuth::AccessToken.from_hash(consumer, token_hash)
      access_token.sign!(req)
    end
  end
end
