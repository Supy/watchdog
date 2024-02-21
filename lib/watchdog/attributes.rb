# frozen_string_literal: true

module Watchdog
  class Attributes
    class << self
      def add(**attributes)
        Thread.current[:watchdog_attributes].merge!(attributes)
      end

      def with(**new_attributes)
        current_attributes = get
        add(**new_attributes)

        yield
      ensure
        Thread.current[:watchdog_attributes] = current_attributes
      end

      def get
        Thread.current[:watchdog_attributes] || {}
      end

      def reset
        Thread.current[:watchdog_attributes] = {}
      end
    end
  end
end
