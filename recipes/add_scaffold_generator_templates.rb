#----------------------------------------------------------------------------
# Add default scaffolding template overrides.
#----------------------------------------------------------------------------
puts "copying scaffold generator templates..."
run 'rm lib/templates/haml/scaffold/_form.html.haml'
#get 'https://github.com/stephenaument/rails-templates/raw/master/templates/haml/scaffold/_form.html.haml', 'lib/templates/haml/scaffold/_form.html.haml'
#get 'https://github.com/stephenaument/rails-templates/raw/master/templates/haml/scaffold/edit.html.haml', 'lib/templates/haml/scaffold/edit.html.haml'
#get 'https://github.com/stephenaument/rails-templates/raw/master/templates/haml/scaffold/index.html.haml', 'lib/templates/haml/scaffold/index.html.haml'
#get 'https://github.com/stephenaument/rails-templates/raw/master/templates/haml/scaffold/new.html.haml', 'lib/templates/haml/scaffold/new.html.haml'
#get 'https://github.com/stephenaument/rails-templates/raw/master/templates/haml/scaffold/show.html.haml', 'lib/templates/haml/scaffold/show.html.haml'
#get 'https://github.com/stephenaument/rails-templates/raw/master/templates/rails/scaffold_controller/controller.rb', 'lib/templates/rails/scaffold_controller/controller.rb'
#get 'https://github.com/stephenaument/rails-templates/raw/master/templates/rspec/scaffold/controller_spec.rb', 'lib/templates/rspec/scaffold/controller_spec.rb'
#get 'https://github.com/stephenaument/rails-templates/raw/master/templates/rspec/scaffold/edit_spec.rb', 'lib/templates/rspec/scaffold/edit_spec.rb'
#get 'https://github.com/stephenaument/rails-templates/raw/master/templates/rspec/scaffold/index_spec.rb', 'lib/templates/rspec/scaffold/index_spec.rb'
#get 'https://github.com/stephenaument/rails-templates/raw/master/templates/rspec/scaffold/new_spec.rb', 'lib/templates/rspec/scaffold/new_spec.rb'
#get 'https://github.com/stephenaument/rails-templates/raw/master/templates/rspec/scaffold/routing_spec.rb', 'lib/templates/rspec/scaffold/routing_spec.rb'
#get 'https://github.com/stephenaument/rails-templates/raw/master/templates/rspec/scaffold/show_spec.rb', 'lib/templates/rspec/scaffold/show_spec.rb'
#get 'https://github.com/stephenaument/rails-templates/raw/master/images/btn-add.png', 'public/images/btn-add.png'

git :add => "."
git :commit => "-m 'add scaffold generator templates'"
