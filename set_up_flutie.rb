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
