module DeskPlatformRpt
  class WorkerPool

    attr_reader :number_of_workers

    def initialize(workers=4)
      @number_of_workers = workers
    end

    # TODO implement cleanup code
    def perform_work!(work_queue)
      puts "=====>performing work: #{work_queue.size}"
      parser = TweetParser.new
      workers = number_of_workers.times.map do |i|
        Thread.new do
          while raw_message = work_queue.pop
            tweet = parser.parse_tweet(raw_message)
            #puts "===========>worker #{i} PARSING 1 TWEET of #{work_queue.size}"
            #puts "------->#{parser.parse_created_at(tweet)}"
          end
          #puts "======>thread #{i} ALL DONE!"
        end
      end
      workers.map(&:join)
      #puts "===========>WORKER THREADS DONE!"
    end
  end
end
