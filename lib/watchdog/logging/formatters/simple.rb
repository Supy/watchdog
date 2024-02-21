# frozen_string_literal: true

require 'logger'

require 'watchdog/event'

module Watchdog
  module Logging
    module Formatters
      class Simple < ::Logger::Formatter
        def call(severity, timestamp, _progname, msg)
          case msg
          when Watchdog::Event
            log_event(severity, timestamp, msg.event, msg.attributes)
          else
            log_generic(severity, timestamp, msg)
          end
        end

        private

        def log_event(severity, timestamp, event, attributes)
          if attributes.key?(:error) && attributes[:error].is_a?(Exception)
            error = attributes[:error]
            attributes[:error] = {
              class: error.class.name,
              message: error.message
            }
          end

          "#{timestamp.utc.iso8601(3)} #{severity} #{event} #{format_attributes(attributes)}\n"
        end

        def log_generic(severity, timestamp, msg)
          "#{timestamp.utc.iso8601(3)} #{severity} #{msg}\n"
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
