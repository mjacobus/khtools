# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Railtie.load

module KhTools
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.middleware.use OmniAuth::Builder do
      if Rails.application.credentials.dig(:oauth, :google, :key)
        provider :google_oauth2,
                 Rails.application.credentials.dig(:oauth, :google, :key),
                 Rails.application.credentials.dig(:oauth, :google, :secret)

      end
    end

    config.i18n.available_locales = ['pt-BR']
    config.i18n.default_locale = 'pt-BR'
    config.time_zone = 'America/Sao_Paulo'

    config.generators do |generate|
      generate.helper false
      generate.assets false
      generate.view_specs false
    end

    config.autoload_paths << Rails.root.join('lib').to_s

    config.add_autoload_paths_to_load_path = true
  end
end
