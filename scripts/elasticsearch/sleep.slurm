#!/bin/bash
#SBATCH -J SLEEP	   # job name
#SBATCH -o SLEEP-%j.out         # output and error file name (%j expands to jobID)
#SBATCH -N 3              # total number of nodes
#SBATCH -n 72
#SBATCH -p hadoop     	   # queue (partition) -- normal, development, etc.
#SBATCH -t 8:00:00        # run time (hh:mm:ss) - 4 hours

sleep 48h
