# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.4.3'

gem 'activeadmin'
gem 'bootsnap', require: false
gem 'caxlsx'
gem 'dotenv-rails'
gem 'matrix'
gem 'omniauth', '~> 1.9.2'
gem 'omniauth-google-oauth2'
gem 'puma', '~> 5.6'
gem 'rails', '~> 7.1.0'
gem 'sqlite3', '~> 1.6'
gem 'whenever', require: false
gem 'wicked_pdf'
gem 'wkhtmltopdf-binpath'

# monitoring
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'stackprof'

# file upload
gem 'carrierwave', '~> 2.2'
gem 'carrierwave-i18n'
gem 'cloudinary'

# HTTP Clients
gem 'koine-rest_client'

# frontend
gem 'importmap-rails'
gem 'kaminari'
gem 'rqrcode', '~> 2.0'
gem 'sass-rails', '>= 6'
gem 'simple_form'
gem 'view_component', require: 'view_component/engine'

group :development, :test do
  gem 'awesome_print'
  gem 'bullet'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '6.1'
end

group :development do
  gem 'listen', '~> 3.4'
  gem 'rubocop'
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  gem 'solargraph', require: false
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.1'
  gem 'web-console', '>= 3.3.0'

  # deployment
  gem 'bcrypt_pbkdf', '~> 1.1'
  gem 'capistrano', '~> 3.18'
  gem 'capistrano3-puma'
  gem 'capistrano-asdf'
  gem 'capistrano-rails'
  gem 'ed25519', '~> 1.2'
end

group :test do
  gem 'capybara'
  gem 'object_comparator'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'webdrivers'
end
