# orin_cv2
This script automates the installation of OpenCV optimized for NVIDIA Jetson GPUs, enabling hardware acceleration and real-time video processing support.

# README for Building OpenCV on Jetson with JetPack 6.2.x

This script builds **OpenCV 4.11.0** with support for **CUDA 12.6**, **cuDNN 9.3**, and **GStreamer** on **NVIDIA Jetson** devices using **JetPack 6.2.1** (L4T 36.4.4) (modifiable).

## Requirements

1. **Jetson with JetPack 6.2.x** (Ubuntu 22.04).

## Usage Instructions

1. **Verify or modify the script**:
    ```bash
    gedit build_opencv.sh
    ```

2. **Run the script**:
    ```bash
    chmod 755 build_opencv.sh
    ./build_opencv.sh
    ```
3. **Run cmake manually in the build directory**:
    ```bash
    cd /tmp/build_opencv/opencv/build
    cmake ..
    ```
4. **Verify the OpenCV version**:
    ```bash
    python3 -c "import cv2; print(cv2.__version__)"
    ```

5. **Verify CUDA support**:
    ```bash
    python3 -c "import cv2; print(cv2.cuda.getCudaEnabledDeviceCount())"
    ```
## Key Parameters for Modification
readonly DEFAULT_VERSION

install_dependencies

CUDA_ARCH_BIN=5.3,6.2,7.2,8.7

CUDNN_VERSION='x.0'

