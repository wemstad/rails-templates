#----------------------------------------------------------------------------
# Set up Omnisocial
#----------------------------------------------------------------------------
puts "setting up Gemfile for Omnisocial..."
append_file 'Gemfile', "\n# Bundle gem needed for Devise\n"
gem 'omnisocial'

puts "installing Omnisocial gem (takes a few minutes!)..."
run 'bundle install'

puts "creating Omnisocial configuration files..."
run 'rails generate omnisocial'

puts "modifying environment configuration files for Omnisocial..."
extension = @haml_flag ? 'haml' : 'erb'
gsub_file "app/views/layouts/application.html.#{extension}", /(, :cache => true)/, ", 'omnisocial'#{$1}"

unless @twitter_app_key.blank?
  inject_into_file 'config/initializers/omnisocial.rb', "  config.twitter '#{@twitter_app_key}', '#{@twitter_app_secret}'\n", :after => "# config.twitter 'APP_KEY', 'APP_SECRET'\n"
end

unless @facebook_app_key.blank?
  inject_into_file 'config/initializers/omnisocial.rb', "  config.facebook '#{@facebook_app_key}', '#{@facebook_app_secret}', :scope => 'publish_stream'\n", :after => "# config.facebook 'APP_KEY', 'APP_SECRET', :scope => 'publish_stream'\n"
end

puts "adding and configuring view files..."
run "mkdir 'app/views/users'"
get 'http://github.com/stephenaument/rails-templates/raw/master/templates/_user_bar_os.html.haml', 'app/views/users/_user_bar.html.haml'

run "mkdir 'app/views/omnisocial"
get 'http://github.com/stephenaument/rails-templates/raw/master/templates/os_new.html.haml', 'app/views/omnisocial/_new.html.haml'

if @haml_flag
  inject_into_file 'app/views/layouts/application.html.haml', :after => "%body\n", do
<<-EOF
  
  #modal-signin.modal{:style => 'display: none;'}
    = render :partial => 'omnisocial/new'
EOF
else
    inject_into_file 'app/views/layouts/application.html.erb', :after => "<body>\n", do
  <<-EOF

    <div id='modal-signin' class='modal' style='display: none;'>
      <%= render :partial => 'omnisocial/new' %>
    </div>
  EOF
end

puts "creating database tables"
rake 'db:migrate'

git :add => '.'
git :commit => "-am 'Add omnisocial'"
