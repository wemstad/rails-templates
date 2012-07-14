append_file 'Gemfile', <<-EOF

group :development, :test do
  gem 'debugger'
  gem 'rspec-rails', '>= 2.8.0'
end

group :test do
  gem 'cucumber-rails'
  gem 'capybara'

  gem 'fabrication'
  gem 'ffaker'
  gem 'database_cleaner'

  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'guard-cucumber'

  gem 'simplecov'
end
EOF
