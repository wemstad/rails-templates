#----------------------------------------------------------------------------
# Depify me
#----------------------------------------------------------------------------
puts "depifying..."
run 'depify .'

inject_into_file 'config/deploy.rb', "\nrequire '~/.recipes/capistrano-db-tasks/lib/dbtasks'\n", :after => "require 'deprec'"
gsub_file 'config/deploy.rb', /set your application name here/, app_const_base.downcase
gsub_file 'config/deploy.rb', /git:\/\/github.com\/\#{user}\/\#{application}.git/, "#{@remote_git_location}#{@repo_name}"
inject_into_file 'config/deploy.rb', "set :rails_env, 'production'\n", :after => %Q("#{@remote_git_location}#{@repo_name}"\n)
inject_into_file 'config/deploy.rb', "set :gems_for_project, %w(mysql mysql2 haml)\n", :after => "# set :gems_for_project, %w(rmagick mini_magick image_science) # list of gems to be installed\n"
inject_into_file 'config/deploy.rb', "\nset :deploy_to, \"/var/www/vhosts/\#{application}\"\n", :after => "role :db,  domain, :primary => true, :no_release => true\n"

git :add => '.'
git :commit => "-am 'Depify'"
