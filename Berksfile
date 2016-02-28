source "https://supermarket.chef.io"

metadata

cookbook 'java', '~> 1.39.0'
cookbook 'tar', '~> 0.7.0'

# main cookbook doesn't work for Centos 7.1
# cookbook 'postgresql', '~> 4.0.0'
cookbook 'postgresql', git: 'git@github.com:AdamNettles/postgresql.git', branch: 'centos7fixes'

cookbook 'ssh_authorized_keys', '~> 0.3.0'

cookbook 'sudo', '~> 2.9.0'

cookbook 'ssh', '~> 0.10.10'