#----------------------------------------------------------------------------
# Add application.css and application.js
#----------------------------------------------------------------------------
puts 'creating default application.css file...'
get 'http://github.com/stephenaument/rails-templates/raw/master/stylesheets/application.css', 'public/stylesheets/application.css'
run 'rm public/javascripts/application.js'
get 'http://github.com/stephenaument/rails-templates/raw/master/javascripts/application.js', 'public/javascripts/application.js'
