# frozen_string_literal: true

source 'https://rubygems.org'

# Prerequisite for upgraded heroku stack
ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 6.0.3.4'
# Use Rails controller testing for testing stability and error-proneness of site.
gem 'rails-controller-testing'
# Use bcrypt for Password hashing to protect against attackers
gem 'bcrypt', '~> 3.1'

gem 'bootstrap', '>= 4.3.1'
# For popovers
gem 'autoprefixer-rails'
gem 'popper_js', '>= 1.12.9'
# Use SCSS for stylesheets
gem 'sassc-rails', '>= 2.1.2', '< 2.2'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '>= 5.0.0', '< 5.1'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'actionview', '>= 6.0.3.3'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# Gems for assisting with Image Upload on the site.
gem 'carrierwave'
gem 'mini_magick', '>= 4.9.4'
# Formating timestamps for site
gem 'strftime', '~>1.0.0'

gem 'rake', '>= 13.0.1', '< 13.1'

gem 'redcarpet', '~> 3.5.0'
# Puma for the app server
gem 'puma', '>= 4.3.3', '< 4.4'

###########################
# 1/21/18 - - Use Postgres as the database for Active Record
# Fix found based off of:
# https://stackoverflow.com/questions/39261996/heroku-and-rails-gem-load-error-with-postgres-however-it-is-specified-in-gemfi
# https://stackoverflow.com/questions/24755673/gemloaderror-specified-postgresql-for-database-adapter-but-the-gem-is-not/24755814

###########################
gem 'figaro'
gem 'fog-aws', '>= 3.5.2', '< 3.6'
gem 'pg', '>= 1.2.2', '< 1.3'

# Used to support cross-site authentication.
gem 'jwt', '~> 2.2.1'
gem 'rack-cors', '~> 1.1.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'dotenv-rails'
  gem 'rspec-rails', '>= 5.0.2'
  gem 'rubocop', '>= 1.19.1', require: false
  gem 'rubocop-rails', '>= 2.11.3', require: false
  gem 'rubocop-rspec', '>= 2.4.0', require: false
end

group :test do
  gem 'database_cleaner-active_record', '~> 1.8.0'
  gem 'factory_bot', '~> 5.2'
  gem 'simplecov', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '>= 4.0.1', '< 4.1'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :production do
  # "[...] configures Rails for CloudFlare so that request.remote_ip [... works] correctly."
  gem 'cloudflare-rails', '~> 0.6.0'
  gem 'rails_12factor'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

## Gemfile for Rails 3+, Sinatra, or Merb
gem 'will_paginate', '>= 3.3.0', '< 3.4'

## Security updates
gem 'excon', '>= 0.71.0'
gem 'loofah', '>= 2.3.1'
gem 'nokogiri', '>= 1.10.9', '< 2.0'
gem 'rack', '>= 2.2.3'
gem 'sentry-raven'
gem 'slim-rails'
