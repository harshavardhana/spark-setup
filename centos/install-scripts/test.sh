#!/bin/bash

source "$(dirname $(realpath $0))/env.sh"

export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
export HADOOP_HOME=$INSTALL_DIR/hadoop-${HADOOP_VERSION}
export SPARK_HOME=$INSTALL_DIR/spark-${SPARK_VERSION}-bin-without-hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$SPARK_HOME/bin
export SPARK_DIST_CLASSPATH=$(hadoop classpath)


spark-submit --master spark://$(cat "$INSTALL_DATA/master"):7077 \
		--conf spark.hadoop.fs.s3a.server-side-encryption-algorithm=SSE-C \
		--conf spark.hadoop.fs.s3a.server-side-encryption-key='MzJieXRlc2xvbmdzZWNyZXRrZXltdXN0cHJvdmlkZWQ=' \
		--conf fs.s3a.path.style.access=true \
		--conf fs.s3a.path.style.access=true \
		--conf fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
		test.py
