#!/bin/bash
cd `dirname $0`

img_mvn="maven:3.3.3-jdk-8"                 # docker image of maven
m2_cache=~/.m2                              # the local maven cache dir
proj_home=$PWD                              # the project root dir
img_output="deepexi/springboot-admin-server"         # output image tag

git pull  # should use git clone https://name:pwd@xxx.git

echo "use docker maven"
    docker run --rm \
        -v $m2_cache:/root/.m2 \
        -v $proj_home:/usr/src/mymaven \
        -w /usr/src/mymaven $img_mvn mvn clean package -U

sudo mv $proj_home/target/springboot-admin-server-*.jar $proj_home/target/demo.jar # 兼容所有sh脚本
docker build -t $img_output .

# 删除容器
docker rm -f springboot-admin-server &> /dev/null

# 启动镜像
docker run -d --restart=on-failure:5 --privileged=true \
    -p 8769:8769 \
    -w /home \
    --name springboot-admin-server deepexi/springboot-admin-server \
    java \
        -Djava.security.egd=file:/dev/./urandom \
        -Duser.timezone=Asia/Shanghai \
        -XX:+PrintGCDateStamps \
        -XX:+PrintGCTimeStamps \
        -XX:+PrintGCDetails \
        -XX:+HeapDumpOnOutOfMemoryError \
        -jar /home/demo.jar