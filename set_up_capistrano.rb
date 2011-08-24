#----------------------------------------------------------------------------
# Set up Capistrano
#----------------------------------------------------------------------------
puts "setting up capistrano..."
append_file 'Gemfile', "\n# Capistrano gem\n"
gem 'capistrano'

puts "installing capistrano gem (could be a while)..."
bundle_install

puts "capifying..."
run 'capify .'

git :add => '.'
git :commit => "-am 'set up capistrano'"
