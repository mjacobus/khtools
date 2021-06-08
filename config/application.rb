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
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.middleware.use OmniAuth::Builder do
      if ENV['OAUTH_GOOGLE_KEY']
        provider :google_oauth2, ENV['OAUTH_GOOGLE_KEY'], ENV['OAUTH_GOOGLE_SECRET']
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

    config.autoload_paths << Rails.root.join('lib')

    Dir[Rails.root.join('packages/*')].each do |package_path|
      package = File.basename(package_path)
      private_path = Rails.root.join("packages/#{package}/private").to_s
      public_path = Rails.root.join("packages/#{package}/public").to_s
      test_support = Rails.root.join("packages/#{package}/test/support/lib/").to_s
      Rails.autoloaders.main.push_dir(private_path) if Dir.exist?(private_path)
      Rails.autoloaders.main.push_dir(public_path) if Dir.exist?(public_path)
      Rails.autoloaders.main.push_dir(test_support) if Dir.exist?(test_support)
      # Autoload all subdirs of the app directory within a package.
      Dir["#{package_path}/app/*"].each do |package_app_subdir|
        Rails.autoloaders.main.push_dir(package_app_subdir)
      end
    end
  end
end
