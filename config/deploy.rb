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

  desc "Minify javascript and css files."
  task :minify_public_files do
    Dir.glob("public/javascripts/**/*.js").each do |js_file|
      path = "#{release_path}/#{js_file}"
      run "yui-compressor --type js #{path} -o #{path}"
    end
    Dir.glob("public/stylesheets/**/*.css").each do |css_file|
      path = "#{release_path}/#{css_file}"
      run "yui-compressor --type css #{path} -o #{path}"
    end
  end
end
after 'deploy:update_code', 'deploy:minify_public_files'
