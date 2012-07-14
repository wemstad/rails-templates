source_paths << File.join(File.dirname(__FILE__))

apply 'recipes/remove_default_index_page.rb'
apply 'recipes/update_readme.rb'
apply 'recipes/gemfile.rb'
apply 'recipes/database_config_sample.rb'
apply 'recipes/testing.rb'
apply 'recipes/simple_form.rb'
apply 'recipes/devise.rb'
apply 'recipes/cancan.rb'
