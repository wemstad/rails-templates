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
generate 'rspec:install' unless DONT_DO_LONG_THINGS
run 'mkdir spec/factories'
inject_into_file 'spec/spec_helper.rb', :after => "require 'rspec/rails'\n" do
<<-RUBY
  require 'rspec/rails'
  Dir[File.join Rails.root, 'spec', 'factories', '*.rb'].each do |file|
    require file
  end
RUBY
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
  run "scp -r #{repo_name} #{remote_git_location}."
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
  create_file 'app/views/layouts/application.html.haml' do <<-FILE
!!! Strict
%html{:xmlns => "http://www.w3.org/1999/xhtml"}

  %head
    %title=h yield(:title) || "$APP_NAME"
    = stylesheet_link_tag :flutie, 'application', :cache => true
    = javascript_include_tag :defaults
    = csrf_meta_tag
    = yield(:head)

  %body

    \#header
      \#user-bar= render :partial => 'users/user_bar'
      \#title= link_to '$APP_NAME', root_url

    \#container.content
      \#menu

      %hr
      
      - flash.each do |name, msg|
        = content_tag :div, msg, :id => "flash_\#{name}", :class => "\#{name}"
      
      - if show_title?
        %h1= yield(:title)
      
      = yield

    \#footer
      &copy;2010
      = link_to 'Stephen Aument', 'http://www.stephenaument.com'
FILE
end

  gsub_file 'app/views/layouts/application.html.haml', /\$APP_NAME/, app_const_base.downcase

  git :add => '.'
  git :commit => "-am 'set up haml'"
end

#----------------------------------------------------------------------------
# Add application.css
#----------------------------------------------------------------------------
puts 'creating default application.css file...'
create_file 'public/stylesheets/application.css' do <<-FILE
  body {
    background-color: #dadada;
  }

  form ol li.date label {
  	display: inline;
  }

  h2 {
    border-bottom: solid 1px #dadada;
    padding-bottom: 2px;
  }

  th.actions {
  	width: 50px;
  }

  .btn-add, .btn-add-inv {
  	float: right;
  	margin: auto 10px;
  }

  .btn-add a, .btn-add-inv a {
  	background: transparent url(/images/btn-add.png) 0 0;
  	display:block;
  	height: 24px;
  	width: 23px;
  }

  .btn-add a {
  	background: transparent url(/images/btn-add.png) 0 0;
  }

  .btn-add-inv a {
  	background: transparent url(/images/btn-add.png) 0 -24px;
  }

  .btn-add a:hover {
  	background: transparent url(/images/btn-add.png) 0 -24px;
  }

  .btn-add-inv a:hover {
  	background: transparent url(/images/btn-add.png) 0 0;
  }

  .clear {
    clear: both;
    height: 0;
    overflow: hidden;
  }

  .content {
    background: #fff;
    padding: 40px;
    margin: 0 auto 10px auto;
    width: 720px;
    -moz-border-radius: 24px;
    -webkit-border-radius: 24px;
  }

  .pagination {
  	margin-top: -1.5em;
  	margin-bottom: 2em;
  }

  #footer {
    padding: 0 40px;
    margin: 10px auto;
    text-align: center;
    width: 720px;
  }

  #header {
    color: #7E90A6;
    height: 40px;
    margin: 15px auto 0 auto;
    padding: 0 40px;
    position: relative;
    width: 720px;
  }

  #menu {
  	margin-bottom: 0.5em;
  }

  #menu a {
  	text-decoration: none;
  }

  #title a {
  	bottom: 0;
    color: #7E90A6;
      font-family: "Helvetica Neue", Helvetica, Arial, sans-serif; 
  	font-size: 2.7em;
  	left: 40px;
  	letter-spacing: .2em;
  	position: absolute;
  	text-decoration: none;
  }

  #user-bar {
  	bottom: 4px;
  	position: absolute;
  	right: 40px;
  }
FILE
end

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
run 'mkdir app/views/pages'
create_file 'app/views/pages/show.html.haml', 'Welcome!'

route "root :to => 'high_voltage/pages#show', :id => :index"

git :add => '.'
git :commit => "-am 'set up High Voltage'"


#----------------------------------------------------------------------------
# Depify me
#----------------------------------------------------------------------------
#run 'depify .'