module DeskPlatformRpt
  class TweetStreamConsumer
    class TwitterError < StandardError; end

    attr_reader :raw_messages_queue, :fragment, :number_of_bytes_left_to_read

    def initialize
      @raw_messages_queue = Queue.new
      @fragment = ""
      @number_of_bytes_left_to_read = 0
    end

    def consume(chunk)
      lines = chunk.lines
      if @number_of_bytes_left_to_read > 0
        assemble_chunked_message(lines.shift)
      end

      # Based on assumptions that first chunk received will begin
      # with a length and will be followed by \r\n and a message.
      # https://dev.twitter.com/streaming/overview/processing
      lines.each_slice(2) do |length, message|
        length = length.to_i
        if message.nil?
          @number_of_bytes_left_to_read = length
        elsif message.size == length
          @raw_messages_queue.push(message)
        elsif message.size < length
          @number_of_bytes_left_to_read = length - message.size
          @fragment << message
        else
          # We'd log this via an exception tracking service (eg HoneyBadger)
          raise TwitterError, "Twitter has sent an incorrect value for message length. "\
                "Expected length was #{length} but message length was #{message.size} bytes."
        end
      end
    end

    private
    def assemble_chunked_message(fragment_suffix)
      if fragment_suffix.size < @number_of_bytes_left_to_read
        @number_of_bytes_left_to_read = @number_of_bytes_left_to_read - fragment_suffix.size
        @fragment << fragment_suffix
      elsif fragment_suffix.size > @number_of_bytes_left_to_read
        # We'd log this via an exception tracking service (eg HoneyBadger)
        raise TwitterError, "Expected a fragment of length #{@number_of_bytes_left_to_read} "\
          "but length was #{fragment_suffix.size}"
      else
        @raw_messages_queue.push(@fragment << fragment_suffix)
        @number_of_bytes_left_to_read = 0
        @fragment = ""
      end
    end
  end
end
