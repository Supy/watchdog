# frozen_string_literal: true

require 'active_support/concern'
require 'watchdog/attributes'

module Watchdog
  module Logging
    module Concerns
      module LogRequestId
        extend ActiveSupport::Concern

        included do
          before_action :set_request_id
        end

        def set_request_id
          Watchdog::Attributes.add(request_id: request.uuid)
        end
      end
    end
  end
end
