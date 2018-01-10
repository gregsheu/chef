SendTest Cookbook
=================
Description. 

This is a Chef cookbook to install SendTest with separate nodes of Jenkins master and slave associate with this App in staging sjc env.

#### packages
Need sendgrid_server to install basic development tools 

#### recipes
deployment_ops to deploy myjenkins app servers.
deployment_master to deploy Jenkins master.
deployment_slave to deploy Jenkins slave.

Three roles: myjenkins, myjenkins_master, myjenkins_slave
bootstrap -r 'role[myjenkins]' to create myjenkins server
bootstrap -r 'role[myjenkins_master]' to create myjenkins jenkins master.
bootstrap -r 'role[myjenkins_slave]' to create myjenkins jenkins slave.
