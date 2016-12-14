#!/bin/bash

if [ -z "$1" ]
then
  echo "Run the shell like: ./elastic-search-kill.sh c252-[101-103]"
  exit
fi

SLURM_NODELIST=$1
NODE_LIST=`scontrol show hostnames $SLURM_NODELIST`
NODE_HOSTNAME=`hostname -s`

echo "TACC: NODE_LIST: $NODE_LIST"
echo "TACC: NODE_HOSTNAME: $NODE_HOSTNAME"



#kill master
echo "kill elasticsearch on $NODE_HOSTNAME"
kill -9 `jps | grep Elasticsearch | cut -d " " -f 1`

sleep 1

#kill slaves
for n in `echo $NODE_LIST | cut -d " " -f2-`;
do
  echo "kill elasticsearch on $n"
  ssh $n "kill -9 \`jps | grep Elasticsearch | cut -d \" \" -f 1\`"
done

sleep 1

#kill kibana
kill -9 `ps aux | grep kibana | head -n 1 | awk '{print $2}'`

#stop port forwarding
echo "stop port forwarding"
for pid in `ps aux | grep "ssh -f" | head -n 2 | awk '{print $2}'`
do
  echo "stop process $pid"
  kill -9 $pid
done
echo "stop port forwarding complete"
rm -f /tmp/ssh.lock

