actions :install_plugin, :uninstall_plugin, :restart, :security_check, :secure_hudson, :secure_unix, :secure_ldap
default_action :install

attribute :name, :kind_of => String, :name_attribute => true
attribute :type, :kind_of => String
