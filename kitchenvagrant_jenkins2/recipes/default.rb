%w{
  java::default
  jenkins::master
}.each do |obj|
  include_recipe obj
end

mykey = data_bag_item('bluefinops_jenkins2', 'jenkins')['private_key']
key = OpenSSL::PKey::RSA.new(mykey)
node.default['bluefinops_jenkins2']['jenkins']['public_key'] = "#{key.ssh_type} #{[key.to_blob].pack('m0')}"
node.default['bluefinops_jenkins2']['jenkins']['private_key'] = key.to_pem

bluefinops_jenkins2_master 'check_security_flag' do
  action :security_check
end

node['bluefinops_jenkins2']['plugins'].each do |p, v|
  jenkins_plugin p do
    version v
    notifies :restart, 'service[jenkins]', :immediately
  end 
end

node['bluefinops_jenkins2']['jenkins']['users'].each do |j| 
  jenkins_user j do
    full_name j
    password j
  end
end

Chef::Log.info node['bluefinops_jenkins2']['jenkins']['public_key']
Chef::Log.info node['bluefinops_jenkins2']['jenkins']['private_key']
jenkins_user 'jenkins' do
  public_keys [node['bluefinops_jenkins2']['jenkins']['public_key']]
end

jenkins_private_key_credentials 'jenkins' do
  id 'jenkins-key'
  retry_delay 120
  description 'Bluefinops Jenkins'
  private_key node['bluefinops_jenkins2']['jenkins']['private_key']
  not_if "egrep 'Bluefinops Jenkins' #{node['bluefinops_jenkins2']['jenkins_home']}/credentials.xml"
end

directory "#{node['bluefinops_jenkins2']['jenkins_home']}/.ssh" do
  owner node['bluefinops_jenkins2']['user']
  group node['bluefinops_jenkins2']['group']
  mode '0700'
  action :create
end

file "#{node['bluefinops_jenkins2']['jenkins_home']}/.ssh/known_hosts" do
  owner node['bluefinops_jenkins2']['user']
  group node['bluefinops_jenkins2']['group']
  mode '0600'
  action :create
end

slaves = search(:node, "role:jenkins2_slave AND chef_environment:#{node.chef_environment}")
slaves.each do |s|
  Chef::Log.info s.node['hostname']
  Chef::Log.info s.node['fqdn']
  Chef::Log.info s.node['ipaddress']
  #Chef::Log.info s.node.name
  #Chef::Log.info s.node.fqdn
  #Chef::Log.info s.node.ipaddress
  if ::File.exists?("#{node['bluefinops_jenkins2']['jenkins_home']}/.ssh/known_hosts")
    ::File.open("#{node['bluefinops_jenkins2']['jenkins_home']}/.ssh/known_hosts", 'a') do |f|
      f.puts("#{s.node.name},#{s.node.ipaddress}, #{node['bluefinops_jenkins2']['jenkins']['public_key']}")
    end
  end

  jenkins_ssh_slave s.node.name do
    host s.node['hostname']
    user node['bluefinops_jenkins2']['user']
    credentials 'jenkins-key'
    executors 4
    remote_fs node['bluefinops_jenkins2']['jenkins_home']
    labels [s.node['hostname'], s.node['ipaddress']]
    action [:create, :online, :connect]
  end
end

bluefinops_jenkins2_master 'hudson' do
  action :secure_hudson
  name 'hudson'
end
