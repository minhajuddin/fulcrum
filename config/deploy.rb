#rvm stuff
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string,'ruby-1.9.2-p290' # Or whatever env you want it to run in.
set :rvm_type, :user
require 'bundler/capistrano'
set :use_sudo, false

set :application, "fulcrum"
set :user, 'ubuntu'
set :repository,  "git@github.com:minhajuddin/fulcrum.git"
set :branch, "master"
set :git_enable_submodules, 1
set :deploy_via, :remote_cache
set :deploy_to, '/var/www/apps/fulcrum'

set :unicorn_binary, "bundle exec unicorn"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

set :scm, :git

role :app, "c3"
role :web, "c3"
role :db, :primary => true
set :rails_env, :production

namespace :unicorn do
  task :setup, :roles => :app, :except => { :no_release => true } do
    run "mkdir -p #{shared_path}/sockets"
  end

  task :symlink, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/sockets #{release_path}/tmp/sockets"
  end

  after "deploy:finalize_update", "unicorn:symlink"
  after "deploy:setup",  "unicorn:setup"
end

namespace :foreman do

  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export, :roles => :app do
    run "cd #{release_path} && rvmsudo foreman export upstart /etc/init -e config/foreman.env -a #{application} -u #{user} -l #{shared_path}/log"
  end

  desc "Start the application services"
  task :start, :roles => :app do
    run "sudo start #{application}"
  end

  desc "Stop the application services"
  task :stop, :roles => :app do
    run "sudo stop #{application}"
  end

  desc "Restart the application services"
  task :restart, :roles => :app do
    run "sudo start #{application} || sudo restart #{application}"
  end

  after 'deploy:update', 'foreman:export'
  after 'deploy:update', 'foreman:restart'

end

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart do ; end

  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after 'deploy:update_code', 'deploy:symlink_shared'
end

namespace :carrierwave do
  task :setup, :roles => :app, :except => { :no_release => true } do
    run "mkdir -p #{shared_path}/uploads"
  end

  task :symlink, :except => { :no_release => true } do
    run "rm -rf #{release_path}/public/uploads && ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
  end

  after "deploy:finalize_update", "carrierwave:symlink"
  after "deploy:setup",  "carrierwave:setup"
end
