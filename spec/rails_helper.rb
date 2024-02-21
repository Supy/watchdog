# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "./dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("./dummy/db/migrate", __dir__)]

require 'rspec/rails'

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include ActiveSupport::Testing::TimeHelpers
end