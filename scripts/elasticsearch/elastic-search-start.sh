#!/bin/bash

if [ -z "$1" ]
then
  echo "Run the shell like: ./elastic-search-start.sh c252-[101-103]"
  exit
fi


SLURM_NODELIST=$1
NODE_LIST=`scontrol show hostnames $SLURM_NODELIST`
NODE_HOSTNAME=`hostname -s`

echo "TACC: NODE_LIST: $NODE_LIST"
echo "TACC: NODE_HOSTNAME: $NODE_HOSTNAME"



#Copy conf templates into ~/.elasticsearch/config
if [ ! -d ~/.elasticsearch ]; then
    mkdir ~/.elasticsearch
fi

if [ -d ~/.elasticsearch/config ]; then
    rm -rf ~/.elasticsearch/config
fi

mkdir ~/.elasticsearch/config
cp -r /opt/apps/elasticsearch-5.0.1/config/* ~/.elasticsearch/config/


#set path.data, path.logs, and network.host
echo "path.data: /tmp/data" >> ~/.elasticsearch/config/elasticsearch.yml
echo "path.logs: /tmp/logs" >> ~/.elasticsearch/config/elasticsearch.yml
echo "network.host: [_p2p2_, _ib0_, _local_]" >> ~/.elasticsearch/config/elasticsearch.yml

#set up unicast.hosts
hosts="discovery.zen.ping.unicast.hosts: ["
for n in $NODE_LIST;
do
    echo adding $n
    hosts=$hosts\"$n\",
done
hosts=${hosts:0:-1}]

echo $hosts >> ~/.elasticsearch/config/elasticsearch.yml

#start master
nohup /opt/apps/elasticsearch-5.0.1/bin/elasticsearch -Epath.conf=${HOME}/.elasticsearch/config -Ecluster.name=es-cluster -Enode.name=${NODE_HOSTNAME} >/tmp/es-start.log 2>&1 &

sleep 10

#start slaves
for n in `echo $NODE_LIST | cut -d " " -f2-`;
do
  echo launching on $n
  ssh $n "nohup /opt/apps/elasticsearch-5.0.1/bin/elasticsearch -Epath.conf=${HOME}/.elasticsearch/config -Ecluster.name=es-cluster -Enode.name=$n > /tmp/es-start.log 2>&1 &"
done

sleep 10

#setup port forwarding
ssh -f -g -N -R 59200:127.0.0.1:9200 login1
echo "port forwarding done"

#setup kibana
tar zxf /data/apps/kibana-5.0.1-linux-x86_64.tar.gz -C /tmp
nohup /tmp/kibana-5.0.1-linux-x86_64/bin/kibana > /tmp/kibana-start.log 2>&1 &
ssh -f -g -N -R 55601:127.0.0.1:5601 login1


