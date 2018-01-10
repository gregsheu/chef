include_recipe 'sensu::rabbitmq'
unless Chef::Config[:zero]
  rabbitmq_nodes = search(:node, 'role:sensu_rabbitmq* AND chef_environment:production') 
  template '/etc/hosts' do
    source 'hosts.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(rabbitmq_nodes: rabbitmq_nodes)
  end
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
if rabbitmq_role.to_s.include?('sensu_rabbitmq_slave')
  rabbitmq_nodes = search(:node, 'role:sensu_rabbitmq_master AND chef_environment:production') 
  rabbitmq_nodes.each do |r|
    rabbitmq_string = '{"name":"rabbit@' + r.name + '","type":"disc"}'
  end
  
  rabbitmq_cluster "[#{rabbitmq_string}]" do
    cluster_name node['rabbitmq']['clustering']['cluster_name']
    action [:join, :set_cluster_name]
  end

  rabbitmq_policy 'ha-all' do
    pattern node['bluefinops_sensu']['ha_policy']
    params ({'ha-mode' => 'all', 'ha-sync-mode' => 'automatic'})
    priority 1
    action :set
    vhost node['bluefinops_sensu']['rabbitmq']['vhost']
  end
end
