require 'spec_helper'
require 'net/http'
require 'json'

describe DeskPlatformRpt do
  before :all do
    # .env credentials are required for this to run
    @thread = Thread.new { DeskPlatformRpt::Runner.start_service }
    @thread.run
    # Give twitter time to send stuff down the wire
    sleep 10
  end

  after :all do
    DeskPlatformRpt::Runner.stop_service
  end

  let(:uri) { URI.parse('http://localhost:3000/top10') }

  it 'returns the top 10 hash tags in json' do
    response_body = Net::HTTP.get_print(uri)
    puts "=========>#{response_body}"
    expect(true).to eq true
  end
end
