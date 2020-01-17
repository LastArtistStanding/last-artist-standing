source 'https://rubygems.org'

# Prerequisite for upgraded heroku stack
ruby "2.6.5"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 5.0.0.rc2', '< 5.1'
#Use Rails controller testing for testing stability and error-proneness of site.
gem 'rails-controller-testing'
# Use bcrypt for Password hashing to protect against attackers
# Pulling directly from the author's github to solve a Windows issue
gem 'bcrypt', git: 'https://github.com/codahale/bcrypt-ruby.git', :require => 'bcrypt'

gem 'bootstrap', '>= 4.3.1'
# For popovers
gem 'popper_js', '>= 1.12.9'
gem 'rails-assets-tether', '>= 1.3.3', source: 'https://rails-assets.org'
gem 'autoprefixer-rails'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'actionview'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# Gems for assisting with Image Upload on the site.
gem 'carrierwave'
gem 'mini_magick', '>= 4.9.4'
#Formating timestamps for site 
gem 'strftime', '~>1.0.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'rake', '< 11.0' 
# Puma for the app server
gem 'puma', '>= 3.12.2'

###########################
  # 1/21/18 - - Use Postgres as the database for Active Record
  # Fix found based off of: 
  #https://stackoverflow.com/questions/39261996/heroku-and-rails-gem-load-error-with-postgres-however-it-is-specified-in-gemfi
  #https://stackoverflow.com/questions/24755673/gemloaderror-specified-postgresql-for-database-adapter-but-the-gem-is-not/24755814
  
###########################
gem 'pg', '0.21'
gem 'figaro'
gem 'fog-aws'
gem 'fog'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rspec-rails', '2.13.1'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :production do
  gem 'rails_12factor'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

## Gemfile for Rails 3+, Sinatra, or Merb
gem 'will_paginate', '~> 3.1.1'

## Security updates
gem "nokogiri", ">= 1.10.4"
gem "rack", ">= 2.0.8"
gem "loofah", ">= 2.3.1"
gem "excon", ">= 0.71.0"
gem "sentry-raven"