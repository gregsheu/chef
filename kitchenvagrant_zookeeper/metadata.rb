name 'bluefinops_zookeeper'
maintainer 'gregsheu'
maintainer_email 'gregsheu@bluefinops'
license 'All rights reserved'
description 'Installs, Configures Zookeeper'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'java', '~> 1.50.0'
depends 'yum', '~> 1.0'
depends 'docker', '~> 2.4'
