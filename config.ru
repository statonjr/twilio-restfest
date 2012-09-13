require 'bundler'

Bundler.setup

# Adapter
require 'webmachine/adapter'
require 'webmachine/adapters/rack'

# Application
require './lib/helpdesk'

run HelpDesk.adapter
