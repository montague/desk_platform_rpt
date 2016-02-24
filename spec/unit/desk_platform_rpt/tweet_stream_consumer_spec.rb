require 'spec_helper'

describe DeskPlatformRpt::TweetStreamConsumer do
  describe '#consume' do
    let(:consumer) { DeskPlatformRpt::TweetStreamConsumer.new }

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

    it 'loads the stream_sample on its queue' do
      file_path = File.expand_path('../../../fixtures/stream_sample.txt', __FILE__)
      # TODO random chunk size?
      chunk_size = 100000

      File.open(file_path) do |io|
        while chunk = io.read(chunk_size)
          consumer.consume(chunk)
        end
      end

      expect(consumer.raw_messages_queue.size).to eq 26
    end

    it 'assembles chunked messages when the length is not followed by a message' do
      consumer.consume("6\r\n1234\r\n6\r\n")
      consumer.consume("5678\r\n")

      expect(consumer.raw_messages_queue.pop).to eq "1234\r\n"
      expect(consumer.raw_messages_queue.pop).to eq "5678\r\n"
      expect(consumer.raw_messages_queue).to be_empty
    end

    it 'assembles chunked messages when the length is followed by a message fragment' do
      consumer.consume("6\r\n1234\r\n6\r\n56")
      consumer.consume("78\r\n7\r\n78900\r\n")

      expect(consumer.raw_messages_queue.pop).to eq "1234\r\n"
      expect(consumer.raw_messages_queue.pop).to eq "5678\r\n"
      expect(consumer.raw_messages_queue.pop).to eq "78900\r\n"
      expect(consumer.raw_messages_queue).to be_empty
    end

    it 'assembles chunked messages when the message is split over more than two chunks' do
      consumer.consume("11\r\n123")
      consumer.consume("456")
      consumer.consume("789\r\n6\r\n1234\r\n")

      expect(consumer.raw_messages_queue.pop).to eq "123456789\r\n"
      expect(consumer.raw_messages_queue.pop).to eq "1234\r\n"
      expect(consumer.raw_messages_queue).to be_empty
    end

    it 'properly resets state after a chunked message is reassembled' do
      consumer.consume("6\r\n1234\r\n6\r\n56")
      consumer.consume("78\r\n")

      expect(consumer.number_of_bytes_left_to_read).to be_zero
      expect(consumer.fragment).to be_empty
    end

    it 'raises an error if the remaining fragment is not the length expected' do
      consumer.consume("6\r\n1234\r\n4\r\n56")

      expect {
        consumer.consume("8888\r\n")
      }.to raise_error(DeskPlatformRpt::TweetStreamConsumer::TwitterError,
                       'Expected a fragment of length 2 but length was 6')
    end

    it 'raises an error if the message is bigger than the length' do
      expect {
        consumer.consume("4\r\n1234556\r\n4\r\n1234")
      }.to raise_error(DeskPlatformRpt::TweetStreamConsumer::TwitterError,
                       'Twitter has sent an incorrect value for message length. '\
                       'Expected length was 4 but message length was 9 bytes.'
                      )

    end
  end
end
