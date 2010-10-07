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

puts "Modifying a new Rails app to use my personal preferences..."

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
#run 'bundle install'

generate :nifty_layout

git :init

run "echo 'TODO add readme content' > README"
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"

gsub_file ".gitignore", /db\/\*.sqlite3/, "db/*.sql*"

git :add => ".", :commit => "-m 'initial commit'"
