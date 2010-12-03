#----------------------------------------------------------------------------
# Setup cancan
#----------------------------------------------------------------------------
puts "setting up cancan..."
append_file 'Gemfile', "\n# Cancan\n"
gem 'cancan'
bundle_install

file 'app/models/ability.rb', <<-RUBY
class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.admin?
        can :manage, :all
      else
        can :read, :all
      end
    end
  end
end
RUBY

inject_into_file 'app/controllers/application_controller.rb', :after => 'protect_from_forgery\n' do
<<-RUBY
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url
  end
RUBY
end

git :add => '.'
git :commit => "-am 'Add cancan'"
