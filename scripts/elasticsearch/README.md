ElasticSearch on Wranlger User Guide
=====

This is the instruction of running ElasticSearch on Wrangler with Hadoop reservation.

### 1. Submit a Hadoop researvation 

Submit a Hadoop reservation on Wrangler portal https://portal.wrangler.tacc.utexas.edu, you will get a reservation id like hadoop+PEMFS+2033. This id can also be acquired by running 

    $ showres

### 2. Submit a sleep job to the Hadoop reservation

On Wrangler login node, run

   $ sbatch --reservation=hadoop+PEMFS+2033 sleep.slurm

By default, the sleep job only request three nodes, you can change the number to the numebr of nodes in your reservation.

Then you can check your job by running

   $ squeue | grep $USER

And you will find the nodes in the reservation in this format: c252-[101-103] or c252-[102, 104-107]. This is the hostlist you will use to start elastic search.

### 3. Login to the first node in allocation

On login node, run 

   $ ssh c252-101

### 4. Start ElasticSearch and Kibana

Make sure, you are on the first compute node in the reservation. Go to the directory that has the elastic-search-start.sh script, run

   $ ./elastic-search-start.sh c252-[101-103]

Wait until the script finishes.

A few things to keep in mind, the ElasticSearch's port is forwarded to http://wranlger.tacc.utexas.edu:59200.
The Kibana port is forwarded to http://wrangler.tacc.utexas.edu:55601.
For the time being, all ports are hard coded, but you can change them in the elastic-search-start.sh.

Then you can check the ElasticSearch cluster by running 

   $ curl -XGET 'http://localhost:9200/_cluster/state?pretty'

You will see all the nodes in the reservation in the result. 
You might also open a web browser and access http://wranlger.tacc.utexas.edu:9200/_cluster/state?pretty .

Now ElasticSearch is up running. You can insert the indices to ElasticSearch, and test it with Kibana interface.

### 5. Stop ElasticSearch and Kibana

   $ ./elastic-search-stop.sh c252-[101-103]

This script will kill all processes related to ElasticSearch and Kibana and release all the ports on login node.
