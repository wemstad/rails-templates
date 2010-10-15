# Application Generator Template
# Modifies a Rails app to include my personal preferences.
# Usage: rails new app_name -m http://github.com/stephenaument/rails-templates/raw/master/base.rb
#
# Thanks to ryanb: http://github.com/ryanb and to  from whom this repository is forked and
# fortuity whose rails3-mongoid-devise template 
# http://github.com/fortuity/rails3-mongoid-devise/raw/master//template.rb
# was consulted, as well.
#
# More info: http://github.com/stephenaument/rails-templates/

# If you are customizing this template, you can use any methods provided by Thor::Actions
# http://rdoc.info/rdoc/wycats/thor/blob/f939a3e8a854616784cac1dcff04ef4f3ee5f7ff/Thor/Actions.html
# and Rails::Generators::Actions
# http://github.com/rails/rails/blob/master/railties/lib/rails/generators/actions.rb
source_paths << File.dirname(__FILE__)

DONT_DO_LONG_THINGS = nil #== nil ? true : nil

#----------------------------------------------------------------------------
# Method for calling bundle_install so I can comment it out in one place when
# building the file out.
#----------------------------------------------------------------------------
module ::Rails
  module Generators
    module Actions
      def bundle_install
        run 'bundle install' unless DONT_DO_LONG_THINGS
      end
    end
  end
end

puts "Modifying a new Rails app to use my personal preferences..."

#----------------------------------------------------------------------------
# Configure
#
# Note: The remote git repository setup assumes a location that you have
# ssh access to and can write to. In my setup, I use ssh keys to connect
# so I'm not prompted for login information for the scp call. Not sure
# what would happen in that case. It would probably die.
#----------------------------------------------------------------------------
@remote_git_location = "jeslyncsoftware.com:/home/saument/git/"
@app_initializer_file = File.join('config', 'initializers', "#{app_const_base.downcase}_defaults.rb")

@db_pass = ask("What password would you like to use for the railsdbuser?")
if yes?("Do you want to create a remote copy of the repository? (yes/no)")
  @repo_name = ask("What do you want to call the remote git repository? [#{app_const_base.downcase}.git]")
  @repo_name = "#{app_const_base.downcase}.git" if @repo_name.blank?
  
  tmp = ask("Where would you like to put the remote repository? [#{@remote_git_location}]")
  @remote_git_location = tmp unless tmp.blank?
  
  @git_remote_flag = true
else
  @git_remote_flag = false
end

#if yes?('Would you like to use the Haml template system? (yes/no)')
  @haml_flag = true
#else
#  @haml_flag = false
#end

@authentication_scheme = 'd'
tmp = ask("Which authentication scheme? (d = devise+openauth, o = opensocial) [#{@authentication_scheme}]")
@authentication_scheme = tmp unless tmp.blank?

if @authentication_scheme.eql? 'o'
  @twitter_app_key = ask("Enter your twitter consumer key:")
  @twitter_app_secret = ask("Enter your twitter consumer secret:") unless @twitter_app_key.blank?
  @facebook_app_key = ask("Enter your facebook app key:")
  @facebook_app_secret = ask("Enter your facebook app secret:") unless @facebook_app_key.blank?
end

@optional_gems = []
tmp = ask("Optional gems to install?: (i.e. acts_as_follower thumbs_up paperclip)")
unless tmp.blank?
  @optional_gems += tmp.split
end

#----------------------------------------------------------------------------
# Run the templates.
#----------------------------------------------------------------------------
puts "unknown authentication scheme #{@authentication_scheme}" unless ['d','o'].include? @authentication_scheme
apply "set_up_git.rb"
apply "set_up_capistrano.rb"
apply "set_up_testing.rb"
apply "remove_the_usual_cruft.rb"
apply "set_up_mysql2.rb"
apply "add_application_css_and_js.rb"
apply "set_up_960_gridder.rb"
apply "set_up_haml.rb" if @haml_flag
apply "set_up_simple_form.rb"
apply "set_up_flutie.rb"
apply "set_up_high_voltage.rb"
apply "set_up_will_paginate.rb"
apply "depify_me.rb"
apply "set_up_whenever.rb"
apply "set_up_bwi_base.rb"
apply "add_scaffold_generator_templates.rb"
apply "set_up_devise.rb" if @authentication_scheme.eql? 'd'
apply "set_up_omnisocial.rb" if @authentication_scheme.eql? 'o'
apply "set_up_cancan.rb"
apply "set_up_optional_gems.rb"

#----------------------------------------------------------------------------
# Finish up
#----------------------------------------------------------------------------
unless DONT_DO_LONG_THINGS
  puts "checking everything into git..."
  git :add => '.'
  git :commit => "-am 'Finish setup script and push repository'"
  git :push
end
puts "Done setting up your Rails app."
