#!/bin/bash

# when using docker mounted volumes, the owner/group is set to root by default
if [ `stat --format=%U /var/lib/cassandra` != "cassandra" ] ; then
  chown -R cassandra:cassandra /var/lib/cassandra
fi
if [ `stat --format=%U /var/log/cassandra` != "cassandra" ] ; then
  chown -R cassandra:cassandra /var/log/cassandra
fi

# default values for configuration variables
if [ -z "${CASSANDRA_CLUSTER_NAME}" ] ; then
  CASSANDRA_CLUSTER_NAME='usergrid'
fi
if [ -z "${CASSANDRA_LISTEN_ADDRESS}" ] ; then
  CASSANDRA_LISTEN_ADDRESS=$(hostname --ip-address)
fi
if [ -z "${CASSANDRA_SEEDS}" ] ; then
  CASSANDRA_SEEDS=$(hostname --ip-address)
fi
if [ -z "${CASSANDRA_RPC_ADDRESS}" ] ; then
  # accept rpc requests from this address
  CASSANDRA_RPC_ADDRESS=0.0.0.0
fi
if [ -z "${CASSANDRA_BROADCAST_RPC_ADDRESS}" ] ; then
  # if rpc address is set to 0.0.0.0, broadcast rpc address has to be different from 0.0.0.0
  CASSANDRA_BROADCAST_RPC_ADDRESS=$(hostname --ip-address)
fi

CONFIG_FILE=/etc/cassandra/cassandra.yaml

sed -i -e "s/cluster_name: 'Test Cluster'/cluster_name: '${CASSANDRA_CLUSTER_NAME}'/" ${CONFIG_FILE}
sed -i -e "s/^\(listen_address:\).*/\1 ${CASSANDRA_LISTEN_ADDRESS}/" ${CONFIG_FILE}
sed -i -e "s/^\(rpc_address:\).*/\1 ${CASSANDRA_RPC_ADDRESS}/" ${CONFIG_FILE}
sed -i -e "s/^\(# \)\(broadcast_rpc_address:\).*/\2 ${CASSANDRA_BROADCAST_RPC_ADDRESS}/" ${CONFIG_FILE}
sed -i -e "s/^\([ ]*- seeds:\).*/\1 ${CASSANDRA_SEEDS}/" ${CONFIG_FILE}

start-stop-daemon --chuid cassandra:cassandra --exec /usr/sbin/cassandra --start -- -f
