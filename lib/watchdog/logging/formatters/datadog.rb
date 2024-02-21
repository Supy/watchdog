# frozen_string_literal: true

require 'logger'

require 'watchdog/event'

module Watchdog
  module Logging
    module Formatters
      class Datadog < ::Logger::Formatter
        DD_SOURCE = 'ruby'

        def initialize
          super

          require 'json'

          begin
            require 'ddtrace'
          rescue LoadError
            raise 'Usage of the Datadog formatter requires the ddtrace gem'
          end
        end

        # rubocop:disable Metrics/MethodLength
        def call(severity, timestamp, _progname, msg)
          payload =
            case msg
            when Watchdog::Event
              log_event(msg)
            else
              log_generic(msg)
            end

          payload.merge!(
            {
              status: severity,
              timestamp: timestamp.utc.iso8601(3)
            },
            tracing_info
          )

          "#{JSON.dump(payload)}\n"
        rescue StandardError => e
          Rails.logger.debug e.backtrace.join("\n")
        end
        # rubocop:enable Metrics/MethodLength

        private

        # rubocop:disable Metrics/AbcSize
        def log_event(event)
          if event.attributes.key?(:error) && event.attributes[:error].is_a?(Exception)
            error = event.attributes[:error]
            event.attributes[:error] = {
              class: error.class.name,
              message: error.message
            }

            { message: "#{event.event&.to_s} #{format_attributes(event.attributes)}" }.merge(dd_error_hash(error))
          else
            { message: "#{event.event&.to_s} #{format_attributes(event.attributes)}" }
          end
        end
        # rubocop:enable Metrics/AbcSize

        def dd_error_hash(error)
          {
            error: {
              kind: error.class.to_s,
              message: error.message,
              stack: Rails.backtrace_cleaner.clean(error.backtrace).join("\n")
            }
          }
        end

        def log_generic(msg)
          { message: msg.to_s }
        end

        def tracing_info
          correlation = ::Datadog::Tracing.correlation

          return {} if correlation.nil?

          {
            env: correlation.env.to_s,
            service: correlation.service.to_s,
            source: DD_SOURCE,
            trace_id: correlation.trace_id.to_s,
            version: correlation.version.to_s
          }
        end

        def format_attributes(attributes)
          return '' if attributes.empty?

          flatten_attributes(**attributes).map do |key, value|
            "#{key}=#{value}"
          end.join(' ')
        end

        # Given an input of
        # { foo: 'bar', baz: { qux: 'quux' } }
        # returns
        # { foo: 'bar', 'baz.qux': 'quux' }
        def flatten_attributes(**attributes)
          attributes.each_with_object({}) do |(key, value), flattened_attributes|
            if value.is_a?(Hash)
              flatten_attributes(**value).each do |nested_key, nested_value|
                flattened_attributes["#{key}.#{nested_key}".to_sym] = nested_value
              end
            else
              flattened_attributes[key.to_sym] = value
            end
          end
        end
      end
    end
  end
end
