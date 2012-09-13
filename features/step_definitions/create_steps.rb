When /^I send a SMS message to "(.*?)" with the following:$/ do |phone_number, text_body|
  @response = stub_api
end

Then /^I should see "(.*?)"$/ do |sms_response_text|
  pending
end
