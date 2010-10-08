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

#generate :nifty_layout

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
# Add application.css
#----------------------------------------------------------------------------
puts 'creating default application.css file...'
get 'http://github.com/stephenaument/rails-templates/raw/master/stylesheets/application.css', 'public/stylesheets/application.css'

#----------------------------------------------------------------------------
# 960gridder setup
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
  gem 'haml', '3.0.18'
  gem 'haml-rails', '0.2', :group => :development
  # the following gems are used to generate Devise views for Haml
  gem 'hpricot', '0.8.2', :group => :development
  gem 'ruby_parser', '2.0.5', :group => :development
  
  append_file app_initializer_file, "\nHaml::Template::options[:ugly] = true\n"
  
  bundle_install
  
  puts "removing application erb layout file..."
  run 'rm app/views/layouts/application.html.erb'

  puts "creating application haml layout file..."
  get 'http://github.com/stephenaument/rails-templates/raw/master/templates/application.html.haml', 'app/views/layouts/application.html.haml'
  gsub_file 'app/views/layouts/application.html.haml', /\$APP_NAME/, app_const_base.downcase

  git :add => '.'
  git :commit => "-am 'set up haml'"
end

#----------------------------------------------------------------------------
# Setup Simple Form
#----------------------------------------------------------------------------
puts 'setting up Simple Form gem...'
append_file 'Gemfile', "\n# Simple Form gem"
gem "simple_form"
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
bundle_install

run 'mkdir app/views/pages'
create_file 'app/views/pages/show.html.haml', 'Welcome!'

route "root :to => 'high_voltage/pages#show', :id => :index"

git :add => '.'
git :commit => "-am 'set up High Voltage'"

#----------------------------------------------------------------------------
# Setup Will Paginate
#----------------------------------------------------------------------------
puts "setting up Will Paginate"
append_file 'Gemfile', "\n# Will Paginate gem\n"
gem "will_paginate", ">= 3.0.pre2"
bundle_install

git :add => '.'
git :commit => "-am 'set up Will Paginate'"

#----------------------------------------------------------------------------
# Depify me
#----------------------------------------------------------------------------
run 'depify .'

inject_into_file 'config/deploy.rb', "\nrequire 'vendor/plugins/capistrano-db-tasks/lib/dbtasks'\n", :after => "require 'deprec'"
gsub_file 'config/deploy.rb', /set your application name here/, app_const_base.downcase
gsub_file 'config/deploy.rb', /git:\/\/github.com\/\#{user}\/\#{application}.git/, "#{remote_git_location}#{repo_name}"
inject_into_file 'config/deploy.rb', "set :rails_env, 'production'\n", :after => %Q("#{remote_git_location}#{repo_name}"\n)
inject_into_file 'config/deploy.rb', "set :gems_for_project, %w(mysql mysql2 haml)\n", :after => "# set :gems_for_project, %w(rmagick mini_magick image_science) # list of gems to be installed\n"
inject_into_file 'config/deploy.rb', "\nset :deploy_to, \"/var/www/vhosts/\#{application}\"\n", :after => "role :db,  domain, :primary => true, :no_release => true\n"
