export CUDA_HOME="/data/cuda/cuda-10.0/cuda"
export CUDNN_HOME="/data/cuda/cuda-10.0/cudnn/v7.5.0"
export CUDA_BIN_PATH=$CUDA_HOME
export NVIDIA_HOME="/usr/local/nvidia"

export PATH="$CUDA_HOME/bin:$PATH"
export PATH="$CUDA_HOME/include:$PATH"
export PATH="$NVIDIA_HOME/bin:$PATH"

export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$CUDNN_HOME/lib64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$NVIDIA_HOME/lib64:$LD_LIBRARY_PATH"
