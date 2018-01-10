name 'bluefinops_jenkins2'
maintainer 'gregsheu'
maintainer_email 'greg@bluefinops'
license 'All rights reserved'
description 'Installs, Configure Jenkins'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'java', '~> 1.50.0'
depends 'jenkins', '= 5.0.0'
depends 'docker', '~> 2.14.0'
