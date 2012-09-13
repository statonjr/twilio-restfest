require 'webmachine'
require 'lib/helpdesk/resources'

HelpDesk = Webmachine::Application.new do |app|
  # Routing
  app.routes do
    add ['helpdesk', 'ticket'], TicketResource
  end

  # Configuration
  app.configure do |config|
    config.adapter = :Rack
  end
end
