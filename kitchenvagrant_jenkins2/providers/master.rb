action :security_enabled do
  cwd = '/var/cache/jenkins/war/WEB-INF'
  jenkins_script 'is_security_enabled' do
    command <<-EOH.gsub(/^ {4}/, '')
      import jenkins.model.*
      import hudson.security.*
      import hudson.model.*
      import org.jenkinsci.plugins.*
      boolean security_mode = Jenkins.instance.isUseSecurity()
      if (security_mode) {
        return true
      } else {
        return false
      }
    EOH
  end
  cmd_str = "java -jar jenkins-cli.jar -s http://localhost:8080 groovy is_security_enabled"
  cmd = Mixlib::ShellOut.new(cmd_str)
  status = cmd.run_command.exitstatus
  status == 0 ? true : false
  file = ::File.new('/tmp/is_security_enabled')
  file = ::File.open('/tmp/is_security_enabled', 'w')
  file.write status 
end

def plugin_installed? (plugin_name)
  cwd = '/var/cache/jenkins/war/WEB-INF'
  cmd_str = "java -jar jenkins-cli.jar -s http://localhost:8080/ list-plugins #{plugin_name}"
  cmd = Mixlib::ShellOut.new(cmd_str)
  status = cmd.run_command.exitstatus
  status == 0 ? true : false
end

def jenkins_running?
  cmd_str = 'service jenkins status'
  cmd = Mixlib::ShellOut.new(cmd_str)
  status = cmd.run_command.exitstatus
  status == 0 ? true : false
end

use_inline_resources

action :install_plugin do
  n = new_resource.name
  if (security_enabled)
    node.run_state[:jenkins_username] = 'vagrant'
    node.run_state[:jenkins_password] = 'vagrant'
  end
  jenkins_plugin n do
    action :install
    not_if { plugin_installed? (n) }
  end
end

action :uninstall_plugin do
  n = new_resource.name
  if (security_enabled)
    node.run_state[:jenkins_username] = 'vagrant'
    node.run_state[:jenkins_password] = 'vagrant'
  end
  jenkins_plugin n do
    action :uninstall
  end
end

action :restart do
  service 'jenkins' do
    action :restart
  end
end

def write_security_flag
  file '/var/lib/jenkins/security_enabled_by_chef' do
    mode '0755'
    owner 'jenkins'
    group 'jenkins'
    content 'true'
  end
end

def check_security_flag
  if ::File.exists?('/var/lib/jenkins/security_enabled_by_chef')
    r = ::File.read('/var/lib/jenkins/security_enabled_by_chef').chomp
    if r == 'true'
      Chef::Log.warn 'True'
      node.run_state[:jenkins_username] = node['bluefinops_jenkins2']['user']
      node.run_state[:jenkins_password] = node['bluefinops_jenkins2']['user'] 
    end
  end
end

action :security_check do
  check_security_flag
end

action :secure_ldap do
  jenkins_script 'add_ldap_security' do
    retries 3
    retry_delay 10
    command <<-EOH.gsub(/^ {4}/, '')
      import jenkins.model.*
      import hudson.security.*
      import hudson.model.*
      import org.jenkinsci.plugins.*
      String server = '#{node['endpoints']['ldap']}'
      String rootDN = 'dc=sendgrid,dc=net'
      String userSearchBase = ''
      String userSearch = ''
      String groupSearchBase = ''
      String managerDN = '#{node['bluefinops_jenkins']['ldap']['jenkins_username']}'
      String managerPassword = '#{node['bluefinops_jenkins']['ldap']['jenkins_password']}'
      boolean inhibitInferRootDN = false
      SecurityRealm ldap_realm = new LDAPSecurityRealm(server, rootDN, userSearchBase, userSearch, groupSearchBase, managerDN, managerPassword, inhibitInferRootDN) 
      Jenkins.instance.setSecurityRealm(ldap_realm)
      def strategy = new GlobalMatrixAuthorizationStrategy()
      strategy.add(Jenkins.ADMINISTER, 'gsheu')
      strategy.add(Jenkins.ADMINISTER, 'cmead')
      strategy.add(Jenkins.READ, 'anonymous')
      strategy.add(Jenkins.RUN_SCRIPTS, 'anonymous')
      Jenkins.instance.setAuthorizationStrategy(strategy)
      Jenkins.instance.save()
    EOH
  end
  
  service 'jenkins' do
    action :reload
  end
end

