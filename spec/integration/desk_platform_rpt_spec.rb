require 'spec_helper'
require 'net/http'
require 'uri'
require 'json'
require 'dotenv'

describe DeskPlatformRpt do
  before :all do
    # .env credentials are required for this to run
    Dotenv.load
    Thread.new { DeskPlatformRpt::Runner.start_service }.run
    # Give twitter time to send stuff down the wire
    sleep 5
  end

  let(:uri) { URI.parse('http://localhost:3000/top10') }
  let(:response) { Net::HTTP.get_response(uri) }
  let(:top_hash_tags) { JSON.parse(response.body)['top_hash_tags'] }

  # I typically strive for a single assertion per spec
  # to make it easier to track down reasons for failure.
  it 'returns a json array' do
    expect(top_hash_tags).to be_an Array
  end

  it 'is not an empty array' do
    expect(top_hash_tags).to_not be_empty
  end

  it 'contains hash tags' do
    contains_only_hash_tags = top_hash_tags.all? { |ht| ht.start_with?('#') }

    expect(contains_only_hash_tags).to eq true
  end



  describe 'signal handling' do

  end
end
