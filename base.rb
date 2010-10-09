# Application Generator Template
# Modifies a Rails app to include my personal preferences.
# Usage: rails new app_name -m http://github.com/stephenaument/rails-templates/raw/master/base.rb
#
# Thanks to ryanb: http://github.com/ryanb and to  from whom this repository is forked and
# fortuity whose rails3-mongoid-devise template 
# http://github.com/fortuity/rails3-mongoid-devise/raw/master//template.rb
# was consulted, as well.
#
# More info: http://github.com/stephenaument/rails-templates/

# If you are customizing this template, you can use any methods provided by Thor::Actions
# http://rdoc.info/rdoc/wycats/thor/blob/f939a3e8a854616784cac1dcff04ef4f3ee5f7ff/Thor/Actions.html
# and Rails::Generators::Actions
# http://github.com/rails/rails/blob/master/railties/lib/rails/generators/actions.rb

DONT_DO_LONG_THINGS = nil #== nil ? true : nil

#----------------------------------------------------------------------------
# Method for calling bundle_install so I can comment it out in one place when
# building the file out.
#----------------------------------------------------------------------------
module ::Rails
  module Generators
    module Actions
      def bundle_install
        run 'bundle install' unless DONT_DO_LONG_THINGS
      end
    end
  end
end

puts "Modifying a new Rails app to use my personal preferences..."

#----------------------------------------------------------------------------
# Configure
#
# Note: The remote git repository setup assumes a location that you have
# ssh access to and can write to. In my setup, I use ssh keys to connect
# so I'm not prompted for login information for the scp call. Not sure
# what would happen in that case. It would probably die.
#----------------------------------------------------------------------------
remote_git_location = "jeslyncsoftware.com:/home/saument/git/"
app_initializer_file = File.join('config', 'initializers', "#{app_const_base.downcase}_defaults.rb")

db_pass = ask("What password would you like to use for the railsdbuser?")
if yes?("Do you want to create a remote copy of the repository? (yes/no)")
  repo_name = ask("What do you want to call the remote git repository? [#{app_const_base.downcase}.git]")
  repo_name = "#{app_const_base.downcase}.git" if repo_name.blank?
  
  tmp = ask("Where would you like to put the remote repository? [#{remote_git_location}]")
  remote_git_location = tmp if !tmp.blank?
  
  git_remote_flag = true
else
  git_remote_flag = false
end

if yes?('Would you like to use the Haml template system? (yes/no)')
  haml_flag = true
else
  haml_flag = false
end


#----------------------------------------------------------------------------
# Set up Cucumber, Rspec, Factory Girl and Shoulda
#----------------------------------------------------------------------------
puts "setting up Gemfile for Testing..."

append_file 'Gemfile', "\n# Bundle gems needed for Testing\n"

gem 'autotest', :group => [:cucumber, :test, :development]
gem 'cucumber-rails', :version => '>=0.2.4', :group => [:cucumber, :test, :development]
gem 'database_cleaner', :version => '>=0.4.3', :group => [:cucumber, :test, :development]
gem 'webrat', :version => '>=0.6.0', :group => [:cucumber, :test, :development]
gem 'shoulda', :group => [:cucumber, :test, :development]
gem 'rspec', :version => '>= 2.0.0.beta.22', :group => [:cucumber, :test, :development]
gem 'rspec-rails', :version => ">= 2.0.0.beta.22", :group => [:cucumber, :test, :development]
gem 'pickle', :version => ">=0.2.1", :group => [:cucumber, :test, :development]
gem 'factory_girl_rails', :group => [:cucumber, :test, :development]
gem 'nokogiri', :version => ">= 1.4.0", :group => [:cucumber, :test, :development]

puts "installing testing gems (takes a few minutes!)..."

bundle_install

puts "generating rspec..."
unless DONT_DO_LONG_THINGS then
  generate 'rspec:install'
  run 'mkdir spec/factories'
  inject_into_file 'spec/spec_helper.rb', :after => "require 'rspec/rails'\n" do
