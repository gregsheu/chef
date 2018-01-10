include_recipe 'sensu::rabbitmq'
rabbitmq_vhost node['mygreops_sensu']['rabbitmq']['vhost'] do
  action :add
end

#rabbitmq_user node['mygreops_sensu']['rabbitmq']['user'] do
#  password node['mygreops_sensu']['rabbitmq']['password']
#  action :add
#end

rabbitmq_user node['mygreops_sensu']['rabbitmq']['user'] do
  password node['mygreops_sensu']['rabbitmq']['password']
  vhost node['mygreops_sensu']['rabbitmq']['vhost']
  permissions '.* .* .*'
  action [:add, :set_permissions]
end

# or set it in conf file
rabbitmq_string = ''
rabbitmq_nodes = search(:node, 'role:rabbitmq_master AND chef_environment:production') 
rabbitmq_nodes.each do |r|
  rabbitmq_string = '{"name":"rabbit@' + r.name + '","type":"disc"}'
end

rabbitmq_cluster "[#{rabbitmq_string}]" do
  action :join
end
