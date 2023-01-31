module load craype-accel-amd-gfx90a
module load PrgEnv-cray
module load amd/4.5.2
module load cray-mpich/8.1.14

module load cmake
module load ninja
module list

export MPICH_ROOT=/opt/cray/pe/mpich/8.1.14
export GTL_ROOT=/opt/cray/pe/mpich/8.1.14/gtl/lib
export MPICH_DIR=${MPICH_ROOT}/ofi/amd/4.4

## These must be set before running

export TOPDIR_HIP=/ccs/home/bjoo/Chroma/Build/hip-jit
export SRCROOT=${TOPDIR_HIP}/../src
export BUILDROOT=${TOPDIR_HIP}/build
export INSTALLROOT=${TOPDIR_HIP}/install
export TARGET_GPU=gfx90a

MPI_CFLAGS="${CRAY_XPMEM_INCLUDE_OPTS} -I${MPICH_DIR}/include "
MPI_LDFLAGS="-L$HOME/install/upstream-llvm/lib -L/opt/cray/libfabric/1.15.0.0/lib64  -Wl,--rpath=/opt/cray/libfabric/1.15.0.0/lib64 ${CRAY_XPMEM_POST_LINK_OPTS} -lxpmem  -Wl,-rpath=${MPICH_DIR}/lib -L${MPICH_DIR}/lib -lmpi -Wl,-rpath=${GTL_ROOT} -L${GTL_ROOT} -lmpi_gtl_hsa"

export PK_BUILD_TYPE="Release"

export PATH=${ROCM_PATH}/bin:${ROCM_PATH}/llvm/bin:${PATH}
export LD_LIBRARY_PATH=${INSTALLROOT}/chroma/lib:${INSTALLROOT}/quda/lib:${INSTALLROOT}/qdpxx/lib:${INSTALLROOT}/qmp/lib:${ROCM_PATH}/lib:${ROCM_PATH}/llvm/lib:${MPICH_DIR}/lib:${GTL_ROOT}:/opt/cray/libfabric/1.15.0.0/lib64:${LD_LIBRARY_PATH}
