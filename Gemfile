source 'https://rubygems.org'

gem 'rails',                '4.0.0.beta1'

# Database Adapter
# Install instructions for Windows: http://blog.mmediasys.com/2011/07/07/installing-mysql-on-windows-7-x64-and-using-ruby-with-it/
gem 'mysql2',               '0.3.11'
gem 'thin',                 '~> 1.5.0',           platforms: [ :mswin, :mingw ]
gem 'eventmachine',         '~> 1.0.0',           platforms: [ :mswin, :mingw ]

# Gems used by project
gem 'contour',              '2.0.0.beta.4'
gem 'devise',               '~> 2.2.3',           github: 'plataformatec/devise',             ref: 'd29b744'   # , branch: 'rails4'
gem 'kaminari',             '~> 0.14.1'
gem 'carrierwave',          '~> 0.7.1'
gem 'ruby-ntlm-namespace',  '~> 0.0.1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',         '~> 4.0.0.beta1'
  gem 'coffee-rails',       '~> 4.0.0.beta1'
  gem 'uglifier',           '>= 1.0.3'
end

gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0.2'

# Testing
group :test do
  # Pretty printed test output
  gem 'win32console',                             platforms: [ :mswin, :mingw ]
  gem 'turn',               '~> 0.9.6'
  gem 'simplecov',          '~> 0.7.1',           require: false
end
