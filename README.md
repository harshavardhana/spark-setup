# Spark install
This document explains how to configure spark master, slave configuration. This document assumes you are running on Ubuntu 18.04,
please make changes accordingly to your favorite distribution.

> NOTE:
> - Make sure you only install OpenJDK8 or Oracle Java 8 on your distribution, aws-sdk-java jars don't support Java 9 and above.
> - This script assumes that you have password less ssh access from master to slaves, make sure that is configured before you read this document.

## Download scripts
```
git clone https://github.com/harshavardhana/spark-setup
```
### Master node
Put the IP of the master node in `master` file.
```
cd spark-setup
echo "<master_ip>" > master
```

### Slave nodes
Put the IPs of all slave nodes in `slaves` file.
```
cd spark-setup
echo "<slave_ip_1>" >> slave
echo "<slave_ip_2>" >> slave
...
```

### Run `ssh-keygen`
Store private & public keys under `data/` with `spark-test.id_rsa` and `spark-test.id_rsa.pub` names.

### Install
Deploy spark now.
```
./script.sh
```

## Setup bash envs
Make sure to set correct bash envs for future setups, save the following to your `.bashrc` or `.bash_profile`
```
export INSTALL_DIR="/home/ubuntu/install/"
export INSTALL_DATA="/home/ubuntu/install-scripts/data/"
export SPARK_VERSION=2.3.1
export HADOOP_VERSION=3.1.0

export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
export HADOOP_HOME=$INSTALL_DIR/hadoop-${HADOOP_VERSION}
export SPARK_HOME=$INSTALL_DIR/spark-${SPARK_VERSION}-bin-without-hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$SPARK_HOME/bin
export SPARK_DIST_CLASSPATH=$(hadoop classpath)
```