action :secure_unix do
  group 'root' do
    members ['root', 'jenkins']
    append true
    action :modify
  end
  
  file '/etc/shadow' do
    mode 0040
    owner 'root'
    group 'root'
  end
  
  jenkins_script 'add_unix_security' do
    retries 3
    retry_delay 10
    command <<-EOH.gsub(/^ {4}/, '')
      import jenkins.model.*
      import hudson.security.*
      import hudson.model.*
      import org.jenkinsci.plugins.*
      SecurityRealm unix_realm = new PAMSecurityRealm('sshd')
      Jenkins.instance.setSecurityRealm(unix_realm)
      def strategy = new GlobalMatrixAuthorizationStrategy()
      strategy.add(Jenkins.ADMINISTER, 'vagrant')
      strategy.add(Jenkins.ADMINISTER, 'jenkins')
      strategy.add(Jenkins.READ, 'anonymous')
      strategy.add(Jenkins.RUN_SCRIPTS, 'anonymous')
      Jenkins.instance.setAuthorizationStrategy(strategy)
      Jenkins.instance.save()
    EOH
  end
  
  service 'jenkins' do
    action :reload
  end
end

action :secure_hudson do
  jenkins_script 'add_hudson_security' do
    retries 3
    retry_delay 10
    command <<-EOH.gsub(/^ {4}/, '')
      import jenkins.*
      import hudson.*
      import jenkins.model.*
      import hudson.security.*
      import hudson.model.*
      import org.jenkinsci.plugins.*
      import com.cloudbees.plugins.credentials.*
      import hudson.scm.*
      SecurityRealm hudson_realm = new HudsonPrivateSecurityRealm(false)
      Jenkins.instance.setSecurityRealm(hudson_realm)
      def strategy = new GlobalMatrixAuthorizationStrategy()
      //def strategy = new LegacyAuthorizationStrategy()
      //def strategy = new AuthorizationStrategy.Unsecured()
      //def strategy  = new FullControlOnceLoggedInAuthorizationStrategy()
      strategy.add(Jenkins.ADMINISTER, 'vagrant')
      strategy.add(Jenkins.ADMINISTER, 'jenkins')
      strategy.add(Jenkins.ADMINISTER, 'greg')
      strategy.add(Jenkins.READ, 'anonymous')
      //strategy.add(Jenkins.RUN_SCRIPTS, 'anonymous')
      //strategy.add(PluginManager.UPLOAD_PLUGINS, 'anonymous')
      //strategy.add(CredentialsProvider.CREATE, 'anonymous')
      //strategy.add(CredentialsProvider.DELETE, 'anonymous')
      //strategy.add(CredentialsProvider.MANAGE_DOMAINS, 'anonymous')
      //strategy.add(CredentialsProvider.UPDATE, 'anonymous')
      strategy.add(CredentialsProvider.VIEW, 'anonymous')
      //strategy.add(Hudson.RUN_SCRIPTS, 'anonymous')
      //strategy.add(Hudson.READ, 'anonymous')
      //strategy.add(PluginManager.CONFIGURE_UPDATECENTER, 'anonymous')
      //strategy.add(PluginManager.UPLOAD_PLUGINS, 'anonymous')
      //strategy.add(Computer.BUILD, 'anonymous')
      //strategy.add(Computer.DELETE, 'anonymous')
      //strategy.add(Computer.CONFIGURE, 'anonymous')
      //strategy.add(Computer.CONNECT, 'anonymous')
      //strategy.add(Computer.CREATE, 'anonymous')
      //strategy.add(Computer.DISCONNECT, 'anonymous')
      //strategy.add(Item.BUILD, 'anonymous')
      //strategy.add(Item.CANCEL, 'anonymous')
      //strategy.add(Item.CONFIGURE, 'anonymous')
      //strategy.add(Item.CREATE, 'anonymous')
      //strategy.add(Item.DELETE, 'anonymous')
      //strategy.add(Item.DISCOVER, 'anonymous')
      //strategy.add(Item.READ, 'anonymous')
      //strategy.add(Item.WORKSPACE, 'anonymous')
      //strategy.add(Run.DELETE, 'anonymous')
      //strategy.add(Run.UPDATE, 'anonymous')
      //strategy.add(View.CONFIGURE, 'anonymous')
      //strategy.add(View.CREATE, 'anonymous')
      //strategy.add(View.DELETE, 'anonymous')
      strategy.add(View.READ, 'anonymous')
      //strategy.add(SCM.TAG, 'anonymous')
      Jenkins.instance.setAuthorizationStrategy(strategy)
      Jenkins.instance.save()
    EOH
  end
  
  service 'jenkins' do
    action :reload
  end
  
  write_security_flag
end
