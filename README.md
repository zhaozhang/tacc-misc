This is the standalone spark launching script.
To use it:

1) Add the following line in ~/.bashrc

   $ export SPARK_CONF_DIR=~/.spark/conf

2) Run 

   $ sbatch spark.slurm

3) Login to the compute node, then run with the master address, e.g.,

   $ spark-shell --master spark://c252-101:7077     

Notes:
This script only works with c252 rack, and expecting the node list in the format of c252-[101-104].
So it has to work with at least 3 nodes.
