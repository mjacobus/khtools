directory '/home/deploy/apps/khtools/current'
rackup '/home/deploy/apps/khtools/current/config.ru'
environment 'production'

pidfile '/home/deploy/apps/khtools/shared/tmp/pids/puma.pid'
state_path '/home/deploy/apps/khtools/shared/tmp/pids/puma.state'
stdout_redirect '/home/deploy/apps/khtools/shared/log/puma.stdout.log',
                '/home/deploy/apps/khtools/shared/log/puma.stderr.log', true

bind 'unix:///home/deploy/apps/khtools/shared/tmp/sockets/puma.sock'
workers 0
threads 4, 16

preload_app!
daemonize true
