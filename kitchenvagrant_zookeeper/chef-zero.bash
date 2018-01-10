cd /tmp/kitchen/
/opt/chef/embedded/bin/gem install chef-zero
/opt/chef/embedded/bin/chef-zero -d
cat << PRO > production_mdw1.rb
name 'production_mdw1'

description 'Midway Datacenter'

\$environment = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }

\$override = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }

default_attributes(Chef::Mixin::DeepMerge.merge(\$_default_environment, \$environment))

override_attributes(\$override)
PRO
cat << ROLE >sendtest.rb 
name 'sendtest'
description 'SendTest'

run_list %w(
    sendtest::deployment_ops
)

default_attributes(
  'sendgrid_ldap_client' => {
    access_groups: [
      'memberOf=cn=eng-bizsystems,ou=Groups,dc=sendgrid,dc=net',
      'memberOf=cn=business-systems,ou=Groups,dc=sendgrid,dc=net'
    ]
  }
)
ROLE
sed -i "s|!= '_default'|== '_default'|g" cookbooks/sendgrid_server/recipes/_servernameapi.rb
knife cookbook upload -a -o cookbooks -c client.rb
knife environment from file production_mdw1.rb -c client.rb
knife role from file sendtest.rb -c client.rb
cat << DNA > dna.json
{"run_list":["role[sendtest]"]}
DNA
chef-client -c client.rb -j dna.json -E production_mdw1
