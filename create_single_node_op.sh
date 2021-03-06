#!/bin/bash -e
OG_SUBNET=172.18.0.0/24
docker network rm opengaussnetwork
docker network create --subnet=$OG_SUBNET opengaussnetwork \
|| {
  echo ""
  echo "ERROR: OpenGauss Database Network was NOT successfully created."
  exit 1
}
echo "OpenGauss Database Network Created."

# Parameters
GS_PASSWORD="omm@Password123"
MASTER_IP="172.18.0.101"

MASTER_HOST_PORT="5432"

PGAPPNAME="opengauss_master"
docker run  --network opengaussnetwork --ip $MASTER_IP --privileged=true \
--name $PGAPPNAME -h $PGAPPNAME -p $MASTER_HOST_PORT:$MASTER_HOST_PORT -d \
-e PGAPPNAME=$PGAPPNAME \
-e GS_PORT=$MASTER_HOST_PORT \
-e OG_SUBNET=$OG_SUBNET \
-e GS_PASSWORD=$GS_PASSWORD \
-e NODE_NAME=$PGAPPNAME \
-v /Users/abc/Documents/software/docker-opengauss/data:/var/lib/opengauss/data \
summertao/opengauss:1.0.0 \
|| {
  echo ""
  echo "ERROR: OpenGauss Database Master Docker Container was NOT successfully created."
  exit 1
}
echo "OpenGauss Database Master Docker Container created."

# sleep 30s

# PGAPPNAME="opengauss_slave1"
# docker run --network opengaussnetwork --ip $SLAVE_1_IP --privileged=true \
# --name $PGAPPNAME -h $PGAPPNAME -p $SLAVE_1_HOST_PORT:$SLAVE_1_HOST_PORT -d \
# -e PGAPPNAME=$PGAPPNAME \
# -e GS_PORT=$SLAVE_1_HOST_PORT \
# -e OG_SUBNET=$OG_SUBNET \
# -e GS_PASSWORD=$GS_PASSWORD \
# -e NODE_NAME=$PGAPPNAME \
# -e REPL_CONN_INFO="replconninfo1 = 'localhost=$SLAVE_1_IP localport=$SLAVE_1_LOCAL_PORT localservice=$SLAVE_1_HOST_PORT remotehost=$MASTER_IP remoteport=$MASTER_LOCAL_PORT remoteservice=$MASTER_HOST_PORT'\n" \
# summertao/opengauss:1.0.0 -M standby \
# || {
#   echo ""
#   echo "ERROR: OpenGauss Database Slave1 Docker Container was NOT successfully created."
#   exit 1
# }
# echo "OpenGauss Database Slave1 Docker Container created."

# docker run  --entrypoint "/bin/bash" --network opengaussnetwork --ip $SLAVE_1_IP --privileged=true \
# --name opengauss_slave1 -h opengauss_slave1 -p $SLAVE_1_HOST_PORT:$SLAVE_1_HOST_PORT -d \
# -e GS_PORT=$SLAVE_1_HOST_PORT \
# -e MASTER_IP=$MASTER_IP \
# -e SLAVE_1_IP=$SLAVE_1_IP \
# -e SLAVE_2_IP=$SLAVE_2_IP \
# -e GS_PASSWORD=$GS_PASSWORD \
# -e NODE_NAME=opengauss_slave1 \
# -e REPL_CONN_INFO="replconninfo1 = 'localhost=$SLAVE_1_IP localport=$SLAVE_1_LOCAL_PORT localservice=$SLAVE_1_HOST_PORT remotehost=$MASTER_IP remoteport=$MASTER_LOCAL_PORT remoteservice=$MASTER_HOST_PORT'\n" \
# summertao/opengauss:1.0.0 -c 'trap : TERM INT; sleep infinity & wait' \
# || {
#   echo ""
#   echo "ERROR: OpenGauss Database Slave1 Docker Container was NOT successfully created."
#   exit 1
# }
# echo "OpenGauss Database Slave1 Docker Container created."
