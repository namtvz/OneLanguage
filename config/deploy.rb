require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'mina/rvm'    # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, 'uxkkdd0eccaa.xuanchien.koding.io'
set :deploy_to, '/var/www/OneLanguage'
set :repository, 'git@github.com:namtvit07/OneLanguage.git'
set :branch, 'master'
set :app_path, lambda { "#{deploy_to}/#{current_path}" }

# For system-wide RVM install.
#   set :rvm_path, '/usr/local/rvm/bin/rvm'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'config/secrets.yml', 'config/application.yml', 'log']

# Optional settings:
set :user, 'xuanchien'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.
set :forward_agent, true     # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use[ruby-2.1.5]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/pids"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/sockets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/sockets"]


  queue! %[mkdir -p "#{deploy_to}/shared/tmp/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/log"]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml'."]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/secrets.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/secrets.yml'."]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/application.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/application.yml'."]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    to :launch do
      invoke :'puma:restart'
      invoke :'clockwork:stop'
      invoke :'clockwork:start'
    end
  end
end

namespace :puma do
  desc "Start the application"
  task :start do
    queue 'echo "-----> Start Puma"'
    queue "cd #{app_path} && RAILS_ENV=#{stage} && bin/puma.sh start", :pty => false
  end

  desc "Stop the application"
  task :stop do
    queue 'echo "-----> Stop Puma"'
    queue "cd #{app_path} && RAILS_ENV=#{stage} && bin/puma.sh stop"
  end

  desc "Restart the application"
  task :restart do
    queue 'echo "-----> Restart Puma"'
    queue "cd #{app_path} && RAILS_ENV=#{stage} && bin/puma.sh restart"
  end
end

namespace :clockwork do
  task :start do
    queue 'echo "-----> Start Clockwork"'
    queue "cd #{app_path} && RAILS_ENV=#{stage} bundle exec clockwork -c config/clockwork.rb start --log"
  end

  desc "Stop the application"
  task :stop do
    queue 'echo "-----> Stop Clockwork"'
    queue "cd #{app_path} && RAILS_ENV=#{stage} bundle exec clockwork -c config/clockwork.rb stop"
  end
end
# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers

