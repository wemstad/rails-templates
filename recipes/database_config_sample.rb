copy_file 'templates/config/database.yml', 'config/database.yml'
copy_file 'templates/config/database.yml', 'config/database.yml.sample'
append_file '.gitignore', <<-EOF

# Ignore database config
config/database.yml
EOF
