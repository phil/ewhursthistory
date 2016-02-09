source 'https://rubygems.org'

ruby "2.3.0"

gem 'rack-rewrite'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'

gem "pg"

gem "unicorn"

gem 'rails_12factor', group: :production
gem 'newrelic_rpm', group: :production

gem "postmark-rails"

# Assets
gem 'sass-rails', '~> 4.0.3' # Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets
gem 'coffee-rails', '~> 4.0.0' # Use CoffeeScript for .js.coffee assets and views
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
#gem 'therubyracer',  platforms: :ruby

#gem "twitter-bootstrap-rails"
#
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
#gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
group :development do
  gem 'spring'
  gem "spring-commands-rspec"
end

gem 'activeadmin', github: 'gregbell/active_admin'
gem 'active_admin_editor'
gem "devise" # For active admin

gem 'ancestry' # Active Record Tree structure
gem 'kaminari'
gem "carrierwave"
gem "fog" # Fo Amazon S3
gem "mini_magick"

gem "exception_notification"

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use debugger
# gem 'debugger', group: [:development, :test]
#

group :test, :development do
  gem "rspec-rails"
  gem "steak"
end
