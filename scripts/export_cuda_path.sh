export CUDA_HOME="/data/cuda/cuda-10.1-libs/cuda-10.1"
export CUDNN_HOME="/data/cuda/cuda-10.1-libs/cudnn-v7.6.0"
export TENSORRT_HOME="/data/cuda/cuda-10.1-libs/TensorRT-5.1.5.0"
export CUDA_BIN_PATH=$CUDA_HOME
export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME

export PATH="$CUDA_HOME/bin:$PATH"

export CPATH="$CUDA_HOME/include:$CPATH"
export CPATH="$CUDNN_HOME/include:$CPATH"
export CPATH="$TENSORRT_HOME/include:$CPATH"

export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$CUDNN_HOME/lib64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$TENSORRT_HOME/lib:$LD_LIBRARY_PATH"
export LIBRARY_PATH=$LD_LIBRARY_PATH
