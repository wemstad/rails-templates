#----------------------------------------------------------------------------
# Setup Simple Form
#----------------------------------------------------------------------------
puts 'setting up Simple Form gem...'
append_file 'Gemfile', "\n# Simple Form gem\n"
gem "simple_form"

puts "installing gem(s) (could be a while)..."
#bundle_install
generate 'simple_form:install'

git :add => '.'
git :commit => "-am 'set up simple_form'"
