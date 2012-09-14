require 'rest_client'
require './lib/helpdesk/twilio'
require 'twilio-ruby'
require 'nokogiri'
require 'cgi'

class TicketResource < Webmachine::Resource

  # TODO: Move this into a Module with the CGI require
  def params
    @params = {}
    request.body.to_s.split(/&/).each do |kv|
      key, value = kv.split(/=/)
      if key && value
        key, value = CGI.unescape(key), CGI.unescape(value)
        @params[key] = value
      end
    end
    @params
  end

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
    description = params['Body']
    # We also need to know what phone number sent the SMS message
    reply_to = params['From']
    reply_from = params['To']

    # Find the tickets URL
    response = RestClient.get("http://restdesk.herokuapp.com")
    doc = Nokogiri::XML(response.body)
    url = doc.xpath('//atom:link[@rel="http://helpdesk.hackday.2012.restfest.org/rels/tickets"]')[0].attr(:href)

    # Create the XML
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.ticket {
        xml.description description
      }
    end

    # POST to our API to create our ticket
    t = Thread.new do
      Thread.current[:restdesk_response] = RestClient.post(url, builder.to_xml, :content_type => 'application/vnd.org.restfest.2012.hackday+xml')
    end
    t.join
    restdesk_headers = t[:restdesk_response].headers

    # Return the status back to the client via SMS
    account_sid = TwilioConfig::ACCOUNT_SID
    auth_token = TwilioConfig::AUTH_TOKEN
    client = Twilio::REST::Client.new account_sid, auth_token
    client.account.sms.messages.create(
      :from => reply_from,
      :to => reply_to,
      :body => "We received your help desk request. You can GET more info at this URL: #{restdesk_headers[:content_location]}"
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

end
