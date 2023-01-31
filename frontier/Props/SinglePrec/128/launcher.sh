#!/bin/bash

# IS this magic actualy needed ?
#echo "Executing rocm-smi"
#${ROCM_PATH}/bin/rocm-smi > /dev/null 2>&1

# Write into the NVME since /tmp is in memory
#
DIR=/mnt/bb/${USER}/${USER}_${SLURM_JOBID}_${SLURM_LOCALID}

if [ ! -d ${DIR} ];
then 
	echo `/bin/hostname` Creating ${DIR}
	mkdir -p ${DIR}
fi

# Run the command redirecting temporary file output to DIR
$* -temp-files-path ${DIR} -keep-files

# Clean up after we are done
rm -rf ${DIR}
