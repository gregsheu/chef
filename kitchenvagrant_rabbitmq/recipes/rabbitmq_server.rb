unless Chef::Config[:zero]
  rabbitmq_nodes = search(:node, 'role:rabbitmq* AND chef_environment:production') 
  template '/etc/hosts' do
    source 'hosts.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(rabbitmq_nodes: rabbitmq_nodes)
  end
end
            
include_recipe "rabbitmq"
include_recipe "rabbitmq::mgmt_console"

rabbitmq_vhost node['mygreops_rabbitmq']['rabbitmq']['vhost'] do
  action :add
  not_if "/usr/sbin/rabbitmqctl list_vhosts | grep #{node['mygreops_rabbitmq']['rabbitmq']['vhost']}"
end

rabbitmq_user node['mygreops_rabbitmq']['rabbitmq']['user'] do
  password node['mygreops_rabbitmq']['rabbitmq']['password']
  vhost node['mygreops_rabbitmq']['rabbitmq']['vhost']
  permissions '.* .* .*'
  action [:add, :set_permissions]
  not_if "/usr/sbin/rabbitmqctl list_user_permissions #{node['mygreops_rabbitmq']['rabbitmq']['user']}"
end

rabbitmq_user 'admin' do
  password 'admin'
  vhost '/'
  permissions '.* .* .*'
  action [:add, :set_permissions]
  not_if '/usr/sbin/rabbitmqctl list_user | awk \'{print $1}\' | grep admin'
end

rabbitmq_user 'admin' do
  tag 'administrator'
  action :set_tags 
end

rabbitmq_string = ''
rabbitmq_role = node.run_list
if rabbitmq_role.to_s.include?('rabbitmq_slave')
  rabbitmq_nodes = search(:node, 'role:rabbitmq_master AND chef_environment:production') 
  rabbitmq_nodes.each do |r|
    rabbitmq_string = '{"name":"rabbit@' + r.name + '","type":"disc"}'
  end
  
  rabbitmq_cluster "[#{rabbitmq_string}]" do
    cluster_name node['rabbitmq']['clustering']['cluster_name']
    action [:join, :set_cluster_name]
  end
end
