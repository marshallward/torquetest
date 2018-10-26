#!/bin/bash
set -x
TORQUE=/var/spool/torque

# Kill any existing servers
killall pbs_sched
killall pbs_mom
killall trqauthd
killall pbs_server

# Ensure that `/var/spool/torque/server_name` matches your node

# Create the TORQUE server
pbs_server -f -t create

# Start the TORQUE queue authentication daemon
trqauthd

# Configure the queue
qmgr -c "set server acl_hosts = bevelle"
qmgr -c "set server scheduling=true"
qmgr -c "create queue batch queue_type=execution"
qmgr -c "set queue batch started=true"
qmgr -c "set queue batch enabled=true"
qmgr -c "set queue batch resources_default.nodes=1"
qmgr -c "set queue batch resources_default.walltime=3600"
qmgr -c "set server default_queue=batch"

# Add host as a compute node
echo "$(hostname)" > ${TORQUE}/server_priv/nodes

# Set up client configuration
echo "\$pbsserver $(hostname)
\$logevent   255" > ${TORQUE}/mom_priv/config

# Restart the server (do I need this?)
killall -9 pbs_server
pbs_server

# Start the clients
pbs_mom

# Start the scheduler
pbs_sched
