server '54.68.42.238',
  user: 'ubuntu',
  roles: %w{web app db},
  ssh_options: {
    keys: %w(~/.ssh/aws-pbalaban.pem),
    forward_agent: true,
    auth_methods: %w(publickey)
  }

set :linked_files, fetch(:linked_files, []).push('config/settings/staging.yml')
