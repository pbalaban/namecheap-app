lock '3.3.5'

set :application, 'namecheap-app'
set :repo_url, 'git@github.com:pbalaban/namecheap-app.git'

ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

set :linked_files, fetch(:linked_files, []).push(*%w{config/secrets.yml config/database.yml config/settings/production.yml})
set :linked_dirs, fetch(:linked_dirs, []).push(*%w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system})

after 'deploy:publishing', 'unicorn:legacy_restart'
after 'deploy:finished', 'unicorn:restart'
