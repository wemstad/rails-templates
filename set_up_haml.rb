#----------------------------------------------------------------------------
# Haml Option
#----------------------------------------------------------------------------
if @haml_flag
  puts "setting up Gemfile for Haml..."
  append_file 'Gemfile', "\n# Bundle gems needed for Haml\n"
  gem 'haml'
  gem 'haml-rails', :group => :development
  # the following gems are used to generate Devise views for Haml
  gem 'hpricot', '0.8.2', :group => :development
  gem 'ruby_parser', '2.0.5', :group => :development
  
  append_file @app_initializer_file, "\nHaml::Template::options[:ugly] = true\n"
  
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
