#----------------------------------------------------------------------------
# Setup BWI Base Gem
#----------------------------------------------------------------------------
puts "setting up bwi base..."
append_file 'Gemfile', "\n# BWI Base\n"
gem 'bwi-base', :git => 'git://github.com/stephenaument/bwi-base.git'

puts "installing gem(s) (could be a while)..."
bundle_install

git :add => '.'
git :commit => "-am 'Add bwi base gem'"
