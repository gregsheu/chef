include_recipe 'java'

directory node['bluefinops_zookeeper']['install_dir']

directory '/var/lib/zookeeper'

remote_file "#{Chef::Config[:file_cache_path]}/#{node['bluefinops_zookeeper']['file']}" do
  source node['bluefinops_zookeeper']['url']
  mode 0644
  not_if { ::File.exists?(node['bluefinops_zookeeper']['file']) }
end

execute 'untar_zookeeper' do
  command "sudo tar -zxvf #{Chef::Config[:file_cache_path]}/#{node['bluefinops_zookeeper']['file']} -C /opt/zookeeper"
end

file 'myid' do
  path '/var/lib/zookeeper/myid'
  content node['hostname'][3]
end

zoos = {}
zoos['keeper'] = search(:node, 'role:zookeeper AND chef_environment:production')
zoos['mesos-master'] = search(:node, 'role:mesos-master AND chef_environment:production')
zoos['mesos-slave'] = search(:node, 'role:mesos-slave AND chef_environment:production')

template "#{node['bluefinops_zookeeper']['install_dir']}/#{node['bluefinops_zookeeper']['version']}/conf/zoo.cfg" do
  source 'zoo.cfg.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(zoos: zoos)
end

template '/etc/hosts' do
  source 'hosts.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(zoos: zoos)
end

centos_version = node['platform_version'].to_i
case centos_version
  when 6
    cookbook_file '/etc/init/zookeeper.conf' do
      source 'zookeeper.conf'
      action :create
    end

    service 'zookeeper' do
      provider Chef::Provider::Service::Upstart
      action :start
    end
  when 7
    cookbook_file '/usr/lib/systemd/system/zookeeper.service' do
      source 'zookeeper.service'
    end

    service 'zookeeper' do
      provider Chef::Provider::Service::Systemd
      action :start
    end
end
