# 1. Build Image

```console
$ ./buildDockerImage.sh
```

# 2. Create Master/Slave Containers

```console
$ ./create_master_slave_op.sh
```

# 3. Launch Slave DB

```console
$ docker exec -it $slave_container_id bash
$ entrypoint.sh gaussdb -M standby
```

# 4. Full Backup Slave DB

```console
$ docker exec -it $slave_container_id bash
$ su omm
$ gs_ctl build -D $PGDATA/
```

# 5. Create DB and User in Master

```console
$ docker exec -it $master_container_id bash
$ su omm
$ gsql -v ON_ERROR_STOP=1 --username omm --password omm@Password123 --dbname postgres --set db="omm" --set passwd="omm@Password123" <<-'EOSQL'
                        CREATE DATABASE :"db" ;
                        create user gaussdb with login password :"passwd" ;
EOSQL

$ gsql -v ON_ERROR_STOP=1 --username omm --password omm@Password123 --dbname postgres --set passwd="RepUser@2020" --set user="repuser" <<-'EOSQL'
                        create user :"user" SYSADMIN REPLICATION password :"passwd" ;
EOSQL
```

# 6. Inspect Sync Info in Master/Slave

```console
$ docker exec -it $master_container_id/$slave_container_id bash
$ su omm
$ gs_ctl query -D $PGDATA/
$ 
```

# 7. Connect to DB

```console
$ docker exec -it $master_container_id/$slave_container_id bash
$ su omm
$ gsql -p 5432 # slave1端口为6432
$ 
```

# 8. Set up DB
> ***进一步初始化数据库和添加应用用户请参考：***[https://www.modb.pro/db/27572](https://www.modb.pro/db/27572)

# 持久化存储数据
容器一旦被删除，容器内的所有数据和配置也均会丢失，而从镜像重新运行一个容器的话，则所有数据又都是呈现在初始化状态，因此对于数据库容器来说，为了防止因为容器的消亡或者损坏导致的数据丢失，需要进行持久化存储数据的操作。通过在`docker run`的时候指定`-v`参数来实现。比如以下命令将会指定将openGauss的所有数据文件存储在宿主机的summertao/opengauss下。

```console
$  docker run --name opengauss --privileged=true -d -e GS_PASSWORD=omm@Password123 \
    -v /summertao/opengauss:/var/lib/opengauss \
    summertao/opengauss:latest
```
