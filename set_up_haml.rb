#----------------------------------------------------------------------------
# Haml Option
#----------------------------------------------------------------------------
@app_initializer_file ||= File.join('config', 'initializers', "#{app_const_base.downcase}_defaults.rb")

puts "setting up Gemfile for Haml..."
append_file 'Gemfile', "\n# Bundle gems needed for Haml\n"
gem 'haml'
gem 'haml-rails', :group => :development
gem 'sass'
# the following gems are used to generate Devise views for Haml
gem 'hpricot', '0.8.2', :group => :development
gem 'ruby_parser', '2.0.5', :group => :development

append_file @app_initializer_file, "\nHaml::Template::options[:ugly] = true\n"

puts "installing gem(s) (could be a while)..."
self.respond_to?(:bundle_install) ? bundle_install : run('bundle install')

puts "removing application erb layout file..."
run 'rm app/views/layouts/application.html.erb'

puts "creating application haml layout file..."
get 'https://github.com/stephenaument/rails-templates/raw/master/templates/application.html.haml', 'app/views/layouts/application.html.haml'
gsub_file 'app/views/layouts/application.html.haml', /\$APP_NAME/, app_const_base.downcase

puts "creating empty menu file..."
run "touch 'app/views/layouts/_menu.html.haml'"

puts "adding the LayoutHelper..."
file 'app/helpers/layout_helper.rb',
<<-EOF
# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def title(page_title, show_title = true)
    content_for :title, page_title.to_s
    @show_title = show_title
  end
  
  def show_title?
    @show_title
  end
  
  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end
  
  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end
  
  def menu_item(klass, opts = {})
    if can? :manage, klass
      html = ''
      html += ' | ' if !opts[:first]
      opts[:label] ||= klass.to_s.tableize.humanize.titleize
      html += link_to(opts[:label],eval("\#{klass.to_s.tableize}_path"))
    end
  end
end
EOF

git :add => '.'
git :commit => "-am 'set up haml'"
