# frozen_string_literal: true

require 'active_support/log_subscriber'

require 'watchdog/event'

module Watchdog
  module Logging
    module LogSubscribers
      class ActionController < ::ActiveSupport::LogSubscriber
        def start_processing(event)
          info do
            Watchdog::Event.new(
              'request.started',
              **{}.tap do |attributes|
                extract_base_details(event, attributes)
                extract_error(event, attributes)
              end
            )
          end
        end

        # rubocop:disable Metrics/AbcSize
        def process_action(event)
          payload = event.payload

          info do
            Watchdog::Event.new(
              'request.processed',
              **{}.tap do |attributes|
                extract_base_details(event, attributes)
                extract_status(event, attributes)
                extract_duration(event, attributes)
                attributes[:db] = payload[:db_runtime].to_f.round(2) if payload[:db_runtime]
                attributes[:view] = payload[:view_runtime].to_f.round(2) if payload[:view_runtime]
                extract_error(event, attributes)
              end
            )
          end
        end
        # rubocop:enable Metrics/AbcSize

        def redirect_to(event)
          info do
            Watchdog::Event.new(
              'request.redirected',
              **{}.tap do |attributes|
                extract_status(event, attributes)
                attributes[:location] = event.payload[:location]
                extract_error(event, attributes)
              end
            )
          end
        end

        def halted_callback(event)
          info do
            Watchdog::Event.new(
              'request.halted',
              **{}.tap do |attributes|
                attributes[:filter] = event.payload[:filter]
                extract_error(event, attributes)
              end
            )
          end
        end

        private

        def extract_base_details(event, attributes)
          payload = event.payload

          attributes[:action] = "#{payload[:controller]}##{payload[:action]}"
          attributes[:ip] = payload[:request].remote_ip
          attributes[:method] = payload[:method]
          attributes[:format] = payload[:format]
          extract_url(event, attributes)
        end

        def extract_url(event, attributes)
          attributes[:url] = clean_url_query_string(event.payload[:request].original_url)
        end

        def extract_error(event, attributes)
          exception = event.payload[:exception_object]
          return unless exception

          attributes[:error] = exception
        end

        def extract_duration(event, attributes)
          # Duration is in milliseconds.
          attributes[:duration] = event.duration.to_f.round(2)
        end

        def extract_status(event, attributes)
          attributes[:status] = event.payload[:status]
        end

        def clean_url_query_string(path)
          uri = URI.parse(path)
          query = uri.query
          if query
            stripped_query = query.split('&').map { |part| "#{part.split('=')[0]}=" }.join('&')
            uri.query = stripped_query
          end
          uri.to_s
        end
      end
    end
  end
end
