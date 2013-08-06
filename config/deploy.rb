set :application, "fresh-fruit"
server "kross.platan.us", :web, :app, :db, primary: true
set :user,        "deploy"
set :deploy_to,   "/home/#{user}/applications/#{application}"

set :scm, 'git'
set :branch, "production"
set :remote, 'origin'

set :domains, 		"fresh-fruit.platan.us"

set :deploy_via, :remote_cache
set :repository, "https://github.com/aarellano/fresh-fruit.git"

# Default environment
set :rails_env, 'production' unless respond_to?(:rails_env)

## Default path
set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

# Run on Linux: `$ ssh-add` or on OSX: `$ ssh-add -K` for "forward_agent".
ssh_options[:forward_agent] = true
ssh_options[:port]          = 22
default_run_options[:pty]   = true

# Use the bundler capistrano task to deploy to the shared folder
require "bundler/capistrano"

# Negroku base task
def template(from, to)
	erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
	put ERB.new(erb).result(binding), to
end

# Wrapper method to set default values for recipes.
def set_default(name, *args, &block)
	set(name, *args, &block) unless exists?(name)
end

# Review and modify the tasks below on a per-app/language/framework basis.
namespace :deploy do
	after "deploy:update_code", "deploy:migrate"

	after "deploy:setup", "deploy:setup_shared"
	desc "Sets up additional folders/files after deploy:setup."
	task :setup_shared do
		run "mkdir -p '#{shared_path}/config'"
	end
end

# Negroku log tasknamespace :log do
namespace :log do
	desc "Stream (tail) the application's production log."
	task :app do
		trap("INT") { puts 'Exit'; exit 0; }
		stream "tail -f '#{shared_path}/log/production.log'"
	end

	desc "Stream (tail) the nginx access log."
	task :nginx_access do
		trap("INT") { puts 'Exit'; exit 0; }
		stream "tail -f '#{shared_path}/log/nginx-access.log'"
	end

	desc "Stream (tail) the nginx error log."
	task :nginx_error do
		trap("INT") { puts 'Exit'; exit 0; }
		stream "tail -f '#{shared_path}/log/nginx-error.log'"
	end
end

# Negroku nginx task
set_default :domains, ["your.domain.com"]
set_default :static_dir, "public"

set_default :app_server, true
#set_default :app_server_port, 8080
set_default :app_server_socket, "/home/#{fetch(:user)}/tmp/negroku.#{fetch(:application)}.sock"

# set_default :use_ssl, true
# set_default :ssl_key, "/path/to/local/ssh.key"
# set_default :ssl_crt, "/path/to/local/ssh.crt"

# Nginx
namespace :nginx do
  %w[start stop restart reload].each do |command|
  	desc "#{command} Nginx."
  	task command, roles: :web do
  		run "#{sudo} service nginx #{command}"
  	end
  end
end

# Negroku namespace :rbenv do
namespace :rbenv do
	namespace :vars do
		desc "Show current rbenv vars"
		task :show, :roles => :app do
			run "sh -c 'cd #{shared_path} && cat .rbenv-vars'"
		end

		desc "Add rbenv vars"
		task :add, :roles => :app do
			run "if awk < #{shared_path}/.rbenv-vars -F= '{print $1}' | grep --quiet #{key}; then sed -i 's/^#{key}=.*/#{key}=#{value}/g' #{shared_path}/.rbenv-vars; else echo '#{key}=#{value}' >> #{shared_path}/.rbenv-vars; fi"
		end

		after "deploy:finalize_update", "rbenv:vars:symlink"
		desc "Symlink rbenv-vars file into the current release"
		task :symlink, :roles => :app do
			run "ln -nfs '#{shared_path}/.rbenv-vars' '#{release_path}/.rbenv-vars'"
		end
	end
end


# Negroku unicorn task

# Number of workers (Rule of thumb is 2 per CPU)
# Just be aware that every worker needs to cache all classes and thus eat some
# of your RAM.
set_default :unicorn_workers, 1

# Workers timeout in the amount of seconds below, when the master kills it and
# forks another one.
set_default  :unicorn_workers_timeout, 30

# Workers are started with this user
# By default we get the user/group set in capistrano.
set_default  :unicorn_user, nil

# The wrapped bin to start unicorn
set_default  :unicorn_bin, 'bin/unicorn'
set_default  :unicorn_socket, fetch(:app_server_socket)

# Defines where the unicorn pid will live.
set_default  :unicorn_pid, File.join(current_path, "tmp", "pids", "unicorn.pid")

# Preload app for fast worker spawn
set_default :unicorn_preload, true

set_default :unicorn_config_path, "#{shared_path}/config"

# Unicorn
#------------------------------------------------------------------------------
# Load unicorn tasks
require "capistrano-unicorn"

namespace :unicorn do
  after "deploy:setup", "unicorn:setup"
  desc "Setup unicorn configuration for this application."
   task :setup, roles: :app do
    template "unicorn.erb", "/tmp/unicorn.rb"
    run "#{sudo} mv /tmp/unicorn.rb #{shared_path}/config/"
  end

  after "deploy:cold", "unicorn:start"
  after 'deploy:restart', 'unicorn:restart'
end