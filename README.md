# DeskPlatformRpt

Hello, Code Reviewer(s)! 

## Things to note
1. I used `bundler` to generate the scaffold for this project out of convenience. I don't intend for it to be installed as a gem, so trying to do so may not work.
2. I developed and tested this using mri ruby `2.3.0`.
3. Please don't hesitate to reach out with any questions :)

## Getting Started
1. Run `bundle install` to install the dependencies
2. Go to [twitter](https://dev.twitter.com/streaming/reference/get/statuses/sample) and use the Oauth Signature Generator to get your credentials to consume the twitter stream.
3. When you've got your credentials, copy `.env.example` to `.env` and fill in your new creds.

## Running the service from the command line
1. Run `bin/start`

## Running the specs
1. Run `bundle exec rspec`

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

