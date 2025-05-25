require_relative "boot"

require "rails/all"
require 'securerandom'
require 'ostruct'
require 'active_support/parameter_filter'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HitFactorBack
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.credentials.content_path = 'config/credentials/local.yml.enc'
    
    config.active_record.encryption.primary_key = 'dBFLZv0h3uhbdY2Ce7ji6ib9KiR7dlcF'
    config.active_record.encryption.deterministic_key = 'XoFuI50ZBczn3pVin0EkAP8fy3jVl8JH'
    config.active_record.encryption.key_derivation_salt = 'IaTqzts4DcbsClt1byuDTCJwnPWh7IjG'
  end
end
