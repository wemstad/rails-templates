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
puts "installing testing gems (takes a few minutes!)..."

bundle_install

puts "generating rspec..."
unless DONT_DO_LONG_THINGS then
  generate 'rspec:install'
  run 'mkdir spec/factories'
  inject_into_file 'spec/spec_helper.rb', :after => "require 'rspec/rails'\n" do
<<-RUBY
  require 'shoulda'
  Dir[File.join Rails.root, 'spec', 'factories', '*.rb'].each do |file|
    require file
  end
RUBY
  end
end

puts "configuring factory_girl generators..."
inject_into_file 'config/application.rb', :after => "config.action_view.javascript_expansions[:defaults] = %w(jquery rails)\n" do
<<-RUBY
    config.generators do |g|
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.webrat_matchers true
    end
RUBY
end

