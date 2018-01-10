include_recipe 'java::default'
include_recipe 'bluefinops_jenkins2::docker'

mykey = data_bag_item('bluefinops_jenkins2', 'jenkins')['private_key']
key = OpenSSL::PKey::RSA.new(mykey)
node.default['bluefinops_jenkins2']['jenkins']['public_key'] = "#{key.ssh_type} #{[key.to_blob].pack('m0')}"
node.default['bluefinops_jenkins2']['jenkins']['private_key'] = key.to_pem

group node['bluefinops_jenkins2']['group']

user node['bluefinops_jenkins2']['user'] do
  home "/home/#{node['bluefinops_jenkins2']['user']}"
  manage_home true
  shell '/bin/bash'
  group node['bluefinops_jenkins2']['group']
  password node['bluefinops_jenkins2']['password']
  action :create
end

directory "/home/#{node['bluefinops_jenkins2']['user']}/.ssh" do
  owner node['bluefinops_jenkins2']['user']
  group node['bluefinops_jenkins2']['group']
  mode '0700'
  action :create
end

file "/home/#{node['bluefinops_jenkins2']['user']}/.ssh/authorized_keys" do
  owner node['bluefinops_jenkins2']['user']
  group node['bluefinops_jenkins2']['group']
  mode '0600'
  content node['bluefinops_jenkins2']['jenkins']['public_key']
  action :create
end

file '/etc/ssh/ssh_host_rsa_key' do
  owner 'root'
  group 'ssh_keys'
  mode '0640'
  content node['bluefinops_jenkins2']['jenkins']['private_key']
  action :create
end

file '/etc/ssh/ssh_host_rsa_key.pub' do
  owner 'root'
  group 'root'
  mode '0644'
  content node['bluefinops_jenkins2']['jenkins']['public_key']
  action :create
end

directory node['bluefinops_jenkins2']['jenkins_home'] do
  owner node['bluefinops_jenkins2']['user']
  group node['bluefinops_jenkins2']['group']
  mode '0775'
  action :create
end
