# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.0.2'

gem 'activeadmin'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'caxlsx'
gem 'dotenv-rails'
gem 'omniauth', '~> 1.9.2'
gem 'omniauth-google-oauth2'
gem 'pg', '~> 1.2'
gem 'puma', '~> 5.6'
gem 'rails', '~> 7.0'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binpath'

# file upload
gem 'carrierwave', '~> 2.0'
gem 'carrierwave-i18n'
gem 'cloudinary'

# HTTP Clients
gem 'koine-rest_client'

# frontend
# gem 'bootstrap', '~> 4.4'
# gem 'jquery-rails'
gem 'sass-rails', '>= 6'
gem 'simple_form'
# gem 'turbolinks', '~> 5'
gem 'kaminari'
gem 'view_component', require: 'view_component/engine'
gem 'webpacker', '~> 4.0'
gem "rqrcode", "~> 2.0"

group :development, :test do
  gem 'awesome_print'
  gem 'bullet'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rails-controller-testing'
  gem 'rspec-rails', '4.0'
end

group :development do
  gem 'listen', '~> 3.4'
  gem 'rubocop', '~> 1.8.1', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.1'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'object_comparator'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'webdrivers'
end
