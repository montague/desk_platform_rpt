require 'spec_helper'

describe DeskPlatformRpt::Tweet do
  describe '#new' do

    context 'with a new tweet payload' do
      let(:tweet_payload) { File.read(File.join(fixture_path, 'tweet.txt')) }
      let(:tweet) { DeskPlatformRpt::Tweet.new(tweet_payload) }

      it 'correctly sets the timestamp' do
        expect(tweet.timestamp).to eq 1456280782
      end

      it 'correctly sets the hash_tags' do
        expect(tweet.hash_tags).to match_array %w(#Ohmypet #lol)
      end
    end

    context 'with a deleted tweet payload' do
      let(:deleted_tweet_payload) { File.read(File.join(fixture_path, 'deleted_tweet.txt')) }
      let(:tweet) { DeskPlatformRpt::Tweet.new(deleted_tweet_payload) }


      it 'correctly sets the is_deletion flag' do
        expect(tweet).to be_deletion
      end
    end
  end
end
