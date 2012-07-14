#----------------------------------------------------------------------------
# Set up git.
#----------------------------------------------------------------------------
puts "setting up source control with 'git'..."
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
gsub_file ".gitignore", /db\/\*.sqlite3/, "db/*.sql*"

# specific to Mac OS X
append_file '.gitignore' do
  '.DS_Store'
end

git :init
git :add => "."
git :commit => "-m 'initial commit'"

if @git_remote_flag
  run "git clone --bare . #{@repo_name}"
  puts "copying new repository to server (takes a few seconds)..."
  run "scp -r #{@repo_name} #{@remote_git_location}." unless DONT_DO_LONG_THINGS
  git :remote => "add origin #{@remote_git_location}#{@repo_name}"
  run "rm -rf #{@repo_name}"
end

