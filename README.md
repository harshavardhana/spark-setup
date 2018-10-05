# Spark install
This document explains how to configure spark master, slave configuration. This document assumes you are running on Ubuntu 18.04 or CentOS 7.5
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
## Setup bash envs on Ubuntu
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

export SPARK_MASTER_HOST=spark://$(cat "$INSTALL_DATA/master"):7077
```

## Setup bash envs on CentOS
Make sure to set correct bash envs for future setups, save the following to your `.bashrc` or `.bash_profile`
```
export INSTALL_DIR="/home/centos/install/"
export INSTALL_DATA="/home/centos/install-scripts/data/"
export SPARK_VERSION=2.3.1
export HADOOP_VERSION=3.1.0

export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
export HADOOP_HOME=$INSTALL_DIR/hadoop-${HADOOP_VERSION}
export SPARK_HOME=$INSTALL_DIR/spark-${SPARK_VERSION}-bin-without-hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$SPARK_HOME/bin
export SPARK_DIST_CLASSPATH=$(hadoop classpath)

export SPARK_MASTER_HOST=spark://$(cat "$INSTALL_DATA/master"):7077
```

## Setup spark-bench
Just follow the quick start guide https://codait.github.io/spark-bench/quickstart/, install and extract the released binary on master. Now upload relevant CSVs to your S3 server, in our example we are going to use the following CSV

```
curl "https://esa.un.org/unpd/wpp/DVD/Files/1_Indicators%20(Standard)/CSV_FILES/WPP2017_TotalPopulationBySex.csv" > TotalPopulation.csv
```

Upload around a 4 csv objects.
```
for i in $(seq 1 4); do
   mc cp TotalPopulation.csv myminio/csvs/${i}.csv
done

```

Create a new workload configuration for `spark-bench`
```
cat > minio-csvs.conf << EOF
spark-bench = {
  spark-submit-config = [{
    suites-parallel = false
    workload-suites = [
      {
        descr = "Run SQL queries over s3a"
        benchmark-output = "console"
        parallel = true
        repeat = 10
        workloads = [
          {
            name = "sql"
            input = ["s3a://csvs/1.csv", "s3a://csvs/2.csv", "s3a://csvs/3.csv", "s3a://csvs/4.csv"]
            query = ["select * from input", "select * from input", "select * from input", "select * from input"]
            cache = false
          }
        ]
      }
    ]
  }]
}
EOF
```

Run the spark-bench workload
```
./bin/spark-bench.sh minio-csvs.conf
```

Benchmark output will be written to console
```
+----+-------------+-------------+---+-----+--------+-------------------+-----------+--------+------+---------+--------------------+-------------+--------------------+-----------------+--------------------+--------------------+-----------------+-----------------------+--------------------+--------------------+--------------------+
|name|    timestamp|total_Runtime|run|cache|saveTime|           queryStr|   loadTime|saveMode|output|queryTime|               input|numPartitions|   spark.driver.host|spark.driver.port|          spark.jars|      spark.app.name|spark.executor.id|spark.submit.deployMode|        spark.master|        spark.app.id|         description|
+----+-------------+-------------+---+-----+--------+-------------------+-----------+--------+------+---------+--------------------+-------------+--------------------+-----------------+--------------------+--------------------+-----------------+-----------------------+--------------------+--------------------+--------------------+
| sql|1538642162377|  21641491001|  0|false|       0|select * from input|21634913956|   error|      |  6577045|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
| sql|1538642164422|  21767312313|  0|false|       0|select * from input|21761389669|   error|      |  5922644|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
| sql|1538642148105|  21759237306|  0|false|       0|select * from input|21741526529|   error|      | 17710777|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
| sql|1538642156901|  21007725159|  0|false|       0|select * from input|21000427859|   error|      |  7297300|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
| sql|1538642150640|  23949310544|  0|false|       0|select * from input|23941320485|   error|      |  7990059|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
| sql|1538642163506|  21501061826|  0|false|       0|select * from input|21495645717|   error|      |  5416109|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
| sql|1538642149339|  24071457652|  0|false|       0|select * from input|24063038739|   error|      |  8418913|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
| sql|1538642155966|  22403508714|  0|false|       0|select * from input|22396200185|   error|      |  7308529|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
| sql|1538642152291|  21196292750|  0|false|       0|select * from input|21188956605|   error|      |  7336145|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
| sql|1538642157832|  21956198968|  0|false|       0|select * from input|21948648761|   error|      |  7550207|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
| sql|1538642160046|  23567871067|  0|false|       0|select * from input|23560977586|   error|      |  6893481|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
| sql|1538642161263|  21536284458|  0|false|       0|select * from input|21529602169|   error|      |  6682289|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
| sql|1538642151576|  20626117841|  0|false|       0|select * from input|20617600607|   error|      |  8517234|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
| sql|1538642159064|  21495898464|  0|false|       0|select * from input|21487513216|   error|      |  8385248|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
| sql|1538642153559|  15250228804|  0|false|       0|select * from input|15048393482|   error|      |201835322|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
| sql|1538642154722|  20676605783|  0|false|       0|select * from input|20670391208|   error|      |  6214575|s3a://csv-vs-parq...|             |ip-172-31-68-171....|            43725|file:/home/ubuntu...|com.ibm.sparktc.s...|           driver|                 client|spark://172.31.68...|app-2018100408353...|Run SQL queries o...|
+----+-------------+-------------+---+-----+--------+-------------------+-----------+--------+------+---------+--------------------+-------------+--------------------+-----------------+--------------------+--------------------+-----------------+-----------------------+--------------------+--------------------+--------------------+
```
