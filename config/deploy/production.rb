server '107.170.205.136',
  user: 'deploy',
  roles: %w{web app db},
  ssh_options: {
    keys: %w(~/.ssh/id_rsa),
    forward_agent: true,
    auth_methods: %w(publickey)
  }

set :linked_files, fetch(:linked_files, []).push('config/settings/production.yml')
