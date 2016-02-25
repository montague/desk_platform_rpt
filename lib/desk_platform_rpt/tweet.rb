require 'json'
require 'time'

module DeskPlatformRpt
  class Tweet

    attr_accessor :timestamp, :hash_tags

    def initialize(payload)
      json = JSON.parse(payload)
      @is_deletion = !!json['delete']
      unless @is_deletion
        @timestamp = Time.parse(json['created_at']).to_i
        @hash_tags = parse_hashtags(json['text'])
      end
    end

    def parse_hashtags(text)
      text.scan(/#\w+/)
    end

    def is_deletion?
      @is_deletion
    end
  end
end
