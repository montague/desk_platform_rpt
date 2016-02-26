require 'net/http'
require 'oauth'

module DeskPlatformRpt
  class Client

    attr_reader :tweet_stream_consumer

    def initialize(tweet_stream_consumer, credentials)
      @tweet_stream_consumer = tweet_stream_consumer
      @credentials = credentials
    end

    def connect_and_consume
      uri = URI('https://stream.twitter.com/1.1/statuses/sample.json')
      @http_session = Net::HTTP.start(uri.host, uri.port, use_ssl: true)
      request = Net::HTTP::Get.new(uri.request_uri)
      sign_request(request, @credentials)
      @http_session.request(request) do |response|
        response.read_body do |chunk|
          tweet_stream_consumer.consume(chunk)
        end
      end
    end

    def close
      @http_session.finish
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
