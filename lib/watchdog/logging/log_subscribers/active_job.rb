# frozen_string_literal: true

require 'active_support/log_subscriber'

require 'watchdog/event'

module Watchdog
  module Logging
    module LogSubscribers
      class ActiveJob < ActiveSupport::LogSubscriber
        def enqueue(event)
          info do
            job_message('job.enqueued', event)
          end
        end

        def enqueue_at(event)
          info do
            job_message('job.enqueue_scheduled', event)
          end
        end

        def enqueue_retry(event)
          info do
            job_message('job.retry_enqueued', event)
          end
        end

        def perform_start(event)
          info do
            job_message('job.started', event)
          end
        end

        def perform(event)
          info do
            job_message('job.finished', event)
          end
        end

        def retry_stopped(event)
          info do
            job_message('job.retry_stopped', event)
          end
        end

        def discard(event)
          info do
            job_message('job.discarded', event)
          end
        end

        private

        def job_message(action, event)
          job = event.payload[:job]

          Watchdog::Event.new(
            action,
            {
              class: job.class,
              arguments: job.arguments&.join(', '),
              queue: job.queue_name,
              id: job.job_id
            }
          )
        end
      end
    end
  end
end
