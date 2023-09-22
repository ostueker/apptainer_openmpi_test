# Open MPI Hybrid Container

This is an Apptainer container with Open MPI based on
https://apptainer.org/docs/user/1.2/mpi.html

The container itself should be started with `mpirun` or `srun`
so that multiple copies of the container can run on several
different nodes on an HPC cluster

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

module load apptainer
#CONTAINER="openmpi-hybrid.sif"
CONTAINER="openmpi-hybrid-slurm.sif"

# create $CACHE_DIR on all participating nodes
CACHE_DIR="${SLURM_TMPDIR}/.cache"
srun --ntasks-per-node=1 mkdir -p $CACHE_DIR

MPIRUN="srun --mpi=pmi2"

APPTAINER_OPTS="\
  --bind="${SLURM_TMPDIR}:/tmp,${CACHE_DIR}:/fd/.cache" \
  --home $PWD \
"

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
```
