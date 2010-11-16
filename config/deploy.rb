require 'bundler/capistrano'

set :application, "smudge"
set :repository,  "git@github.com:mconnell/smudge.git"
set :user, 'smudge'
set :scm, :git

set :deploy_to, "/home/smudge/apps/#{application}"
set :rails_env, "production"

role :web, "smudge.it"                   # Your HTTP server, Apache/etc
role :app, "smudge.it"                   # This may be the same as your `Web` server
role :db,  "smudge.it", :primary => true # This is where Rails migrations will run

set :branch, :master
set :deploy_via, :remote_cache

set :use_sudo, false
set :port, 38721

ssh_options[:forward_agent] = true
default_run_options[:pty] = true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after "deploy:update_code" do
  # run "ln -sf #{shared_path}/database.yml #{release_path}/config/database.yml"
  # run "ln -sf #{shared_path}/assets #{release_path}/public/assets"

  Dir["#{current_path}/public/javascripts/**/*.js"].each do |js_file|
    run "yui-compressor --type js #{js_file} -o #{js_file}"
  end
  Dir["#{current_path}/public/stylesheets/**/*.css"].each do |css_file|
    run "yui-compressor --type css #{css_file} -o #{css_file}"
  end
end
