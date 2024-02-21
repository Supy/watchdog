# Watchdog
Rails default logging is not great outside of the development loop. It is noisy and its formatting makes parsing a 
challenge in log management solutions. Watchdog aims to standardise and simplify the logging format for Rails by both
reducing its default output and providing formatters for popular log management solutions.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'watchdog-rails', require: 'watchdog', git: 'https://github.com/Supy/watchdog.git', ref: '58ddfef'
```

Set the required log formatter in either `config/environments/production.rb` or `config/application.rb`:

```ruby
# For easy to read key-value pairs
config.watchdog.log_formatter = :simple

# For Datadog's JSON format
config.watchdog.log_formatter = :datadog
```

## Credits
This gem was heavily inspired by and draws from the [lograge](https://github.com/roidrage/lograge) gem.