<<-RUBY
  require 'rspec/rails'
  Dir[File.join Rails.root, 'spec', 'factories', '*.rb'].each do |file|
    require file
  end
RUBY
  end
end

#----------------------------------------------------------------------------
# Set up git.
#----------------------------------------------------------------------------
git :init

puts "setting up source control with 'git'..."
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
gsub_file ".gitignore", /db\/\*.sqlite3/, "db/*.sql*"

# specific to Mac OS X
append_file '.gitignore' do
  '.DS_Store'
end
git :add => "."
git :commit => "-m 'initial commit'"

if git_remote_flag
  run "git clone --bare . #{repo_name}"
  puts "copying new repository to server (takes a few seconds)..."
  run "scp -r #{repo_name} #{remote_git_location}." unless DONT_DO_LONG_THINGS
  git :remote => "add origin #{remote_git_location}#{repo_name}"
  run "rm -rf #{repo_name}"
end

#----------------------------------------------------------------------------
# Remove the usual cruft
#----------------------------------------------------------------------------
puts "removing unneeded files..."
run 'rm config/database.yml'
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm public/images/rails.png'
run 'rm README'
create_file 'README',  'TODO add readme content'
run "touch #{app_initializer_file}"

puts "banning spiders from your site by changing robots.txt..."
gsub_file 'public/robots.txt', /# User-Agent/, 'User-Agent'
gsub_file 'public/robots.txt', /# Disallow/, 'Disallow'

git :add => '.'
git :commit => "-am 'remove unneeded files. ban spiders from site'"

#----------------------------------------------------------------------------
# Set up mysql2
#----------------------------------------------------------------------------
puts "setting up mysql2"
gsub_file 'Gemfile', /^gem 'sqlite3/, "# gem 'sqlite3"
append_file 'Gemfile', "\n# Mysql2 database gem\n"
gem 'mysql2'

file 'config/database.yml', <<-RUBY
defaults: &DEFAULT
    adapter: mysql2
    encoding: utf8
    username: railsdbuser
    password: $DB_PW
    host: localhost

development:
  <<: *DEFAULT
  database: $APPNAME_development

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test: &TEST
    <<: *DEFAULT
    database: $APPNAME_test

staging:
  <<: *DEFAULT
  database: $APPNAME_staging

production:
  <<: *DEFAULT
  database: $APPNAME

cucumber:
  <<: *TEST
RUBY

gsub_file 'config/database.yml', /\$APPNAME/, app_const_base.downcase
gsub_file 'config/database.yml', /\$DB_PW/, db_pass

puts "installing mysql2 gem (could be a while)..."
bundle_install

puts "creating the databases..."
rake 'db:create:all' unless DONT_DO_LONG_THINGS
rake 'db:migrate' unless DONT_DO_LONG_THINGS

git :add => '.'
git :commit => "-am 'set up mysql2'"

#----------------------------------------------------------------------------
# Add application.css and application.js
#----------------------------------------------------------------------------
puts 'creating default application.css file...'
get 'http://github.com/stephenaument/rails-templates/raw/master/stylesheets/application.css', 'public/stylesheets/application.css'
run 'rm public/javascripts/application.js'
get 'http://github.com/stephenaument/rails-templates/raw/master/javascripts/application.js', 'public/javascripts/application.js'

#----------------------------------------------------------------------------
# Setup 960gridder
#----------------------------------------------------------------------------
puts "setting up 960gridder"
get 'http://github.com/nathansmith/960-Grid-System/raw/master/code/css/960.css', 'public/stylesheets/960.css'
get 'http://github.com/stephenaument/rails-templates/raw/master/javascripts/960.js', 'public/javascripts/960.js'


