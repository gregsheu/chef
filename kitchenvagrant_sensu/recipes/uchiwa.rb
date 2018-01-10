package 'uchiwa'

file '/etc/rc.d/init.d/uchiwa' do
  action :delete
end

cookbook_file '/etc/sensu/uchiwa.json' do
  source 'uchiwa.json'
  owner 'uchiwa'
  group 'uchiwa'
  mode '0644'
  action :create
end

cookbook_file '/usr/lib/systemd/system/uchiwa.service' do
  source 'uchiwa.service'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

service 'uchiwa' do
  provider Chef::Provider::Service::Systemd
  action [:start, :enable]
end
