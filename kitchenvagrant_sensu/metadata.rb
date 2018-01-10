name             'bluefinops_sensu'
maintainer       'gregsheu'
maintainer_email 'greg@bluefinops'
license          'All rights reserved'
description      'Installs, Configures Sensu '
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1'

depends          'sensu', '~> 2.12'
depends          'rabbitmq', '= 4.6.0'
depends          'uchiwa', '~> 1.2'
