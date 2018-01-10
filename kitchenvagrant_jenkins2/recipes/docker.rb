docker_installation_script 'default' do
  repo 'main'
  script_url 'https://get.docker.com'
  action :create
end

docker_service_manager_systemd 'default' do
  host 'unix:///var/run/docker.sock'
  action :start
end

execute 'yum -y groupinstall Development Tools'

service 'jenkins' do
  action :reload
end
