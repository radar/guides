require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Warden
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

   config.middleware.use Warden::Manager do |manager|
      manager.default_strategies :password

      manager.serialize_into_session do |user|
        user.id
      end

      manager.serialize_from_session do |id|
        User.find(id)
      end
    end
  end
end
