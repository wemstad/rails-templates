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
gem 'spork', :group => [:cucumber, :test, :development]
gem 'rails3-generators'
gem 'rcov'

puts "installing testing gems (takes a few minutes!)..."
bundle_install

puts "generating rspec..."
unless DONT_DO_LONG_THINGS then
  generate 'rspec:install'
  run 'mkdir spec/factories'
  
  # TODO - Figure out why I'm having to include the Shoulda matchers here. Wrong
  # version of rspec?? Fix it right later. No time now.
  puts "configuring spork and shoulda..."
  prepend_file 'spec/spec_helper.rb' do
<<-EOF
require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
EOF
  end
  inject_into_file 'spec/spec_helper.rb', :after => "require 'rspec/rails'\n" do
<<-EOF
  require 'shoulda'
  Dir[File.join Rails.root, 'spec', 'factories', '*.rb'].each do |file|
    require file
  end
  
  include Shoulda::ActiveRecord::Matchers
  include Shoulda::ActionController::Matchers
  include Shoulda::ActionMailer::Matchers
EOF
  end
  
  append_file 'spec/spec_helper.rb' do
<<-EOF
  class ActionController::Base
    def login(user=Factory(:user))
      @current_user = user
    end

    def logout!
      @current_user     = nil
    end

    def current_user
      @current_user
    end
  end 


  ### Part of a Spork hack. See http://bit.ly/arY19y
  # Emulate initializer set_clear_dependencies_hook in 
  # railties/lib/rails/application/bootstrap.rb
  ActiveSupport::Dependencies.clear
end

Spork.each_run do
  # This code will be run each time you run your specs.
end
EOF
  end
  
  append_file '.rspec', "\n--drb\n"
end

puts "configuring factory_girl generators..."
inject_into_file 'config/application.rb', :after => "config.action_view.javascript_expansions[:defaults] = %w(jquery rails)\n" do
<<-EOF
    config.generators do |g|
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.webrat_matchers true
    end
EOF
end

#puts "installing rcov with rcovert extension..."
#rcov_dir = `bundle show rcov`
#run "cd #{rcov_dir}; sudo ruby setup.rb"
