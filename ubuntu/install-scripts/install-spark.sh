#!/bin/bash

set -x

source "$(dirname $(realpath $0))/env.sh"

NODE_TYPE="$1"
SLAVE_NODE_IP="$2"

mkdir -p $INSTALL_DIR && pushd $INSTALL_DIR

wget -c https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-without-hadoop.tgz && \
	     tar -xzf spark-$SPARK_VERSION-bin-without-hadoop.tgz

wget -c http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
               tar -xf hadoop-$HADOOP_VERSION.tar.gz && \

sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update # && apt-get -o Dpkg::Options::="--force-confold" --force-yes -y dist-upgrade
sudo apt-get -y install psmisc python oracle-java8-installer oracle-java8-set-default

killall -9 java
rm /tmp/spark-home/ubuntu-org.apache.spark.deploy.*

export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
export HADOOP_HOME=$INSTALL_DIR/hadoop-${HADOOP_VERSION}
export SPARK_HOME=$INSTALL_DIR/spark-${SPARK_VERSION}-bin-without-hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$SPARK_HOME/bin
export SPARK_DIST_CLASSPATH=$(hadoop classpath)

cp $INSTALL_DATA/core-site.xml $INSTALL_DIR/hadoop-$HADOOP_VERSION/etc/hadoop/core-site.xml

cp $INSTALL_DIR/hadoop-${HADOOP_VERSION}/share/hadoop/tools/lib/hadoop-aws-${HADOOP_VERSION}.jar \
	   $INSTALL_DATA/jars/* \
	   $INSTALL_DIR/spark-${SPARK_VERSION}-bin-without-hadoop/jars

if [ "$NODE_TYPE" == "master" ]; then
    sudo cp $INSTALL_DATA/spark-test.id_rsa /home/ubuntu/.ssh
    echo "Host *" >/home/ubuntu/.ssh/config
    echo "    StrictHostKeyChecking no" >>/home/ubuntu/.ssh/config
    echo "    IdentityFile ~/.ssh/spark-test.id_rsa" >>/home/ubuntu/.ssh/config

    export SPARK_MASTER_HOST=$(cat "$INSTALL_DATA/master")
    $INSTALL_DIR/spark-${SPARK_VERSION}-bin-without-hadoop/sbin/start-master.sh
else
    export SPARK_LOCAL_IP=$SLAVE_NODE_IP
    $INSTALL_DIR/spark-${SPARK_VERSION}-bin-without-hadoop/sbin/start-slave.sh spark://$(cat "$INSTALL_DATA/master"):7077
fi
