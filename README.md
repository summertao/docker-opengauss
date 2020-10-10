# 一、OpenGauss Server编译流程
## 1. 下载openGauss源码
可以从开源社区下载openGauss-server源码。下载解压后重命名为openGauss-server。
可以通过[此处](https://opengauss.obs.cn-south-1.myhuaweicloud.com/1.0.0/openGauss-third_party_binarylibs.tar.gz)获取编译好的binarylibs。下载后解压缩并重命名为binarylibs。

## 2. 配置环境变量
```console
export CODE_BASE=/home/omm/software/openGauss-server
export BINARYLIBS=/home/omm/software/binarylibs
export GAUSSHOME=/home/omm/software/openGauss-server/dest
export GCC_PATH=$BINARYLIBS/buildtools/centos7.6_x86_64/gcc8.2/
export CC=$GCC_PATH/gcc/bin/gcc
export CXX=$GCC_PATH/gcc/bin/g++
export LD_LIBRARY_PATH=$GAUSSHOME/lib:$GCC_PATH/gcc/lib64:$GCC_PATH/isl/lib:$GCC_PATH/mpc/lib/:$GCC_PATH/mpfr/lib/:$GCC_PATH/gmp/lib/:$LD_LIBRARY_PATH
export PATH=$GAUSSHOME/bin:$GCC_PATH/gcc/bin:$PATH
```

## 3. 执行build
```console
$ ./build.sh -3rd $BINARYLIBS

```

编译完的文件在$GAUSSHOME文件夹中，默认为Release版本。

## 4. 编译完成后打包

```console
$ cd $GAUSSHOME
$ tar -jcvf ../openGauss-1.0.0-CentOS-64bit.tar.bz2 ./
```

# 二、OpenGauss Docker部署流程

## 1. Build Image

```console
$ ./buildDockerImage.sh
```

## 2. Create Master/Slave Containers

```console
$ ./create_master_slave_op.sh
```

## 3. Inspect Sync Info in Master/Slave

```console
$ docker exec -it $master_container_id/$slave_container_id bash
$ su omm
$ gs_ctl query -D $PGDATA/
$ 
```

## 4. Connect to Master DB

```console
$ docker exec -it $master_container_id/$slave_container_id bash
$ su omm
$ gsql -p 5432 # slave1端口为6432
$ 
```

## 5. Set up DB
> ***进一步初始化数据库和添加应用用户请参考：***[https://www.modb.pro/db/27572](https://www.modb.pro/db/27572)

## 持久化存储数据
容器一旦被删除，容器内的所有数据和配置也均会丢失，而从镜像重新运行一个容器的话，则所有数据又都是呈现在初始化状态，因此对于数据库容器来说，为了防止因为容器的消亡或者损坏导致的数据丢失，需要进行持久化存储数据的操作。通过在`docker run`的时候指定`-v`参数来实现。比如以下命令将会指定将openGauss的所有数据文件存储在宿主机的summertao/opengauss下。

```console
$ docker run --name opengauss --privileged=true -d -e GS_PASSWORD=omm@Password123 \
    -v /summertao/opengauss:/var/lib/opengauss \
    summertao/opengauss:latest
```
