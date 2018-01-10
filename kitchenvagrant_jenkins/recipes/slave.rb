include_recipe 'java::default'
include_recipe 'bluefinops_jenkins::docker'

mykey = data_bag_item('bluefinops_jenkins', 'jenkins')['private_key']
key = OpenSSL::PKey::RSA.new(mykey)
node.default['bluefinops_jenkins']['jenkins']['public_key'] = "#{key.ssh_type} #{[key.to_blob].pack('m0')}"
node.default['bluefinops_jenkins']['jenkins']['private_key'] = key.to_pem

group node['bluefinops_jenkins']['group']

user node['bluefinops_jenkins']['user'] do
  home "/home/#{node['bluefinops_jenkins']['user']}"
  manage_home true
  shell '/bin/bash'
  group node['bluefinops_jenkins']['group']
  password node['bluefinops_jenkins']['password']
  action :create
end

directory "/home/#{node['bluefinops_jenkins']['user']}/.ssh" do
  owner node['bluefinops_jenkins']['user']
  group node['bluefinops_jenkins']['group']
  mode '0700'
  action :create
end

file "/home/#{node['bluefinops_jenkins']['user']}/.ssh/authorized_keys" do
  owner node['bluefinops_jenkins']['user']
  group node['bluefinops_jenkins']['group']
  mode '0600'
  content node['bluefinops_jenkins']['jenkins']['public_key']
  action :create
end

directory node['bluefinops_jenkins']['jenkins_home'] do
  owner node['bluefinops_jenkins']['user']
  group node['bluefinops_jenkins']['group']
  mode '0775'
  action :create
end
