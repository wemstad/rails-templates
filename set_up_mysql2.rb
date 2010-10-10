#----------------------------------------------------------------------------
# Set up mysql2
#----------------------------------------------------------------------------
puts "setting up mysql2..."
gsub_file 'Gemfile', /^gem 'sqlite3/, "# gem 'sqlite3"
append_file 'Gemfile', "\n# Mysql2 database gem\n"
gem 'mysql2'

file 'config/database.yml', <<-RUBY
defaults: &DEFAULT
    adapter: mysql2
    encoding: utf8
    username: railsdbuser
    password: $DB_PW
    host: localhost

development:
  <<: *DEFAULT
  database: $APPNAME_development

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test: &TEST
    <<: *DEFAULT
    database: $APPNAME_test

staging:
  <<: *DEFAULT
  database: $APPNAME_staging

production:
  <<: *DEFAULT
  database: $APPNAME

cucumber:
  <<: *TEST
RUBY

gsub_file 'config/database.yml', /\$APPNAME/, app_const_base.downcase
gsub_file 'config/database.yml', /\$DB_PW/, @db_pass

puts "installing mysql2 gem (could be a while)..."
bundle_install

puts "creating the databases..."
rake 'db:create:all' unless DONT_DO_LONG_THINGS
rake 'db:migrate' unless DONT_DO_LONG_THINGS

git :add => '.'
git :commit => "-am 'set up mysql2'"

