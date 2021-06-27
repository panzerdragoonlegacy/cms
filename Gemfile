source 'https://rubygems.org'

gem 'rails', '6.1.3.2'
gem 'rake', '13.0.1'

group :development do
  gem 'brakeman' # It is recommended to always use the latest version.
  gem 'bundler-audit'
  gem 'listen'
  gem 'rubocop', '~> 0.89.1', require: false
  gem 'spring', '~> 2.1.1'
  gem 'web-console', '~> 4.0.4'
end

group :development, :test do
  gem 'byebug', '~> 11.1.3'
  gem 'dotenv-rails', '~> 2.7.6'
  gem 'factory_bot_rails', '~> 6.1.0'
  gem 'rspec-rails', '~> 4.0.1'
end

group :test do
  gem 'pundit-matchers', '~> 1.6.0'
  gem 'rspec_junit_formatter' # Used for formatting CircleCI output
  gem 'shoulda-matchers', '~> 4.4.1'
end

gem 'bcrypt', '~> 3.1.15'
gem 'bootsnap', '~> 1.7.5'
gem 'bootstrap', '~> 4.5.2'
gem 'cocoon', '~> 1.2.14'
gem 'devise', '~> 4.7.2'
gem 'font-awesome-sass', '~> 5.13.0'
gem 'jquery-rails', '~> 4.4.0'
gem 'kaminari', '~> 1.2.1'
gem 'kramdown', '~> 2.3.1'
gem 'local_time', '~> 2.1.0'
gem 'mini_magick', '~> 4.10.1'

# Mini Racer currently causes a stack smashing detected error when running
# rails assets:precompile within Dockerfile when the host machine is an M1 Mac.
# https://github.com/rubyjs/mini_racer/issues/190
# gem 'mini_racer', '~> 0.4.0'

gem 'nokogiri', '1.11.4'
gem 'onebox', '~> 2.0.2'
gem 'kt-paperclip', '~> 7.0.0'
gem 'paper_trail', '~> 12.0.0'
gem 'pg', '~> 1.2.3'
gem 'pundit', '~> 2.1.0'
gem 'puma', '< 6'
gem 'rails_autolink', '~> 1.1.6'
gem 'ransack', '~> 2.4.2'
gem 'sanitize', '~> 5.2.1'
gem 'sassc', '~> 2.4.0'
gem 'sassc-rails', '~> 2.1.2'
gem 'stringex', '~> 2.8.5'
gem 'uglifier', '>= 4.2.0'
gem 'webpacker', '6.0.0.beta.7'
