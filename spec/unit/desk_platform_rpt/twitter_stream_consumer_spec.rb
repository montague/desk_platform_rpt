require 'spec_helper'

describe DeskPlatformRpt::TwitterStreamConsumer do
  describe '#consume' do
    let(:consumer) { DeskPlatformRpt::TwitterStreamConsumer.new }

    it 'initializes its inner state to be empty' do
      expect(consumer.raw_messages_queue).to be_empty
      expect(consumer.fragment).to be_empty
    end

    it 'loads messages on its queue' do
      consumer.consume("1234\r\n")

      expect(consumer.raw_messages_queue.pop).to eq "1234\r\n"
      expect(consumer.raw_messages_queue).to be_empty
    end


    it "loads the stream_sample on its queue with a chunk size of 1500" do
      file_path = File.expand_path('../../../fixtures/stream_sample.txt', __FILE__)
      chunk_size = 500 # nice and chunky
      File.open(file_path) do |io|
        while chunk = io.read(chunk_size)
          consumer.consume(chunk)
        end
      end

      expect(consumer.raw_messages_queue.size).to eq 26
    end

    it 'does not push a fragment onto its queue' do
      consumer.consume("1234\r\n567")

      expect(consumer.raw_messages_queue.pop).to eq "1234\r\n"
      expect(consumer.raw_messages_queue).to be_empty
    end

    it 'consumes a message that has emoji' do
      consumer.consume("1234\r\n567😀\r\n")

      expect(consumer.raw_messages_queue.pop).to eq "1234\r\n"
      expect(consumer.raw_messages_queue.pop).to eq "567😀\r\n"
      expect(consumer.raw_messages_queue).to be_empty
    end

    it 'assembles chunked messages when the length is not followed by a message' do
      consumer.consume("1234\r\nomg")
      consumer.consume("5678\r\n")

      expect(consumer.raw_messages_queue.pop).to eq "1234\r\n"
      expect(consumer.raw_messages_queue.pop).to eq "omg5678\r\n"
      expect(consumer.raw_messages_queue).to be_empty
    end

    it 'assembles chunked messages when the message is split over more than two chunks' do
      consumer.consume("123\r\n123")
      consumer.consume("456")
      consumer.consume("789\r\n1234\r\n")

      expect(consumer.raw_messages_queue.pop).to eq "123\r\n"
      expect(consumer.raw_messages_queue.pop).to eq "123456789\r\n"
      expect(consumer.raw_messages_queue.pop).to eq "1234\r\n"
      expect(consumer.raw_messages_queue).to be_empty
    end
  end
end
