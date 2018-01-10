default['bluefinops_sensu']['rabbitmq']['user'] = 'sensu'
default['bluefinops_sensu']['rabbitmq']['password'] = 'sensu'
default['bluefinops_sensu']['rabbitmq']['vhost'] = '/sensu'
default['bluefinops_sensu']['rabbitmq']['erlang_cookie'] = 'iamrabbitmqclusterforsensu'
default['bluefinops_sensu']['sensu']['ssl'] = true
default['bluefinops_sensu']['rabbitmq']['ssl'] = true
default['bluefinops_sensu']['ha_policy'] = '^(results$|keepalives$)'
default['rabbitmq']['ssl'] = node['bluefinops_sensu']['rabbitmq']['ssl']
default['rabbitmq']['cluster'] = true
default['rabbitmq']['erlang_cookie'] = node['bluefinops_sensu']['rabbitmq']['erlang_cookie']
default['rabbitmq']['cluster_partition_handling'] = 'pause_minority'
default['rabbitmq']['clustering']['use_auto_clustering'] = false
default['rabbitmq']['clustering']['cluster_name'] = 'sensu'
default['redis']['version'] = '2.2.2'
default['sensu']['version'] = '0.23.1-1'
default['sensu']['use_ssl'] = node['bluefinops_sensu']['sensu']['ssl']
default['sensu']['rabbitmq']['password'] = node['bluefinops_sensu']['rabbitmq']['password']