#!/bin/bash
#SBATCH --time=0-00:15:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --mem-per-cpu=1000M

module load StdEnv/2020 gcc/9.3.0 openmpi/4.0.3
module load apptainer

# create $CACHE_DIR on all participating nodes
CACHE_DIR="${SLURM_TMPDIR}/.cache"
srun --ntasks-per-node=1 mkdir -p $CACHE_DIR

APPTAINER_OPTS="\
  --bind="${SLURM_TMPDIR}:/tmp,${CACHE_DIR}:/fd/.cache" \
  --home $PWD \
"

# suppress PMIX ERROR: "ERROR in file gds_ds12_lock_pthread.c"
export PMIX_MCA_gds="^ds12"
# The btl_vader_single_copy_mechanism can't be used with containers.
export OMPI_MCA_btl_vader_single_copy_mechanism="none"

for CONTAINER in openmpi-hybrid.sif openmpi-hybrid-slurm.sif ; do
  for MPIRUN in mpirun mpiexec "srun --mpi=pmi2" ; do
    for TEST in /opt/mpitest /opt/mpitest_sendrecv "/opt/reduce_stddev 100000000" ; do
      echo "running:"
      echo "  ${MPIRUN} apptainer --silent exec \\"
      echo "    ${APPTAINER_OPTS} \\"
      echo "    ${CONTAINER} $TEST"
      echo ""
      echo "========================================="
      echo ""
      time  ${MPIRUN}  apptainer --silent exec \
            ${APPTAINER_OPTS} \
            ${CONTAINER}  $TEST
      echo ""
      echo "========================================="
      echo ""
    done
  done
done
