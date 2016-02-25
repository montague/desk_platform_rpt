module DeskPlatformRpt
  class WorkerPool

    def initialize(workers=4)
      @number_of_workers = workers
    end

    def consume_tweet_queue!(work_queue, top_tweets)
      workers = @number_of_workers.times.map do |i|
        Thread.new do
          while raw_message = work_queue.pop
            tweet = Tweet.new(raw_message)
            top_tweets.add_tweet(tweet) unless tweet.deletion?
            puts "===========added tweet to top_tweets"
          end
        end
      end
      workers.each(&:join)
    end
  end
end
