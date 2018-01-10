#search_query = 'role:rancher_server AND chef_environment:development'
search_query = node['bluefinops_rancher']['searching_query']
endpoint = search(:node, search_query)
server_endpoint = ''
endpoint.each do |s|
  server_endpoint = 'http://' + s.normal.network.internal_ip.to_s + ':8080/v1'
end
os_version = node['platform_version']
case os_version.to_i
when 6
  package 'libcgroup'

  service 'cgconfig' do
    action [:enable, :start]
  end

  docker_service 'default' do
    action [:create, :start]
  end

  docker_service_manager_upstart 'default' do
    host 'unix:///var/run/docker.sock'
    action :start
  end

  docker_image node['bluefinops_rancher']['agent_image'] do
    host 'unix:///var/run/docker.sock'
    tag node['bluefinops_rancher']['rancher_tag']
    action :pull_if_missing
  end

  docker_container 'rancher_agent' do
    image node['bluefinops_rancher']['agent_image']
    tag node['bluefinops_rancher']['rancher_tag']
    host 'unix:///var/run/docker.sock'
    #command 'http://192.168.43.33:8080/v1'
    command server_endpoint
    volume node['bluefinops_rancher']['rancher_volume']
    detach true
    action :run
    not_if 'docker inspect rancher_agent'
  end

when 7
  docker_installation_binary 'default' do
    version node['bluefinops_rancher']['docker_version']
    checksum node['bluefineops_rancher']['docker_checksum']
    action :create
  end

  docker_service_manager_systemd 'default' do
    host 'unix:///var/run/docker.sock'
    action :start
  end

  docker_image node['bluefinops_rancher']['agent_image'] do
    host 'unix:///var/run/docker.sock'
    tag node['bluefinops_rancher']['rancher_tag']
    action :pull_if_missing
  end

  docker_container 'rancher_agent' do
    image node['bluefinops_rancher']['agent_image']
    tag node['bluefinops_rancher']['rancher_tag']
    host 'unix:///var/run/docker.sock'
    #command 'http://192.168.43.33:8080/v1'
    command server_endpoint
    volume node['bluefinops_rancher']['rancher_volume']
    detach true
    action :run
    not_if 'docker inspect rancher_agent'
  end
end
