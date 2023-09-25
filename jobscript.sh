#!/bin/bash
#SBATCH --time=0-00:15:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --mem-per-cpu=1000M

module load apptainer

# create $CACHE_DIR on all participating nodes
CACHE_DIR="${SLURM_TMPDIR}/.cache"
srun --ntasks-per-node=1 mkdir -p $CACHE_DIR

APPTAINER_OPTS="\
  --bind="${SLURM_TMPDIR}:/tmp,${CACHE_DIR}:/fd/.cache" \
  --home $PWD \
"

for CONTAINER in openmpi-hybrid.sif openmpi-hybrid-slurm.sif ; do
  for MPIRUN in mpirun mpiexec "srun --mpi=pmi2" ; do
    for TEST in /opt/mpitest /opt/mpitest_sendrecv ; do
      echo "running:"
      echo "  ${MPIRUN} apptainer exec \\"
      echo "    ${APPTAINER_OPTS} \\"
      echo "    ${CONTAINER} $TEST"
      echo ""
      echo "========================================="
      echo ""
      time  ${MPIRUN}  apptainer  exec \
            ${APPTAINER_OPTS} \
            ${CONTAINER}  $TEST
      echo ""
      echo "========================================="
      echo ""
    done
  done
done
