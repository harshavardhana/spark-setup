#!/bin/bash

set -x

INSTALL_DIR="/root/install/"
INSTALL_DATA="/root/install-scripts/data/"
SPARK_VERSION=2.3.1
HADOOP_VERSION=3.1.0

NODE_TYPE="$1"
MASTER_NODE_IP="$2"

mkdir -p $INSTALL_DIR && pushd $INSTALL_DIR

wget -c https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-without-hadoop.tgz && \
	     tar -xzf spark-$SPARK_VERSION-bin-without-hadoop.tgz

wget -c http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
               tar -xf hadoop-$HADOOP_VERSION.tar.gz && \

apt-get update # && apt-get -o Dpkg::Options::="--force-confold" --force-yes -y dist-upgrade
apt-get -y install psmisc default-jre

killall java
rm /tmp/spark-root-org.apache.spark.deploy.*

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
    export SPARK_MASTER_HOST=$MASTER_NODE_IP
    $INSTALL_DIR/spark-${SPARK_VERSION}-bin-without-hadoop/sbin/start-master.sh
else
    $INSTALL_DIR/spark-${SPARK_VERSION}-bin-without-hadoop/sbin/start-slave.sh http://$MASTER_NODE_IP:7077/
fi


