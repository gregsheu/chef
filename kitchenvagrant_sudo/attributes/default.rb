default['bluefinops_sudo']['user'] = 'greg'
default['bluefinops_sudo']['group'] = 'wheel'
default['bluefinops_sudo']['passwordless'] = nil
default['authorization']['sudo']['users'] = node['bluefinops_sudo']['user']
default['authorization']['sudo']['groups'] = node['bluefinops_sudo']['group']
default['authorization']['sudo']['passwordless'] = node['bluefinops_sudo']['passwordless']
