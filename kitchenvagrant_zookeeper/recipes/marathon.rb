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

package 'marathon'

directory '/etc/marathon/conf' do
  recursive true
  owner 'root'
  group 'root'
  mode '0644'
end

zoos = {}
zoos['keeper'] = search(:node, 'role:zookeeper AND chef_environment:production')
zoos['mesos-master'] = search(:node, 'role:mesos-master AND chef_environment:production')

template '/etc/marathon/conf/master' do
  source 'zk.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(zoos: zoos)
end

template '/etc/marathon/conf/zk' do
  source 'marathon.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(zoos: zoos)
end

centos_version = node['platform_version'].to_i
case centos_version
  when 6
    service 'marathon' do
      provider Chef::Provider::Service::Upstart
      action :start
    end
  when 7
    service 'marathon' do
      provider Chef::Provider::Service::Systemd
      action :start
    end
end
