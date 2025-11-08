require_relative "boot"

require "rails/all"

# Load sprockets for asset pipeline support
begin
  require "sprockets/railtie"
rescue LoadError
  # Sprockets not available
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require "lookout"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    
    # Disable ActionMailer previews (Rails 8 compatibility)
    config.action_mailer.show_previews = false if config.respond_to?(:action_mailer)
  end
end
