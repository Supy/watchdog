# frozen_string_literal: true

require 'rails/railtie'

module Watchdog
  module Logging
    class Railtie < Rails::Railtie
      require 'active_support/ordered_options'
      require 'watchdog/attributes'

      config.watchdog = ActiveSupport::OrderedOptions.new
      config.watchdog.enabled = true
      config.watchdog.log_formatter = :simple
      config.watchdog.include_request_params = true

      initializer 'watchdog.remove_rack_logger' do |app|
        Watchdog::Logging.remove_rack_logger(app) if config.watchdog.enabled
      end

      initializer 'watchdog.reset_tagged_attributes' do |app|
        app.executor.to_run      { Watchdog::Attributes.reset }
        app.executor.to_complete { Watchdog::Attributes.reset }
      end

      config.after_initialize do |app|
        Watchdog::Logging.setup(app) if config.watchdog.enabled
      end
    end
  end
end
