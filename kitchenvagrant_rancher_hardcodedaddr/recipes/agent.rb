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

    docker_image node['bluefinops_rancher']['agent_image'] do
      host 'unix:///var/run/docker.sock'
      tag node['bluefinops_rancher']['rancher_tag']
      action :pull_if_missing
    end

    docker_container 'rancher_agent' do
      image node['bluefinops_rancher']['agent_image']
      tag node['bluefinops_rancher']['rancher_tag']
      host 'unix:///var/run/docker.sock'
      command 'http://192.168.43.33:8080/v1'
      volume ['/var/run/docker.sock:/var/run/docker.sock', '/var/lib/rancher:/var/lib/ranche']
      detach true
      action :run
      not_if 'docker inspect rancher_agent'
    end

  when 7
    docker_installation_binary 'default' do
      version node['bluefinops_rancher']['docker_version']
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
      command 'http://192.168.43.33:8080/v1'
      volume ['/var/run/docker.sock:/var/run/docker.sock', '/var/lib/rancher:/var/lib/rancher']
      detach true
      action :run
      not_if 'docker inspect rancher_agent'
    end
end
