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
SLAVE_1_IP="172.18.0.102"
SLAVE_2_IP="172.18.0.103"
SLAVE_3_IP="172.18.0.104"

MASTER_HOST_PORT="5432"
MASTER_LOCAL_PORT="5434"

SLAVE_1_HOST_PORT="6432"
SLAVE_1_LOCAL_PORT="6434"

SLAVE_2_HOST_PORT="7432"
SLAVE_2_LOCAL_PORT="7434"

SLAVE_3_HOST_PORT="8432"
SLAVE_3_LOCAL_PORT="8434"

PGAPPNAME="opengauss_master"
docker run --network opengaussnetwork --ip $MASTER_IP --privileged=true \
--name $PGAPPNAME -h $PGAPPNAME -p $MASTER_HOST_PORT:$MASTER_HOST_PORT -d \
-e PGAPPNAME=$PGAPPNAME \
-e GS_PORT=$MASTER_HOST_PORT \
-e OG_SUBNET=$OG_SUBNET \
-e GS_PASSWORD=$GS_PASSWORD \
-e NODE_NAME=$PGAPPNAME \
-e REPL_CONN_INFO="replconninfo1 = 'localhost=$MASTER_IP localport=$MASTER_LOCAL_PORT localservice=$MASTER_HOST_PORT remotehost=$SLAVE_1_IP remoteport=$SLAVE_1_LOCAL_PORT remoteservice=$SLAVE_1_HOST_PORT'\nreplconninfo2 = 'localhost=$MASTER_IP localport=$MASTER_LOCAL_PORT localservice=$MASTER_HOST_PORT remotehost=$SLAVE_2_IP remoteport=$SLAVE_2_LOCAL_PORT remoteservice=$SLAVE_2_HOST_PORT'\nreplconninfo3 = 'localhost=$MASTER_IP localport=$MASTER_LOCAL_PORT localservice=$MASTER_HOST_PORT remotehost=$SLAVE_3_IP remoteport=$SLAVE_3_LOCAL_PORT remoteservice=$SLAVE_3_HOST_PORT'\n" \
summertao/opengauss:1.0.0 -M primary \
|| {
  echo ""
  echo "ERROR: OpenGauss Database Master Docker Container was NOT successfully created."
  exit 1
}
echo "OpenGauss Database Master Docker Container created."

sleep 30s

PGAPPNAME="opengauss_slave1"
docker run --network opengaussnetwork --ip $SLAVE_1_IP --privileged=true \
--name $PGAPPNAME -h $PGAPPNAME -p $SLAVE_1_HOST_PORT:$SLAVE_1_HOST_PORT -d \
-e PGAPPNAME=$PGAPPNAME \
-e GS_PORT=$SLAVE_1_HOST_PORT \
-e OG_SUBNET=$OG_SUBNET \
-e GS_PASSWORD=$GS_PASSWORD \
-e NODE_NAME=$PGAPPNAME \
-e REPL_CONN_INFO="replconninfo1 = 'localhost=$SLAVE_1_IP localport=$SLAVE_1_LOCAL_PORT localservice=$SLAVE_1_HOST_PORT remotehost=$MASTER_IP remoteport=$MASTER_LOCAL_PORT remoteservice=$MASTER_HOST_PORT'\nreplconninfo2 = 'localhost=$SLAVE_1_IP localport=$SLAVE_1_LOCAL_PORT localservice=$SLAVE_1_HOST_PORT remotehost=$SLAVE_2_IP remoteport=$SLAVE_2_LOCAL_PORT remoteservice=$SLAVE_2_HOST_PORT'\n" \
summertao/opengauss:1.0.0 -M standby \
|| {
  echo ""
  echo "ERROR: OpenGauss Database Slave1 Docker Container was NOT successfully created."
  exit 1
}
echo "OpenGauss Database Slave1 Docker Container created."

sleep 30s

PGAPPNAME="opengauss_slave2"
docker run --network opengaussnetwork --ip $SLAVE_2_IP --privileged=true \
--name $PGAPPNAME -h $PGAPPNAME -p $SLAVE_2_HOST_PORT:$SLAVE_2_HOST_PORT -d \
-e PGAPPNAME=$PGAPPNAME \
-e GS_PORT=$SLAVE_2_HOST_PORT \
-e OG_SUBNET=$OG_SUBNET \
-e GS_PASSWORD=$GS_PASSWORD \
-e NODE_NAME=$PGAPPNAME \
-e REPL_CONN_INFO="replconninfo1 = 'localhost=$SLAVE_2_IP localport=$SLAVE_2_LOCAL_PORT localservice=$SLAVE_2_HOST_PORT remotehost=$MASTER_IP remoteport=$MASTER_LOCAL_PORT remoteservice=$MASTER_HOST_PORT'\nreplconninfo2 = 'localhost=$SLAVE_2_IP localport=$SLAVE_2_LOCAL_PORT localservice=$SLAVE_2_HOST_PORT remotehost=$SLAVE_1_IP remoteport=$SLAVE_1_LOCAL_PORT remoteservice=$SLAVE_1_HOST_PORT'\nreplconninfo3 = 'localhost=$SLAVE_2_IP localport=$SLAVE_2_LOCAL_PORT localservice=$SLAVE_2_HOST_PORT remotehost=$SLAVE_3_IP remoteport=$SLAVE_3_LOCAL_PORT remoteservice=$SLAVE_3_HOST_PORT'\n" \
summertao/opengauss:1.0.0 -M standby \
|| {
  echo ""
  echo "ERROR: OpenGauss Database Slave2 Docker Container was NOT successfully created."
  exit 1
}
echo "OpenGauss Database Slave2 Docker Container created."

sleep 30s

PGAPPNAME="opengauss_slave3"
docker run --entrypoint "/bin/bash" --network opengaussnetwork --ip $SLAVE_3_IP --privileged=true \
--name $PGAPPNAME -h $PGAPPNAME -p $SLAVE_3_HOST_PORT:$SLAVE_3_HOST_PORT -d \
-e PGAPPNAME=$PGAPPNAME \
-e GS_PORT=$SLAVE_3_HOST_PORT \
-e OG_SUBNET=$OG_SUBNET \
-e GS_PASSWORD=$GS_PASSWORD \
-e NODE_NAME=$PGAPPNAME \
-e REPL_CONN_INFO="replconninfo1 = 'localhost=$SLAVE_3_IP localport=$SLAVE_3_LOCAL_PORT localservice=$SLAVE_3_HOST_PORT remotehost=$MASTER_IP remoteport=$MASTER_LOCAL_PORT remoteservice=$MASTER_HOST_PORT'\n" \
summertao/opengauss:1.0.0 -c 'trap : TERM INT; sleep infinity & wait' \
|| {
  echo ""
  echo "ERROR: OpenGauss Database Slave3 Docker Container was NOT successfully created."
  exit 1
}
echo "OpenGauss Database Slave3 Docker Container created."

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
