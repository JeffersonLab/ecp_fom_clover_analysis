#!/bin/bash
#SBATCH -A lgt104
#SBATCH -J PropBig64
#SBATCH -o %x-%j.out
#SBATCH -t 0:30:00
#SBATCH -N 64
#SBATCH -C nvme
#SBATCH --cpus-per-task=7
#SBATCH --ntasks-per-node=8
#SBATCH -x frontier00889,frontier00890,frontier05243,frontier05244,frontier05369,frontier05372,frontier05495,frontier05498,frontier05623,frontier05626,frontier05751,frontier05754,frontier05888,frontier06006,frontier06007,frontier06133,frontier06137,frontier06258,frontier06259,frontier06387,frontier06388,frontier06513,frontier06514,frontier06647,frontier06648,frontier06769,frontier06771,frontier06901,frontier06902,frontier07024,frontier07025,frontier07154,frontier07155,frontier07281,frontier07282,frontier07410,frontier07411,frontier07540,frontier07541,frontier07663,frontier07664,frontier07791,frontier07792,frontier07922,frontier07923,frontier08051,frontier08052,frontier08178,frontier08179,frontier08304,frontier08305,frontier08435,frontier08436,frontier08561,frontier08562,frontier08691,frontier08692,frontier08822,frontier08823,frontier08948,frontier09072,frontier10224,frontier10353,frontier10481,frontier05373,frontier05374,frontier05499,frontier05501,frontier05504,frontier05627,frontier05629,frontier05630,frontier05755,frontier05757,frontier06010,frontier06011,frontier06138,frontier06141,frontier06144,frontier06263,frontier06264,frontier06267,frontier06269,frontier06392,frontier06393,frontier06396,frontier06397,frontier06518,frontier06519,frontier06522,frontier06524,frontier06649,frontier06650,frontier06654,frontier06655,frontier06775,frontier06776,frontier06779,frontier06906,frontier06907,frontier06910,frontier06912,frontier07029,frontier07031,frontier07159,frontier07161,frontier07163,frontier07164,frontier07286,frontier07288,frontier07290,frontier07291,frontier07415,frontier07416,frontier07418,frontier07420,frontier07545,frontier07546,frontier07548,frontier07550,frontier07668,frontier07669,frontier07671,frontier07672,frontier07796,frontier07797,frontier07799,frontier07800,frontier07926,frontier07928,frontier07930,frontier08055,frontier08057,frontier08059,frontier08182,frontier08184,frontier08186,frontier08308,frontier08312,frontier08313,frontier08315,frontier08439,frontier08442,frontier08565,frontier08568,frontier08695,frontier08698,frontier08826,frontier08829,frontier08951,frontier08954,frontier08956,frontier09075,frontier09077,frontier09079,frontier10227,frontier10229,frontier10231,frontier10356,frontier10358,frontier10360,frontier10484,frontier10485,frontier10487,frontier10489
source ./env.sh

NODES=$SLURM_NNODES
NPROC=`expr \( $NODES \* 8 \)`
GEOM="1 4 8 16"
IOGEOM="1 1 4 8"
AMAP="2 3 0 1"

PROGDIR=`pwd`
PROG=${PROGDIR}/chroma
export QUDA_RESOURCE_PATH=${PROGDIR}/${NODES}
if [ ! -d ${QUDA_RESOURCE_PATH} ];
then 
	mkdir ${QUDA_RESORUCE_PATH}
fi

##
export QUDA_ENABLE_GDR=1
export QUDA_ENABLE_P2P=0

export GPUDIRECT=" -gpudirect "
export QUDA_PROFILE_OUTPUT_BASE=profile_prop_big_rocm4.5.2_${NODES}_GDR${QUDA_ENABLE_GDR}_${SLURM_JOBID}
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
srun -n ${NPROC} -N ${NODES} --ntasks-per-node=8 --cpus-per-task=7 --distribution=*:block ${CPU_MASK} ${MEMBIND} ./launcher.sh ${PROG} -i ./clover_quda_multigrid_test_big.ini.xml -geom ${GEOM} -iogeom ${IOGEOM} ${GPUDIRECT} 
sleep 10
srun -n ${NPROC} -N ${NODES} --ntasks-per-node=8 --cpus-per-task=7 --distribution=*:block ${CPU_MASK} ${MEMBIND} ./launcher.sh ${PROG} -i ./clover_quda_multigrid_test_big.ini.xml -geom ${GEOM} -iogeom ${IOGEOM} ${GPUDIRECT}
#cray_debug_end
