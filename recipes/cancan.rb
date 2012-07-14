gem 'cancan'
run 'bundle install'

generate 'cancan:ability'

inject_into_file 'app/controllers/application_controller.rb', after: 'protect_from_forgery\n' do <<-RUBY
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end
RUBY
end
