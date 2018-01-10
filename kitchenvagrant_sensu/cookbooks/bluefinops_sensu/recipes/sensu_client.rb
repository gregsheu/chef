include_recipe 'sensu'
%w(sensu-api sensu-client sensu-server sensu-service).each do |f|
  file "/etc/rc.d/init.d/#{f}" do
    action :delete
  end
end
rabbitmq_masters = search(:node, 'role:sensu_rabbitmq_master AND chef_environment:production') 
rabbitmq_master = ''
rabbitmq_masters.each do |r|
  rabbitmq_master = r.normal.ipaddress.to_s
end

cookbook_file '/usr/lib/systemd/system/sensu-client.service' do
  source 'sensu-client.service'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute 'systemctl_reload' do
  command 'systemctl daemon-reload'
end

template '/etc/sensu/conf.d/client.json' do
  source 'client.json.erb'
  owner 'sensu'
  group 'root'
  mode '0644'
  variables(rabbitmq_master: rabbitmq_master)
  notifies :restart, 'service[sensu-client]', :immediately
end

service 'sensu-client' do
  provider Chef::Provider::Service::Systemd
  action [:start, :enable]
end
