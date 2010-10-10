#----------------------------------------------------------------------------
# Setup Will Paginate
#----------------------------------------------------------------------------
puts "setting up Will Paginate..."
append_file 'Gemfile', "\n# Will Paginate gem\n"
gem "will_paginate", ">= 3.0.pre2"

puts "installing gem(s) (could be a while)..."
bundle_install

git :add => '.'
git :commit => "-am 'set up Will Paginate'"
