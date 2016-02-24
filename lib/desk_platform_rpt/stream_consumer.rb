require 'json'
module DeskPlatformRpt
  class StreamConsumer
    class TwitterError < StandardError; end

    attr_reader :raw_messages_queue, :fragment, :number_of_bytes_left_to_read

    def initialize
      # first chunk will start with the number of bytes to read
      # last chunk will be cut off and will not have the full number of bytes
      # push each chunk into a queue
      @raw_messages_queue = Queue.new
      @fragment = ""
      @number_of_bytes_left_to_read = 0
    end

    def consume(chunk)
      lines = chunk.lines
      if @number_of_bytes_left_to_read > 0
        assemble_chunked_message(lines.shift.chomp)
      end

      lines.each_slice(2) do |length, message|
        length = length.to_i
        # could also use the new 2.3.0 message&.chomp! syntax
        message && message.chomp!
        if message.nil?
          @number_of_bytes_left_to_read = length
        elsif message.size == length
          @raw_messages_queue.push(message)
        elsif message.size < length
          @number_of_bytes_left_to_read = length - message.size
          @fragment << message
        else
          # Twitter is being weird. Shouldn't happen.
          raise TwitterError, "Twitter has sent an incorrect value for message length. "\
                "Expected length was #{length} but message length was #{message.size} bytes."
        end
      end
    end

    private
    def assemble_chunked_message(fragment_suffix)
      if fragment_suffix.size != @number_of_bytes_left_to_read
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
