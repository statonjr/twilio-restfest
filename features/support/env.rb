require 'webmock/cucumber'
require 'rack/test'
require 'rspec'
require 'json'

$LOAD_PATH.unshift(File.expand_path('../../..', __FILE__))
require "lib/helpdesk"

module AppHelper
  def app
    HelpDesk.adapter
  end
end

module FakeTwilio
  def stub_api
    canned_response = File.read('features/support/test-data/twilio-mock-request.json')
    stub_request(:post, "https://api.twilio.com/").to_return(canned_response)
  end
end

World(Rack::Test::Methods, AppHelper, FakeTwilio)

After do
  @api_stubbed = false
end
