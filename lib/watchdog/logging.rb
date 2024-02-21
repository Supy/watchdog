# frozen_string_literal: true

require 'watchdog/event'
require 'watchdog/attributes'

module Watchdog
  module Logging
    class << self
      # This method must be called after the application is initialized.
      def setup(app)
        detach_default_log_subscribers
        attach_log_subscribers
        change_formatter(app)
      end

      # This method must be called before the application is initialized because
      # the middleware chain is finalized during initialization.
      def remove_rack_logger(app)
        app.config.middleware.delete(Rails::Rack::Logger) if defined?(Rails::Rack::Logger)
      end

      def detach_default_log_subscribers
        require 'action_view/log_subscriber'
        ActionView::LogSubscriber.detach_from :action_view if defined?(ActionView::LogSubscriber)

        require 'action_controller/log_subscriber'
        ActionController::LogSubscriber.detach_from :action_controller if defined?(ActionController::LogSubscriber)

        require 'active_job/log_subscriber'
        ActiveJob::LogSubscriber.detach_from :active_job if defined?(ActiveJob::LogSubscriber)

        require 'action_view/log_subscriber'
        ActionView::LogSubscriber.detach_from :action_view if defined?(ActionView::LogSubscriber)
        ActiveSupport::Notifications.unsubscribe 'render_template.action_view'
        ActiveSupport::Notifications.unsubscribe 'render_layout.action_view'
      end

      def attach_log_subscribers
        require 'watchdog/logging/log_subscribers/action_controller'
        Watchdog::Logging::LogSubscribers::ActionController.attach_to :action_controller

        require 'watchdog/logging/log_subscribers/active_job'
        Watchdog::Logging::LogSubscribers::ActiveJob.attach_to :active_job
      end

      def change_formatter(app)
        return if Rails.logger.nil?

        case app.config.watchdog.log_formatter
        when :datadog
          require 'watchdog/logging/formatters/datadog'
          Rails.logger.formatter = Watchdog::Logging::Formatters::Datadog.new
        when :simple
          require 'watchdog/logging/formatters/simple'
          Rails.logger.formatter = Watchdog::Logging::Formatters::Simple.new
        else
          require 'watchdog/logging/formatters/simple'
          Rails.logger.formatter = Watchdog::Logging::Formatters::Simple.new
        end
      end
    end
  end

  def self.event(event, **attributes)
    attributes.merge!(Watchdog::Attributes.get)

    Watchdog::Event.new(event, **attributes)
  end
end

require 'watchdog/logging/railtie' if defined?(Rails)
