#!/bin/bash
#SBATCH -J SPARK	   # job name
#SBATCH -o SPARK-%j         # output and error file name (%j expands to jobID)
#SBATCH -N 4              # total number of nodes
#SBATCH -n 96
#SBATCH -p hadoop     	   # queue (partition) -- normal, development, etc.
#SBATCH -t 8:00:00        # run time (hh:mm:ss) - 4 hours
#SBATCH -A PEMFS    #TG-CCR150011    # project name

NODE_LIST=`scontrol show hostnames $SLURM_NODELIST`
NODE_HOSTNAME=`hostname -s`

echo "TACC: NODE_LIST: $NODE_LIST"
echo "TACC: NODE_HOSTNAME: $NODE_HOSTNAME"



#Copy conf templates into ~/.spark/conf
if [ ! -d ~/.spark ]; then
    mkdir ~/.spark
fi

if [ -d ~/.spark/conf ]; then
    rm -rf ~/.spark/conf
fi

mkdir ~/.spark/conf
cp -r /etc/spark/conf/spark-defaults.conf ~/.spark/conf/

#Update slaves with worker nodes
for n in `echo $NODE_LIST | cut -d " " -f2-`;
do
    echo adding $n
    echo $n >> ~/.spark/conf/slaves
done

#Update spark-defaults.conf
echo "spark.executor.memory   112g" >> ~/.spark/conf/spark-defaults.conf
echo "spark.locality.wait   3000" >> ~/.spark/conf/spark-defaults.conf

#Update spark-env.sh
cat /etc/spark/conf/spark-env.sh | sed "s/\/var\/run/\/tmp/" | sed "s/\/var\/log/\/tmp/" > ~/.spark/conf/spark-env.sh

#Set env variable
export SPARK_CONF_DIR=~/.spark/conf

/usr/lib/spark/sbin/start-all.sh

sleep 3600