#----------------------------------------------------------------------------
# Haml Option
#----------------------------------------------------------------------------
if haml_flag
  puts "setting up Gemfile for Haml..."
  append_file 'Gemfile', "\n# Bundle gems needed for Haml\n"
  gem 'haml'
  gem 'haml-rails', :group => :development
  # the following gems are used to generate Devise views for Haml
  gem 'hpricot', '0.8.2', :group => :development
  gem 'ruby_parser', '2.0.5', :group => :development
  
  append_file app_initializer_file, "\nHaml::Template::options[:ugly] = true\n"
  
  puts "installing gem(s) (could be a while)..."
  bundle_install
  
  puts "removing application erb layout file..."
  run 'rm app/views/layouts/application.html.erb'

  puts "creating application haml layout file..."
  get 'http://github.com/stephenaument/rails-templates/raw/master/templates/application.html.haml', 'app/views/layouts/application.html.haml'
  gsub_file 'app/views/layouts/application.html.haml', /\$APP_NAME/, app_const_base.downcase
  
  puts "creating empty menu file..."
  run "touch 'app/views/layouts/_menu.html.haml'"

  git :add => '.'
  git :commit => "-am 'set up haml'"
end

#----------------------------------------------------------------------------
# Setup Simple Form
#----------------------------------------------------------------------------
puts 'setting up Simple Form gem...'
append_file 'Gemfile', "\n# Simple Form gem\n"
gem "simple_form"

puts "installing gem(s) (could be a while)..."
bundle_install
generate 'simple_form:install'

git :add => '.'
git :commit => "-am 'set up simple_form'"

#----------------------------------------------------------------------------
# Setup Flutie
#----------------------------------------------------------------------------
puts 'setting up Flutie gem...'
append_file 'Gemfile', "\n# Flutie - app stylings from thoughtbot\n"
gem 'flutie'
bundle_install

rake 'flutie:install'

git :add => '.'
git :commit => "-am 'set up flutie'"

#----------------------------------------------------------------------------
# Setup High Voltage pages controller
#----------------------------------------------------------------------------
puts "setting up High Voltage..."
append_file 'Gemfile', "\n# High Voltage - pages controller from thoughbot\n"
gem 'high_voltage'

puts "installing gem(s) (could be a while)..."
bundle_install

run 'mkdir app/views/pages'
create_file 'app/views/pages/index.html.haml', '%h1 Welcome!'

route "root :to => 'high_voltage/pages#show', :id => :index"

git :add => '.'
git :commit => "-am 'set up High Voltage'"

#----------------------------------------------------------------------------
# Setup Will Paginate
#----------------------------------------------------------------------------
puts "setting up Will Paginate..."
append_file 'Gemfile', "\n# Will Paginate gem\n"
gem "will_paginate", ">= 3.0.pre2"

puts "installing gem(s) (could be a while)..."
bundle_install

git :add => '.'
git :commit => "-am 'set up Will Paginate'"

#----------------------------------------------------------------------------
# Depify me
#----------------------------------------------------------------------------
puts "depifying..."
run 'depify .'

inject_into_file 'config/deploy.rb', "\nrequire 'vendor/plugins/capistrano-db-tasks/lib/dbtasks'\n", :after => "require 'deprec'"
gsub_file 'config/deploy.rb', /set your application name here/, app_const_base.downcase
gsub_file 'config/deploy.rb', /git:\/\/github.com\/\#{user}\/\#{application}.git/, "#{remote_git_location}#{repo_name}"
inject_into_file 'config/deploy.rb', "set :rails_env, 'production'\n", :after => %Q("#{remote_git_location}#{repo_name}"\n)
inject_into_file 'config/deploy.rb', "set :gems_for_project, %w(mysql mysql2 haml)\n", :after => "# set :gems_for_project, %w(rmagick mini_magick image_science) # list of gems to be installed\n"
inject_into_file 'config/deploy.rb', "\nset :deploy_to, \"/var/www/vhosts/\#{application}\"\n", :after => "role :db,  domain, :primary => true, :no_release => true\n"

git :add => '.'
git :commit => "-am 'Depify'"

#----------------------------------------------------------------------------
# Setup Whenever Gem
#----------------------------------------------------------------------------
puts "setting up Whenever..."
append_file 'Gemfile', "\n# Whenever\n"
gem 'whenever'

