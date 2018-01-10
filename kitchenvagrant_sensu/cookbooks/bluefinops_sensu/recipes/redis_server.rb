include_recipe 'sensu::redis'
file '/etc/rc.d/init.d/redis6379' do
  action :delete
end

file '/usr/lib/systemd/system/redis@.service' do
  action :delete
end

directory '/var/log/redis' do
  owner 'redis'
end

file '/var/log/redis/6379.log' do
  owner 'redis'
end

file '/var/log/redis/sentinel.log' do
  owner 'redis'
end

cookbook_file '/usr/lib/systemd/system/redis6379.service' do
  source 'redis6379.service'
  owner 'root'
  group 'root'
  mode '0755'
  action :create_if_missing
end

cookbook_file '/usr/lib/systemd/system/sentinel.service' do
  source 'sentinel.service'
  owner 'root'
  group 'root'
  mode '0755'
  action :create_if_missing
end

master_node = ''
node_role = node.run_list
if node_role.to_s.include?('sensu_redis_slave')
  masters = search(:node, 'role:sensu_redis_master AND chef_environment:production')
  masters.each do |m|
    master_node = m.normal.ipaddress.to_s
  end
end

if node_role.to_s.include?('sensu_redis_master')
  master_node = node.normal.ipaddress.to_s
end

template '/etc/redis/6379.conf' do
  source '6379.conf.erb'
  owner 'redis'
  group 'root'
  variables(master_node: master_node, node_role: node_role)
  notifies :restart, 'service[redis6379]', :immediately
end

template '/etc/redis/sentinel.conf' do
  source 'redis-sentinel.conf.erb'
  owner 'redis'
  group 'root'
  variables(master_node: master_node)
  notifies :restart, 'service[sentinel]', :immediately
end

execute 'systemctl_reload' do
  command 'systemctl daemon-reload'
end

service 'redis6379' do
  provider Chef::Provider::Service::Systemd
  action [:start, :enable]
end

service 'sentinel' do
  provider Chef::Provider::Service::Systemd
  action [:start, :enable]
end

service 'firewalld' do
  action [:stop, :disable]
end
