#!/usr/bin/env bash
# Adaptado por Jefferson Ramirez (July 2025) para Jetson con JetPack 6.2.1 (L4T 36.4.4)
# Basado en el script original de Michael de Gans (2019)

set -e

# CONFIGURACIÓN INICIAL
readonly PREFIX=/usr/local                 # Ruta de instalación
readonly DEFAULT_VERSION=4.11.0            # Versión por defecto de OpenCV
readonly CPUS=$(nproc)                    # Núcleos disponibles

# Detección automática de recursos del dispositivo
if [[ $CPUS -gt 5 ]]; then
    JOBS=$CPUS
else
    JOBS=1
fi

cleanup () {
    while true ; do
        echo "¿Desea eliminar los archivos temporales en /tmp/build_opencv?"
        if [[ "$1" != "--test-warning" ]]; then
            echo "(Esto puede evitar que se ejecuten tests posteriores)"
        fi
        read -p "Y/N " yn
        case ${yn} in
            [Yy]* ) rm -rf /tmp/build_opencv ; break;;
            [Nn]* ) exit ;;
            * ) echo "Por favor responda Y o N." ;;
        esac
    done
}

setup () {
    cd /tmp
    if [[ -d "build_opencv" ]]; then
        echo "Ya existe un build en /tmp/build_opencv"
        cleanup
    fi
    mkdir build_opencv
    cd build_opencv
}

git_source () {
    echo "Clonando OpenCV versión '$1'"
    git clone --depth 1 --branch "$1" https://github.com/opencv/opencv.git
    git clone --depth 1 --branch "$1" https://github.com/opencv/opencv_contrib.git
}

install_dependencies () {
    echo "Instalando dependencias del sistema"

    sudo apt-get update
    sudo apt-get purge -y libopencv* python-opencv

    sudo apt-get install -y \
        build-essential \
        cmake \
        git \
        gfortran \
        libatlas-base-dev \
        libavcodec-dev \
        libavformat-dev \
        libswresample-dev \
        libcanberra-gtk3-module \
        libdc1394-dev \
        libeigen3-dev \
        libglew-dev \
        libgstreamer-plugins-base1.0-dev \
        libgstreamer-plugins-good1.0-dev \
        libgstreamer1.0-dev \
        libgtk-3-dev \
        libjpeg-dev \
        libjpeg8-dev \
        libjpeg-turbo8-dev \
        liblapack-dev \
        liblapacke-dev \
        libopenblas-dev \
        libpng-dev \
        libpostproc-dev \
        libswscale-dev \
        libtbb-dev \
        libtbb2 \
        libtesseract-dev \
        libtiff-dev \
        libv4l-dev \
        libxine2-dev \
        libxvidcore-dev \
        libx264-dev \
        pkg-config \
        python3-dev \
        python3-numpy \
        python3-matplotlib \
        qv4l2 \
        v4l-utils \
        zlib1g-dev
}

configure () {
    local CMAKEFLAGS="
        -D BUILD_EXAMPLES=OFF
        -D BUILD_opencv_python2=OFF
        -D BUILD_opencv_python3=ON
        -D CMAKE_BUILD_TYPE=RELEASE
        -D CMAKE_INSTALL_PREFIX=${PREFIX}
        -D CUDA_ARCH_BIN=8.7
        -D CUDA_ARCH_PTX=
        -D CUDA_FAST_MATH=ON
        -D CUDNN_VERSION='9.3'
        -D EIGEN_INCLUDE_PATH=/usr/include/eigen3
        -D ENABLE_NEON=ON
        -D OPENCV_DNN_CUDA=ON
        -D OPENCV_ENABLE_NONFREE=ON
        -D OPENCV_EXTRA_MODULES_PATH=/tmp/build_opencv/opencv_contrib/modules
        -D OPENCV_GENERATE_PKGCONFIG=ON
        -D WITH_CUBLAS=ON
        -D WITH_CUDA=ON
        -D WITH_CUDNN=ON
        -D WITH_GSTREAMER=ON
        -D WITH_LIBV4L=ON
        -D WITH_OPENGL=ON"

    if [[ "$1" != "test" ]]; then
        CMAKEFLAGS="${CMAKEFLAGS}
        -D BUILD_PERF_TESTS=OFF
        -D BUILD_TESTS=OFF"
    fi

    echo "CMake flags: ${CMAKEFLAGS}"

    cd opencv
    mkdir -p build
    cd build
    cmake ${CMAKEFLAGS} .. 2>&1 | tee -a configure.log
}

main () {
    local VER=${DEFAULT_VERSION}
    if [[ "$#" -gt 0 ]]; then
        VER="$1"
    fi

    if [[ "$#" -gt 1 ]] && [[ "$2" == "test" ]]; then
        DO_TEST=1
    fi

    setup
    install_dependencies
    git_source ${VER}

    if [[ ${DO_TEST} ]]; then
        configure test
    else
        configure
    fi

    make -j${JOBS} 2>&1 | tee -a build.log

    if [[ ${DO_TEST} ]]; then
        make test 2>&1 | tee -a test.log
    fi

    if [[ -w ${PREFIX} ]]; then
        make install 2>&1 | tee -a install.log
    else
        sudo make install 2>&1 | tee -a install.log
    fi

    cleanup --test-warning
}

main "$@"

