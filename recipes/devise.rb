gem 'devise'
run 'bundle install'

run 'rails generate devise:install'

gsub_file 'config/environments/development.rb', /config.action_mailer.raise_delivery_errors = false/, <<-RUBY
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default charset: 'utf-8'
RUBY

gsub_file 'config/environments/production.rb', /config.i18n.fallbacks = true/, <<-RUBY
  config.i18n.fallbacks = true

  config.action_mailer.default_url_options = { host: 'yourhost.com' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default charset: 'utf-8'
RUBY

run 'rails generate devise User'
rake 'db:migrate'
