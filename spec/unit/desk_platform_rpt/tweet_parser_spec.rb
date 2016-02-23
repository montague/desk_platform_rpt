require 'spec_helper'

describe DeskPlatformRpt::TweetParser do
  def stream_data(&block)
    file_path = File.expand_path('../../../fixtures/sample.txt', __FILE__)
    chunk_size = 1000

    File.open(file_path, mode: 'r:UTF-8') do |io|
      while chunk = io.read(chunk_size)
        puts '=========reading chunk'
        block.call(chunk)
        puts '=========read da chunk'
      end
    end
  end

  it 'streams data' do
    stream_data do |chunk|
      puts chunk
    end
  end
end