puts "installing gem(s) (could be a while)..."
bundle_install

puts "wheneverizing..."
run 'wheneverize .'

append_file 'config/deploy.rb' do<<-FILE

after "deploy:symlink", "deploy:update_crontab"

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd \#{release_path} && whenever --update-crontab \#{application}"
  end
end
FILE
end

git :add => '.'
git :commit => "-am 'Add whenever'"

#----------------------------------------------------------------------------
# Setup BWI Base Gem
#----------------------------------------------------------------------------
puts "setting up bwi base..."
append_file 'Gemfile', "\n# BWI Base\n"
gem 'bwi-base', :git => 'git://github.com/stephenaument/bwi-base.git'

puts "installing gem(s) (could be a while)..."
bundle_install

git :add => '.'
git :commit => "-am 'Add bwi base gem'"

#----------------------------------------------------------------------------
# Add default scaffolding template overrides.
#----------------------------------------------------------------------------
puts "copying scaffold generator templates..."
run 'rm lib/templates/haml/scaffold/_form.html.haml'
get 'http://github.com/stephenaument/rails-templates/raw/master/templates/haml/scaffold/_form.html.haml', 'lib/templates/haml/scaffold/_form.html.haml'
get 'http://github.com/stephenaument/rails-templates/raw/master/templates/haml/scaffold/edit.html.haml', 'lib/templates/haml/scaffold/edit.html.haml'
get 'http://github.com/stephenaument/rails-templates/raw/master/templates/haml/scaffold/index.html.haml', 'lib/templates/haml/scaffold/index.html.haml'
get 'http://github.com/stephenaument/rails-templates/raw/master/templates/haml/scaffold/new.html.haml', 'lib/templates/haml/scaffold/new.html.haml'
get 'http://github.com/stephenaument/rails-templates/raw/master/templates/haml/scaffold/show.html.haml', 'lib/templates/haml/scaffold/show.html.haml'
get 'http://github.com/stephenaument/rails-templates/raw/master/templates/rails/scaffold_controller/controller.rb', 'lib/templates/rails/scaffold_controller/controller.rb'
get 'http://github.com/stephenaument/rails-templates/raw/master/images/btn-add.png', 'public/images/btn-add.png'

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
get 'http://github.com/stephenaument/rails-templates/raw/master/templates/_user_bar.html.haml', 'app/views/users/_user_bar.html.haml'

puts "creating a User model and modifying routes for Devise..."
run 'rails generate devise User'
run 'rails generate migration add_admin_to_users admin:boolean'
rake 'db:migrate'

git :add => '.'
git :commit => "-am 'Add devise'"


#----------------------------------------------------------------------------
# Setup cancan
#----------------------------------------------------------------------------
puts "setting up cancan..."
append_file 'Gemfile', "\n# Cancan\n"
gem 'cancan'
bundle_install

file 'app/model/ability.rb', <<-RUBY
class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.admin?
        can :manage, :all
      else
        can :read, :all
      end
    end
  end
end
RUBY

inject_into_file 'app/controllers/application_controller.rb', :after => 'protect_from_forgery\n' do <<-RUBY
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url
  end
RUBY
end

git :add => '.'
git :commit => "-am 'Add cancan'"

#----------------------------------------------------------------------------
# Create a default user
#----------------------------------------------------------------------------
puts "creating a default user"
append_file 'db/seeds.rb' do <<-FILE
puts 'SETTING UP DEFAULT USER LOGIN'
user = User.create! :email => 'step@stephenaument.com', :password => 'please', :password_confirmation => 'please'
puts 'New user created: ' << user.name
FILE
end
rake 'db:seed'

git :add => '.'
git :commit => "-am 'Add a default user'"

#----------------------------------------------------------------------------
# Finish up
#----------------------------------------------------------------------------
puts "checking everything into git..."
git :add => '.'
git :commit => "-am 'Finish setup script and push repository'"
git :push

puts "Done setting up your Rails app."
