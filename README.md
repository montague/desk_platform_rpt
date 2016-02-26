# DeskPlatformRpt

Hello, Code Reviewer(s)! 

## Things to note
1. I used `bundler` to generate the scaffold for this project out of convenience. I don't intend for it to be installed as a gem, so trying to do so may not work.
2. I developed and tested this using mri ruby `2.3.0`.
3. Please don't hesitate to reach out with any questions. There is a lot I'd improve about this, so if you see something that causes a furrowed brow, there's a good chance I also furrowed my brow but decided to focus on other stuff in the interest of time.
4. This was fun. Thanks!

## Getting Started
1. Run `bundle install` to install the dependencies
2. Go to [twitter](https://dev.twitter.com/streaming/reference/get/statuses/sample) and use the Oauth Signature Generator to get your credentials to consume the twitter stream.
3. When you've got your credentials, copy `.env.example` to `.env` and fill in your new creds.

## Running the service from the command line
1. Run `bin/start`

## Running the specs
1. Run `bundle exec rspec`
