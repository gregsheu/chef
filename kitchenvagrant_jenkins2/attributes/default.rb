override['java']['install_flavor'] = 'oracle'
override['java']['jdk_version'] = '8'
default['java']['oracle_rpm']['package_name'] = '8'
default['java']['oracle_rpm']['package_version'] = '8'
default['java']['oracle']['accept_oracle_download_terms'] = true
override['java']['ark_retries'] = 3
override['java']['ark_retry_delay'] = 60
override['java']['ark_timeout'] = 60
default['jenkins']['master']['install_method'] = 'package'
default['bluefinops_jenkins2']['jenkins_home'] = '/var/lib/jenkins'
default['bluefinops_jenkins2']['ports'] = [25, 80, 8080, 1084, 1086, 1088]
default['bluefinops_jenkins2']['user'] = 'jenkins'
default['bluefinops_jenkins2']['group'] = 'jenkins'
default['bluefinops_jenkins2']['password'] = '$1$.JkiVyh5$11L6COktwXsF03ynJAy7n1'
default['bluefinops_jenkins2']['git'] = 'git@github.com:sendgrid/bluefinops_jenkins2.git'
default['bluefinops_jenkins2']['revision'] = '2.46.1-1.1'
default['jenkins']['master']['jvm_options'] = '-Djenkins.install.runSetupWizard=false'
default['bluefinops_jenkins2']['plugins'] = {'mailer' => '1.20', 'junit' => '1.20', 'structs' => '1.7', 'git-client' => '2.4.6', 'credentials' => '2.1.13', 'ssh-credentials' => '1.13', 'ssh-agent' => '1.15', 'icon-shim' => '2.0.3', 'matrix-auth' => '1.6', 'ssh-slaves' => '1.17', 'workflow-step-api' => '2.11'}
#default['bluefinops_jenkins2']['plugins'] = ['junit', 'structs', 'git-client', 'credentials', 'mailer', 'ssh-credentials', 'ssh-agent', 'matrix-project', 'matrix-auth', 'ssh-slaves']
default['bluefinops_jenkins2']['install_dir'] = '/usr/local/bluefinops_jenkins2'
default['bluefinops_jenkins2']['ldap']['jenkins_username'] = 'jenkins-auth'
default['bluefinops_jenkins2']['ldap']['jenkins_password'] = 'u1k+J7SJchoKYUnDQrZp'
default['endpoints']['ldap'] = '172.16.0.108'
default['bluefinops_jenkins2']['jenkins']['users'] = ['jenkins', 'vagrant', 'greg']
default['bluefinops_jenkins2']['jenkins']['security_type'] = 'hudson'
default['jenkins']['master']['version'] = node['bluefinops_jenkins2']['revision'] 
default['jenkins']['executor']['timeout'] = 1920
