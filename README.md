# Open MPI Hybrid Container

This is an Apptainer container with Open MPI based on
https://apptainer.org/docs/user/1.2/mpi.html

The container itself should be started with `mpirun` or `srun`
so that multiple copies of the container can run on several
different nodes on an HPC cluster

Note that running Open MPI applications in containers works
with both `mpirun` and `mpiexec`. In order to use `srun`,
the Open MPI needs to have been compiled with `--with-slurm`
(see `openmpi-hybrid-slurm.def``).

## Building Open MPI container from scratch (bootstrapped)

```bash
sudo apptainer build --fix-perms openmpi-hybrid.sif openmpi-hybrid.def

sudo apptainer build --fix-perms openmpi-hybrid-slurm.sif openmpi-hybrid-slurm.def
```

## Slurm Jobscript to run the test-cases inside

```bash
#!/bin/bash
#SBATCH --time=0-00:15:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --mem-per-cpu=1000M

module load StdEnv/2020 gcc/9.3.0 openmpi/4.0.3
module load apptainer
#CONTAINER="openmpi-hybrid.sif"
CONTAINER="openmpi-hybrid-slurm.sif"

# create $CACHE_DIR on all participating nodes
CACHE_DIR="${SLURM_TMPDIR}/.cache"
srun --ntasks-per-node=1 mkdir -p $CACHE_DIR

MPIRUN="srun --mpi=pmi2"

# suppress PMIX ERROR: "ERROR in file gds_ds12_lock_pthread.c"
export PMIX_MCA_gds="^ds12"
# The btl_vader_single_copy_mechanism can't be used with containers.
export OMPI_MCA_btl_vader_single_copy_mechanism="none"

APPTAINER_OPTS="\
  --bind="${SLURM_TMPDIR}:/tmp,${CACHE_DIR}:/fd/.cache" \
  --home $PWD "

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
```
