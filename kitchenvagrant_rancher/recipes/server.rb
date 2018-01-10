os_ver = node['platform_version']
case os_ver.to_i
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

  docker_image node['bluefinops_rancher']['server_image'] do
    host 'unix:///var/run/docker.sock'
    tag node['bluefinops_rancher']['rancher_tag']
    action :pull_if_missing
  end

  docker_container 'rancher_server' do
    image node['bluefinops_rancher']['server_image']
    tag node['bluefinops_rancher']['rancher_tag']
    host 'unix:///var/run/docker.sock'
    port ['8080:8080', '3306']
    detach true
    restart_policy 'always'
    action :run
    not_if 'docker inspect rancher_server'
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

  docker_image node['bluefinops_rancher']['server_image'] do
    host 'unix:///var/run/docker.sock'
    tag node['bluefinops_rancher']['rancher_tag']
    action :pull_if_missing
  end

  docker_container 'rancher_server' do
    image node['bluefinops_rancher']['server_image']
    tag node['bluefinops_rancher']['rancher_tag']
    host 'unix:///var/run/docker.sock'
    port ['8080:8080', '3306']
    detach true
    restart_policy 'always'
    action :run
    not_if 'docker inspect rancher_server'
  end
end
