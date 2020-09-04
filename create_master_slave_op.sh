#!/bin/bash -e
docker network rm opengaussnetwork
docker network create --subnet=172.18.0.0/24 opengaussnetwork \
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

MASTER_HOST_PORT="5432"
MASTER_LOCAL_PORT="5434"

SLAVE_1_HOST_PORT="6432"
SLAVE_1_LOCAL_PORT="6434"

SLAVE_2_HOST_PORT="7432"
SLAVE_2_LOCAL_PORT="7434"

docker run --network opengaussnetwork --ip $MASTER_IP --privileged=true \
--name opengauss_master -h opengauss_master -p $MASTER_HOST_PORT:$MASTER_HOST_PORT -d \
-e GS_PORT=$MASTER_HOST_PORT \
-e MASTER_IP=$MASTER_IP \
-e SLAVE_1_IP=$SLAVE_1_IP \
-e SLAVE_2_IP=$SLAVE_2_IP \
-e GS_PASSWORD=$GS_PASSWORD \
-e NODE_NAME=opengauss_master \
-e REPL_CONN_INFO="replconninfo1 = 'localhost=$MASTER_IP localport=$MASTER_LOCAL_PORT localservice=$MASTER_HOST_PORT remotehost=$SLAVE_1_IP remoteport=$SLAVE_1_LOCAL_PORT remoteservice=$SLAVE_1_HOST_PORT'\n" \
summertao/opengauss:1.0.0 -M primary \
|| {
  echo ""
  echo "ERROR: OpenGauss Database Master Docker Container was NOT successfully created."
  exit 1
}
echo "OpenGauss Database Master Docker Container created."

sleep 20s

docker run --network opengaussnetwork --ip $SLAVE_1_IP --privileged=true \
--name opengauss_slave1 -h opengauss_slave1 -p $SLAVE_1_HOST_PORT:$SLAVE_1_HOST_PORT -d \
-e GS_PORT=$SLAVE_1_HOST_PORT \
-e MASTER_IP=$MASTER_IP \
-e SLAVE_1_IP=$SLAVE_1_IP \
-e SLAVE_2_IP=$SLAVE_2_IP \
-e GS_PASSWORD=$GS_PASSWORD \
-e NODE_NAME=opengauss_slave1 \
-e REPL_CONN_INFO="replconninfo1 = 'localhost=$SLAVE_1_IP localport=$SLAVE_1_LOCAL_PORT localservice=$SLAVE_1_HOST_PORT remotehost=$MASTER_IP remoteport=$MASTER_LOCAL_PORT remoteservice=$MASTER_HOST_PORT'\n" \
summertao/opengauss:1.0.0 -M standby \
|| {
  echo ""
  echo "ERROR: OpenGauss Database Slave1 Docker Container was NOT successfully created."
  exit 1
}
echo "OpenGauss Database Slave1 Docker Container created."

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
