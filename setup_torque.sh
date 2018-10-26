#!/bin/bash
set -x
TORQUE=/var/spool/torque

# Kill any existing servers
/etc/init.d/torque-mom stop
/etc/init.d/torque-scheduler stop
/etc/init.d/torque-server stop
#killall pbs_server
#killall pbs_sched
#killall pbs_mom
#killall trqauthd

# Create and shut down the TORQUE server in order to set up the directories
pbs_server -f -t create
killall pbs_server

## Start the TORQUE queue authentication daemon
#service trqauthd restart
#server=$(hostname -f)
server=localhost

# Do I need these?
echo ${server} > /etc/torque/server_name
echo ${server} > ${TORQUE}/server_priv/acl_svr/acl_hosts
echo root@${server} > ${TORQUE}/server_priv/acl_svr/operators
echo root@${server} > ${TORQUE}/server_priv/acl_svr/managers

# Update hosts
echo "127.0.0.1 ${server}" >> /etc/hosts

# Add host as a compute node
echo "${server}" > ${TORQUE}/server_priv/nodes

# Set up client configuration
# NOTE: Simplify?
#echo "\$pbsserver $(hostname)
#\$logevent   255" > ${TORQUE}/mom_priv/config
echo ${server} > ${TORQUE}/mom_priv/config

# Restart server
/etc/init.d/torque-server start
/etc/init.d/torque-scheduler start
/etc/init.d/torque-mom start

# Server config
qmgr -c "set server scheduling = true"
qmgr -c "set server keep_completed = 300"
qmgr -c "set server mom_job_sync = true"

# Default queue
qmgr -c "create queue batch"
qmgr -c "set queue batch queue_type = execution"
qmgr -c "set queue batch started = true"
qmgr -c "set queue batch enabled = true"
qmgr -c "set queue batch resources_default.walltime = 3600"
qmgr -c "set queue batch resources_default.nodes = 1"
qmgr -c "set server default_queue = batch"

#qmgr -c "set server submit_hosts = $(hostname)"
#qmgr -c "set server allow_node_submit = true"

# Parse the inevitable error:
grep Unauthorized /var/spool/torque/server_logs/*

service pbs_sched start

# MOM setup

## Restart the server (do I need this?)
#killall -9 pbs_server
#pbs_server
service pbs_server restart
#
## Start the clients
#pbs_mom
#
## Start the scheduler
#pbs_sched

# Check the nodes
pbsnodes
