user node['bluefinops_sudo']['user']

group node['bluefinops_sudo']['group'] do
  members ["#{node['bluefinops_sudo']['user']}"]
end    
sudo node['bluefinops_sudo']['user'] do
  user node['bluefinops_sudo']['user']
  nopasswd node['bluefinops_sudo']['passwordless']
end
