#!/bin/bash
set -x
TORQUE=/var/spool/torque

# Kill any existing servers
/etc/init.d/torque-mom stop
/etc/init.d/torque-scheduler stop
/etc/init.d/torque-server stop

# Ensure that `/var/spool/torque/server_name` matches your node

# Create and shut down the TORQUE server in order to set up the directories
pbs_server -f -t create
killall pbs_server

## Start the TORQUE queue authentication daemon
# Arch only?
#trqauthd

# Do I need these?
echo $(hostname) > /etc/torque/server_name
echo $(hostname) > /var/spool/torque/server_priv/acl_svr/acl_hosts
echo root@$(hostname) > /var/spool/torque/server_priv/acl_svr/operators
echo root@$(hostname) > /var/spool/torque/server_priv/acl_svr/managers

# Add host as a compute node
echo "$(hostname)" > ${TORQUE}/server_priv/nodes

# Set up client configuration
# NOTE: Simplify?
echo "\$pbsserver $(hostname)
\$logevent   255" > ${TORQUE}/mom_priv/config

# Restart server
/etc/init.d/torque-server start
/etc/init.d/torque-scheduler start
/etc/init.d/torque-mom start

# Configure the queue
qmgr -c "set server scheduling = true"
qmgr -c "set server keep_completed = 300"
qmgr -c "set server mom_job_sync = true"

#qmgr -c "set server acl_hosts = $(hostname)"
qmgr -c "create queue batch"
qmgr -c "set queue batch queue_type = execution"
qmgr -c "set queue batch started = true"
qmgr -c "set queue batch enabled = true"
qmgr -c "set queue batch resources_default.walltime = 3600"
qmgr -c "set queue batch resources_default.nodes = 1"
qmgr -c "set server default_queue = batch"

qmgr -c "set server submit_hosts = $(hostname)"
qmgr -c "set server allow_node_submit = true"

## Restart the server (do I need this?)
#killall -9 pbs_server
#pbs_server
#
## Start the clients
#pbs_mom
#
## Start the scheduler
#pbs_sched
