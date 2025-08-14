#!/bin/bash
set -e
IMAGE=$(grep LLM_SBSA_DOCKER_IMAGE ~/scratch/tekit/jenkins/current_image_tags.properties | head -1 | awk -F "=" '{print $2}' ) #| cut -c 2- | rev | cut -c 2- | rev)
echo $IMAGE

ORIG_CONT=$(echo $IMAGE | sed 's|urm.nvidia.com/|urm.nvidia.com#|g')
TAG=$(echo ${ORIG_CONT} | awk -F ":" '{print $2}')


# !!!! Please change the highlighted color to your own directory
SQSH_CONT="/lustre/fsw/portfolios/coreai/users/zhenhuanc/sqsh/trtllm-${TAG}.sqsh"
SAVE_CONT_OPTIONS=""

if [ ! -e ${SQSH_CONT} ]; then
   CONT=${ORIG_CONT}
   SAVE_CONT_OPTIONS="--container-save=${SQSH_CONT}"
   echo "Fetching container and saving to ${SQSH_CONT}"
else
   CONT=${SQSH_CONT}
fi

# MOUNTS="/lustre/fsw/portfolios/coreai/:/lustre/fsw/portfolios/coreai/,\
# /lustre/fs1/portfolios/coreai/:/lustre/fs1/portfolios/coreai/,\
# /lustre/fs1/portfolios/coreai/projects/coreai_comparch_trtllm/:/lustre/fs1/portfolios/coreai/projects/coreai_comparch_trtllm/,\
# /home/zhenhuanc:/home/zhenhuanc"
MOUNTS="/lustre/fs1:/lustre/fs1,/home/zhenhuanc:/home/zhenhuanc"

WORKDIR=$(realpath `pwd`)
# salloc -A coreai_comparch_trtllm -J trtllm.zhenhuanc -t 04:00:00 \
#         -N 4 \
#         --ntasks-per-node=4 \
#         -p batch \
#         --gres=gpu:4 \
#         --container=${CONT} --container-mounts=${MOUNTS} --container-workdir=${WORKDIR} ${SAVE_CONT_OPTIONS}
srun -l --container-image=${CONT} \
        --container-mounts=${MOUNTS} \
        --container-workdir=${WORKDIR} ${SAVE_CONT_OPTIONS} \
        --container-writable \
        --container-name=wideep_zhenhuanc \
        --mpi=pmix \
        $@
