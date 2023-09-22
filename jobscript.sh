#!/bin/bash
#SBATCH --time=0-00:15:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --mem-per-cpu=1000M

module load apptainer
#CONTAINER="openmpi-hybrid.sif"
CONTAINER="openmpi-hybrid-slurm.sif"
SCRIPT=""

CACHE_DIR="${SLURM_TMPDIR}/.cache"
srun --ntasks-per-node=1 mkdir -p $CACHE_DIR

#OVERLAY="${SLURM_TMPDIR}/overlay"
#srun --ntasks-per-node=1 mkdir -p $OVERLAY

#MPIRUN="srun --mpi=pmi2"
MPIRUN="mpirun"

#A_BIND="/var/spool,/etc/host.conf,/etc/libibverbs.d/mlx5.driver,/etc/libnl/classid,/etc/resolv.conf,/run/munge/munge.socket.2"
#A_BIND="$A_BIND,/usr/lib64/libibverbs/,/usr/lib64/libibverbs.so.1,/usr/lib64/libkeyutils.so.1,/usr/lib64/liblnetconfig.so.4,/usr/lib64/liblustreapi.so,/usr/lib64/libmunge.so.2,/usr/lib64/libnl-3.so.200,/usr/lib64/libnl-genl-3.so.200,/usr/lib64/libnl-route-3.so.200,/usr/lib64/librdmacm.so.1,/usr/lib64/libyaml-0.so.2"
#A_BIND="$A_BIND,$EBROOTLIBFABRIC/lib/libfabric.so.1,/opt/software/slurm"
#export APPTAINER_BIND="$A_BIND"

APPTAINER_OPTS="\
  --bind="${SLURM_TMPDIR}:/tmp,${CACHE_DIR}:/fd/.cache" \
  --home $PWD \
"
#  --containall \
#  --overlay=\"${OVERLAY}\" \

for CONTAINER in openmpi-hybrid.sif openmpi-hybrid-slurm.sif ; do
  for MPIRUN in mpirun mpiexec "srun --mpi=pmi2" ; do
    for TEST in /opt/mpitest /opt/mpitest_sendrecv ; do

      echo "running:"
      echo "  $MPIRUN apptainer exec \\"
      echo "    $APPTAINER_OPTS \\"
      echo "    ${CONTAINER} $TEST"
      echo ""
      echo "========================================="
      echo ""

      time ${MPIRUN}  apptainer  exec \
          ${APPTAINER_OPTS} \
          "${CONTAINER}"  $TEST

      echo ""
      echo "========================================="
      echo ""

    done
  done
done
