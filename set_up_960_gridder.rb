#----------------------------------------------------------------------------
# Setup 960gridder
#----------------------------------------------------------------------------
puts "setting up 960gridder"
get 'http://github.com/nathansmith/960-Grid-System/raw/master/code/css/960.css', 'public/stylesheets/960.css'
get 'http://github.com/stephenaument/rails-templates/raw/master/javascripts/960.js', 'public/javascripts/960.js'
