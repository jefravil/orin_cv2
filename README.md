# orin_cv2
Este script automatiza la instalación de OpenCV optimizado para GPUs NVIDIA Jetson, habilitando aceleración por hardware y compatibilidad con procesamiento de video en tiempo real.

# README para Compilación de OpenCV en Jetson con JetPack 6.2.1

Este script compila **OpenCV 4.11.0** con soporte para **CUDA 12.6**, **cuDNN 9.3** y **GStreamer** en dispositivos **NVIDIA Jetson** usando **JetPack 6.2.1** (L4T 36.4.4).

## Requisitos

1. **Jetson con JetPack 6.2.x** (Ubuntu 22.04).

## Instrucciones de Uso

1. **Actualiza el sistema**:
    ```bash
   sudo apt update && sudo apt upgrade -y

2. **Ejecuta el script**:
    ```bash
    ./build_opencv_jetpack621.sh

3. **Verifica la versión de OpenCV**:
    ```bash
    python3 -c "import cv2; print(cv2.__version__)"
    
4. **Verifica el soporte de CUDA:**:
    ```bash
    python3 -c "import cv2; print(cv2.cuda.getCudaEnabledDeviceCount())"
