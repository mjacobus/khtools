lock '~> 3.18.0'

set :application, 'khtools'
set :repo_url, 'git@github.com:mjacobus/khtools.git'
set :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :deploy_to, "/home/deploy/apps/#{fetch(:application)}"

# ASDF
set :asdf_version, '3.4.3'
set :default_env, {
  'ASDF_DIR' => '/home/deploy/.asdf',
  'PATH' => '/home/deploy/.asdf/bin:/home/deploy/.asdf/shims:$PATH'
}

append :linked_files, 'config/master.key'
append :linked_dirs,
       'log',
       'tmp/pids',
       'tmp/cache',
       'tmp/sockets',
       'vendor/bundle',
       'public/system',
       'storage'

# Puma com systemd --user
set :puma_user, fetch(:user)
set :puma_service_unit_name, "puma_#{fetch(:application)}"
set :puma_systemctl_user, :user
