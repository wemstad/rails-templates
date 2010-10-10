#----------------------------------------------------------------------------
# Add default scaffolding template overrides.
#----------------------------------------------------------------------------
puts "copying scaffold generator templates..."
run 'rm lib/templates/haml/scaffold/_form.html.haml'
get 'http://github.com/stephenaument/rails-templates/raw/master/templates/haml/scaffold/_form.html.haml', 'lib/templates/haml/scaffold/_form.html.haml'
get 'http://github.com/stephenaument/rails-templates/raw/master/templates/haml/scaffold/edit.html.haml', 'lib/templates/haml/scaffold/edit.html.haml'
get 'http://github.com/stephenaument/rails-templates/raw/master/templates/haml/scaffold/index.html.haml', 'lib/templates/haml/scaffold/index.html.haml'
get 'http://github.com/stephenaument/rails-templates/raw/master/templates/haml/scaffold/new.html.haml', 'lib/templates/haml/scaffold/new.html.haml'
get 'http://github.com/stephenaument/rails-templates/raw/master/templates/haml/scaffold/show.html.haml', 'lib/templates/haml/scaffold/show.html.haml'
get 'http://github.com/stephenaument/rails-templates/raw/master/templates/rails/scaffold_controller/controller.rb', 'lib/templates/rails/scaffold_controller/controller.rb'
get 'http://github.com/stephenaument/rails-templates/raw/master/images/btn-add.png', 'public/images/btn-add.png'

git :add => "."
git :commit => "-m 'add scaffold generator templates'"
