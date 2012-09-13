require 'rest_client'
require 'json'
require './lib/helpdesk/twilio'
require 'twilio-ruby'

class TicketResource < Webmachine::Resource

  def allowed_methods
    %W[POST]
  end

  def languages_provided
    ["en-us"]
  end

  def allow_missing_post?
    true
  end

  def post_is_create?
    false
  end

  def process_post
    # Here's the request body from Twilio
    # We want the 'Body' key
    # We'll use this as the description
    # TODO: Stuff this into XML per the media type
    description = JSON.parse(request.body.to_s)['Body']
    # We also need to know what phone number sent the SMS message
    reply_to = JSON.parse(request.body.to_s)['From']
    reply_from = JSON.parse(request.body.to_s)['To']
    # PUT to our API to create our ticket
    # response = RestClient.put('http://restdesk.herokuapp.com',
    # description, :content_type =>
    # 'application/vnd.org.restfest.2012.hackday+xml'
    # Return the status back to the client via SMS
    account_sid = TwilioConfig::ACCOUNT_SID
    auth_token = TwilioConfig::AUTH_TOKEN
    client = Twilio::REST::Client.new account_sid, auth_token
    client.account.sms.messages.create(
      :from => reply_from,
      :to => reply_to,
      :body => "Test" # response.body?
    )
    true
  end

  # Hack to deal with Rack::Lint
  def finish_request
    case
    when [204,205,304].include?(response.code)
      response.headers.delete 'Content-Type'
    end
  end

  def content_types_accepted
    [['application/json', :ticket_status]]
  end

  def ticket_status
  end

end
