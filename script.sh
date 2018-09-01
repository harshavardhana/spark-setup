#!/bin/bash

MASTER_IP=$(cat master)
SLAVES_IP=$(cat slaves)

ARCHIVE_TARBALL="install-scripts.tar.gz"
SSH_OPTS="-oStrictHostKeyChecking=no"

cp master slaves install-scripts/data/
tar -zcf $ARCHIVE_TARBALL install-scripts/

master=1
for ip in $MASTER_IP $SLAVES_IP; do
    scp $SSH_OPTS $ARCHIVE_TARBALL root@$ip:~/
    arg="slave $ip"
    [[ $master -eq 1 ]] && arg="master" && master=0
    ssh $SSH_OPTS root@$ip "cd ~/; tar -xzf $ARCHIVE_TARBALL"
    ssh $SSH_OPTS root@$ip "bash ~/install-scripts/install-spark.sh $arg"
    shift
done
