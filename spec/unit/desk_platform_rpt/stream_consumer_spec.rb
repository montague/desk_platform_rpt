require 'spec_helper'

describe DeskPlatformRpt::StreamConsumer do
  def stream_data(&block)
    file_path = File.expand_path('../../../fixtures/stream_sample.txt', __FILE__)
     # TODO random chunk size?
    chunk_size = 1000

    File.open(file_path, mode: 'r:UTF-8') do |io|
      while chunk = io.read(chunk_size)
        puts '=========reading chunk'
        block.call(chunk)
        puts '=========read da chunk'
      end
    end
  end

  describe '#consume' do
    let(:consumer) { DeskPlatformRpt::StreamConsumer.new }

    it 'initializes its inner state to be empty' do
      expect(consumer.raw_messages_queue).to be_empty
      expect(consumer.fragment).to be_empty
      expect(consumer.number_of_bytes_left_to_read).to be_zero
    end

    it 'loads messages on its queue' do
      consumer.consume("4\r\n1234")

      expect(consumer.raw_messages_queue.pop).to eq '1234'
      expect(consumer.raw_messages_queue).to be_empty
    end

    it 'assembles chunked messages when the length is not followed by a message' do
      consumer.consume("4\r\n1234\r\n4\r\n")
      consumer.consume("5678\r\n")

      expect(consumer.raw_messages_queue.pop).to eq '1234'
      expect(consumer.raw_messages_queue.pop).to eq '5678'
      expect(consumer.raw_messages_queue).to be_empty
    end

    it 'assembles chunked messages when the length is not followed by a message' do
      consumer.consume("4\r\n1234\r\n4\r\n56")
      consumer.consume("78\r\n5\r\n78900")

      expect(consumer.raw_messages_queue.pop).to eq '1234'
      expect(consumer.raw_messages_queue.pop).to eq '5678'
      expect(consumer.raw_messages_queue.pop).to eq '78900'
      expect(consumer.raw_messages_queue).to be_empty
    end

    it 'properly resets state after a chunked message is reassembled' do
      consumer.consume("4\r\n1234\r\n4\r\n56")
      consumer.consume("78\r\n")

      expect(consumer.number_of_bytes_left_to_read).to be_zero
      expect(consumer.fragment).to be_empty
    end

    it 'raises an error if the remaining fragment is not the length expected' do
      consumer.consume("4\r\n1234\r\n4\r\n56")

      expect {
        consumer.consume("8\r\n")
      }.to raise_error(DeskPlatformRpt::StreamConsumer::TwitterError,
                       'Expected a fragment of length 2 but length was 1')
    end
  end
end