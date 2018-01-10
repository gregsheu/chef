include_recipe 'java'

execute 'clean-yum-cache' do
  command 'yum clean all'
  action :run
end

execute 'clean-yum-repo' do
  command 'yum repolist'
  action :run
end

bash 'mesosphere' do
  code <<-EOF
    rpm -ivh #{node['mesosphere']['repo']}
  EOF
  notifies :run, 'execute[clean-yum-cache]', :immediately
  not_if "rpm -qa | grep #{node['mesosphere']['rpm']}"
end

package 'mesos'

zoos = {}
zoos['keeper'] = search(:node, 'role:zookeeper AND chef_environment:production')
zoos['mesos-master'] = search(:node, 'role:mesos-master AND chef_environment:production')
zoos['mesos-slave'] = search(:node, 'role:mesos-slave AND chef_environment:production')

template '/etc/mesos/zk' do
  source 'zk.erb'
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

file '/etc/mesos-slave/containerizers' do
  content 'docker,mesos'
end

file '/etc/mesos-slave/executor_registration_timeout' do
  content '10mins'
  notifies :restart, 'service[mesos-slave]', :immediately
end

docker_installation_script 'default' do
  repo 'main'
  script_url 'https://get.docker.com'
  action :create
end

centos_version = node['platform_version'].to_i
case centos_version
  when 6
    service 'mesos-slave' do
      provider Chef::Provider::Service::Upstart
      action [:enable, :start]
    end

    service 'mesos-master' do
      provider Chef::Provider::Service::Upstart
      action [:disable, :stop]
    end
    
    service 'cgconfig' do
      provider Chef::Provider::Service::Init
      action :start
    end
    
    docker_service_manager_sysvinit 'default' do
      host 'unix:///var/run/docker.sock'
      action :start
    end
  when 7
    service 'mesos-slave' do
      provider Chef::Provider::Service::Systemd
      action [:enable, :start]
    end

    service 'mesos-master' do
      provider Chef::Provider::Service::Systemd
      action [:disable, :stop]
    end
    
    docker_service_manager_systemd 'default' do
      host 'unix:///var/run/docker.sock'
      action :start
    end
end
