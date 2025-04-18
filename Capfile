require 'capistrano/setup'
require 'capistrano/deploy'

require 'capistrano/asdf'
require 'capistrano/rails'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

require 'capistrano/puma'
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Systemd
