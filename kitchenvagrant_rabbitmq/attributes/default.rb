default['mygreops_rabbitmq']['rabbitmq']['user'] = 'rabbitmq'
default['mygreops_rabbitmq']['rabbitmq']['password'] = 'rabbitmq'
default['mygreops_rabbitmq']['rabbitmq']['vhost'] = '/rabbitmq'
default['mygreops_rabbitmq']['rabbitmq']['erlang_cookie'] = 'iamrabbitmqclusterforanyapp'
default['rabbitmq']['cluster'] = true
#default['rabbitmq']['clustering']['enable'] = true
default['rabbitmq']['erlang_cookie_path'] = '/var/lib/rabbitmq/.erlang.cookie'
default['rabbitmq']['erlang_cookie'] = node['mygreops_rabbitmq']['rabbitmq']['erlang_cookie']
default['rabbitmq']['cluster_partition_handling'] = 'ignore'
default['rabbitmq']['clustering']['use_auto_clustering'] = false
default['rabbitmq']['clustering']['cluster_name'] = 'rabbitmq_cluster'
#default['rabbitmq']['clustering']['master_node_name'] = 'rabbit@rabbitmq1-centos-72'
#default['rabbitmq']['clustering']['cluster_nodes'] = { :name => 'rabbit@rabbitmq1', :type => 'disc' }
