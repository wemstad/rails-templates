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
