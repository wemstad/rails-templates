#----------------------------------------------------------------------------
# Set up Devise
#----------------------------------------------------------------------------
puts "setting up Gemfile for Devise..."
append_file 'Gemfile', "\n# Bundle gem needed for Devise\n"
gem 'devise'

puts "installing Devise gem (takes a few minutes!)..."
run 'bundle install'

puts "creating 'config/initializers/devise.rb' Devise configuration file..."
run 'rails generate devise:install'
# run 'rails generate devise:views'

puts "modifying environment configuration files for Devise..."
gsub_file 'config/environments/development.rb', /# Don't care if the mailer can't send/, '### ActionMailer Config'
gsub_file 'config/environments/development.rb', /config.action_mailer.raise_delivery_errors = false/ do
<<-RUBY
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  # A dummy setup for development - no deliveries, but logged
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"
RUBY
end
gsub_file 'config/environments/production.rb', /config.i18n.fallbacks = true/ do
<<-RUBY
config.i18n.fallbacks = true

  config.action_mailer.default_url_options = { :host => 'yourhost.com' }
  ### ActionMailer Config
  # Setup for production - deliveries, no errors raised
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default :charset => "utf-8"
RUBY
end

run "mkdir 'app/views/users'"
get 'https://github.com/stephenaument/rails-templates/raw/master/templates/_user_bar.html.haml', 'app/views/users/_user_bar.html.haml'

puts "creating a User model and modifying routes for Devise..."
run 'rails generate devise User'
run 'rails generate migration add_admin_to_users admin:boolean'
rake 'db:migrate'

git :add => '.'
git :commit => "-am 'Add devise'"

#----------------------------------------------------------------------------
# Create a default user
#----------------------------------------------------------------------------
puts "creating a default user"
append_file 'db/seeds.rb' do <<-FILE
puts 'SETTING UP DEFAULT USER LOGIN'
user = User.create! :email => 'step@stephenaument.com', :password => 'please', :password_confirmation => 'please'
puts 'New user created: ' << user.email
FILE
end
rake 'db:seed'

git :add => '.'
git :commit => "-am 'Add a default user'"

