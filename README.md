# Open MPI Hybrid Container

This is an Apptainer container with Open MPI based on
https://apptainer.org/docs/user/1.2/mpi.html

The container itself should be started with `mpirun` or `srun`
so that multiple copies of the container can run on several
different nodes on an HPC cluster

## Building Open MPI container from scratch (bootstrapped)

```bash
sudo apptainer build --fix-perms openmpi-hybrid.sif openmpi-hybrid.def
```


## Slurm Jobscript to run the test-cases inside

```
#!/bin/bash
#SBATCH --time=0-00:15:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=40
#SBATCH --mem-per-cpu=1000M

module load apptainer
CONTAINER="openmpi-hybrid.sif"
SCRIPT=""

CACHE_DIR="${SLURM_TMPDIR}/.cache"
mkdir $CACHE_DIR

OVERLAY="${SLURM_TMPDIR}/overlay"
mkdir $OVERLAY

echo "running test /opt/mpitest"
time srun --mpi=pmi2 apptainer  exec \
     --bind="/localscratch:/localscratch" \
     --bind="${CACHE_DIR}:/fd/.cache" \
     --overlay="${OVERLAY}" \
     --home $PWD  \
     "${CONTAINER}"  /opt/mpitest

echo "========================================="
echo "running test /opt/mpitest_sendrecv"
time srun --mpi=pmi2 apptainer  exec \
     --bind="/localscratch:/localscratch" \
     --bind="${CACHE_DIR}:/fd/.cache" \
     --overlay="${OVERLAY}" \
     --home $PWD  \
     "${CONTAINER}"  /opt/mpitest_sendrecv

```
