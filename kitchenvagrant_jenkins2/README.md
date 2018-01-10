SendTest Cookbook
=================
Description. 

This is a Chef cookbook to install SendTest with separate nodes of Jenkins master and slave associate with this App in staging sjc env.

#### packages
Need sendgrid_server to install basic development tools 

#### recipes
deployment_ops to deploy bluefinops_jenkins app servers.
deployment_master to deploy Jenkins master.
deployment_slave to deploy Jenkins slave.

Three roles: bluefinops_jenkins, bluefinops_jenkins_master, bluefinops_jenkins_slave
bootstrap -r 'role[bluefinops_jenkins]' to create bluefinops_jenkins server
bootstrap -r 'role[bluefinops_jenkins_master]' to create bluefinops_jenkins jenkins master.
bootstrap -r 'role[bluefinops_jenkins_slave]' to create bluefinops_jenkins jenkins slave.
