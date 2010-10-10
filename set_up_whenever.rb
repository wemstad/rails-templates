#----------------------------------------------------------------------------
# Setup Whenever Gem
#----------------------------------------------------------------------------
puts "setting up Whenever..."
append_file 'Gemfile', "\n# Whenever\n"
gem 'whenever'

puts "installing gem(s) (could be a while)..."
bundle_install

puts "wheneverizing..."
run 'wheneverize .'

append_file 'config/deploy.rb' do<<-FILE

after "deploy:symlink", "deploy:update_crontab"

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd \#{release_path} && whenever --update-crontab \#{application}"
  end
end
FILE
end

git :add => '.'
git :commit => "-am 'Add whenever'"
