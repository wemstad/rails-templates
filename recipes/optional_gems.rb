#----------------------------------------------------------------------------
# Setup Optional Gems
#----------------------------------------------------------------------------
unless true
  puts "setting up Optional Gems: #{@optional_gems}..."

  append_file 'Gemfile', "\n# Optional Gems\n"
  @optional_gems.each do |a_gem|
    gem "#{a_gem}"
  end  
  
  puts "installing gem(s) (could be a while)..."
  bundle_install

  git :add => '.'
  git :commit => "-am 'Add whenever'"
end
