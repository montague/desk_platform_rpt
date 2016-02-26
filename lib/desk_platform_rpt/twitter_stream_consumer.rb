require 'json'

module DeskPlatformRpt
  class TwitterStreamConsumer
    class TwitterError < StandardError; end

    attr_accessor :raw_messages_queue, :fragment

    MSG_DELIMITER = "\r\n"

    def initialize
      @raw_messages_queue = Queue.new
      @fragment = ""
    end

    def reset
      @raw_messages_queue.clear
      @fragment = ""
    end

    def consume(chunk)
      lines = chunk.lines(MSG_DELIMITER)
      # Assumes beginning of the stream will be a full message.
      lines.each do |line|
        if !self.fragment.empty?
          # This line is part of the fragment
          if line.end_with?(MSG_DELIMITER)
            # This will complete the fragment
            self.raw_messages_queue.push(self.fragment << line)
            self.fragment = ""
          else
            # This is another part of the fragment
            self.fragment << line
          end
        elsif line.end_with?(MSG_DELIMITER)
          self.raw_messages_queue.push(line)
        else # fragment
          self.fragment << line
        end
      end
    end
  end
end
