include_recipe 'sensu'
%w(sensu-api sensu-client sensu-server sensu-service).each do |f|
  file "/etc/rc.d/init.d/#{f}" do
    action :delete
  end
end
#include_recipe 'sensu::server_service'
rabbitmq_masters = search(:node, 'role:sensu_rabbitmq_master AND chef_environment:production') 
rabbitmq_master = ''
rabbitmq_masters.each do |r|
  rabbitmq_master = r.normal.ipaddress.to_s
end
redis_masters = search(:node, 'role:sensu_redis_master AND chef_environment:production')
redis_master = ''
redis_masters.each do |r|
  redis_master = r.normal.ipaddress.to_s
end

%w(sensu-server sensu-api).each do |f|
  cookbook_file "/usr/lib/systemd/system/#{f}.service" do
    source "#{f}.service"
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end

execute 'systemctl_reload' do
  command 'systemctl daemon-reload'
end

template '/etc/sensu/config.json' do
  source 'config.json.erb'
  owner 'sensu'
  group 'root'
  mode '0644'
  variables(rabbitmq_master: rabbitmq_master, redis_master: redis_master)
  notifies :restart, 'service[sensu-server]', :immediately
  notifies :restart, 'service[sensu-api]', :immediately
end

service 'sensu-server' do
  provider Chef::Provider::Service::Systemd
  action [:start, :enable]
end

service 'sensu-api' do
  provider Chef::Provider::Service::Systemd
  action [:start, :enable]
end
