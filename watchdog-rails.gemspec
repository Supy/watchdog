require_relative "lib/watchdog/version"

Gem::Specification.new do |spec|
  spec.name        = "watchdog-rails"
  spec.version     = Watchdog::VERSION
  spec.authors     = ["Supy"]
  spec.homepage    = "https://github.com/Supy/watchdog"
  spec.summary     = "A better way to monitor your Rails application."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{lib}/**/*", "LICENSE.txt", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6.1", "< 7.2"

  spec.add_development_dependency "rspec-rails", "~> 4.0.2"
end
