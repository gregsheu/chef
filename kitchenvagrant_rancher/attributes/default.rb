default['bluefinops_rancher']['docker_version'] = '1.10.3'
default['bluefinops_rancher']['server_image'] = 'rancher/server'
default['bluefinops_rancher']['agent_image'] = 'rancher/agent'
default['bluefinops_rancher']['rancher_tag'] = 'latest'
default['bluefinops_rancher']['rancher_volume'] = ['/var/run/docker.sock:/var/run/docker.sock', '/var/lib/rancher:/var/lib/rancher']
default['bluefinops_rancher']['searching_query'] = 'role:rancher_server AND chef_environment:development'
default['bluefineops_rancher']['docker_checksum'] = 'd0df512afa109006a450f41873634951e19ddabf8c7bd419caeb5a526032d86d'
