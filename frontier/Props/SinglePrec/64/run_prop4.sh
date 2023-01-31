#!/bin/bash
#SBATCH -A lgt104
#SBATCH -J Prop4
#SBATCH -o %x-%j.out
#SBATCH -t 0:30:00
#SBATCH -N 4
#SBATCH -C nvme
#SBATCH --cpus-per-task=7
#SBATCH --ntasks-per-node=8
source ./env.sh

NODES=$SLURM_NNODES
NPROC=`expr \( $NODES \* 8 \)`
GEOM="1 1 4 8"
IOGEOM="1 1 2 8"
AMAP="3 0 1 2"

PROGDIR=`pwd`
PROG=${PROGDIR}/chroma
export QUDA_RESOURCE_PATH=${PROGDIR}/${NODES}
if [ ! -d ${QUDA_RESOURCE_PATH} ];
then 
	mkdir ${QUDA_RESOURCE_PATH}
fi

##
export QUDA_ENABLE_GDR=1
export QUDA_ENABLE_P2P=0

export GPUDIRECT=" -gpudirect "
export QUDA_PROFILE_OUTPUT_BASE=profile_prop_rocm4.5.2_${NODES}_GDR${QUDA_ENABLE_GDR}_${SLURM_JOBID}
export MPICH_ENV_DISPLAY=1
export MPICH_GPU_SUPPORT_ENABLED=1
export MPICH_SMP_SINGLE_COPY_MODE=XPMEM
export MPICH_COLL_SYNC=MPI_Bcast
export MPICH_OFI_NIC_VERBOSE=2
export OMP_NUM_THREADS=1
export MPICH_OFI_NIC_POLICY=NUMA
export FI_MR_CACHE_MAX_COUNT=0

# New vars
rm -f ./core
ulimit -c unlimited 
rm -f ${QUDA_RESOURCE_PATH}/tunecache.tsv

export OMP_NUM_THREADS=1
export OMP_PROC_BIND=spread
MASK_0="0x00fe000000000000"
MASK_1="0xfe00000000000000"
MASK_2="0x0000000000fe0000"
MASK_3="0x00000000fe000000"
MASK_4="0x00000000000000fe"
MASK_5="0x000000000000fe00"
MASK_6="0x000000fe00000000"
MASK_7="0x0000fe0000000000"
MEMBIND="--mem-bind=map_mem:3,3,1,1,0,0,2,2"
CPU_MASK="--cpu-bind=mask_cpu:${MASK_0},${MASK_1},${MASK_2},${MASK_3},${MASK_4},${MASK_5},${MASK_6},${MASK_7}"
#cray_debug_start
srun -n ${NPROC} -N ${NODES} --ntasks-per-node=8 --cpus-per-task=7 --distribution=*:block ${CPU_MASK} ${MEMBIND} ./launcher.sh ${PROG} -i ./clover_quda_multigrid_test.ini.xml -geom ${GEOM} -iogeom ${IOGEOM} ${GPUDIRECT} 
sleep 10
srun -n ${NPROC} -N ${NODES} --ntasks-per-node=8 --cpus-per-task=7 --distribution=*:block ${CPU_MASK} ${MEMBIND} ./launcher.sh ${PROG} -i ./clover_quda_multigrid_test.ini.xml -geom ${GEOM} -iogeom ${IOGEOM} ${GPUDIRECT}
