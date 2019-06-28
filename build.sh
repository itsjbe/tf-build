#!/bin/bash

# Author: Sasha Nikiforov

# source of inspiration
# https://stackoverflow.com/questions/41293077/how-to-compile-tensorflow-with-sse4-2-and-avx-instructions

GIT_VERSION="r2.0"
SRC_DIR="src/tensorflow.git"
OUT_DIR="out"

raw_cpu_flags=`sysctl -a | grep machdep.cpu.features | cut -d ":" -f 2 | tr '[:upper:]' '[:lower:]'`
COPT="--copt=-march=native --config=v2"

for cpu_feature in $raw_cpu_flags
do
    case "$cpu_feature" in
        "sse4.1" | "sse4.2" | "ssse3" | "fma" | "cx16" | "popcnt" | "maes")
            COPT+=" --copt=-m$cpu_feature"
        ;;
        "avx1.0")
            COPT+=" --copt=-mavx"
        ;;
        *)
            # noop
        ;;
    esac
done

mkdir $OUT_DIR
chmod 777 $OUT_DIR

mkdir $SRC_DIR
chmod 777 $SRC_DIR

git clone https://github.com/tensorflow/tensorflow.git $SRC_DIR

bazel clean
$SRC_DIR/configure
bazel build -c opt $COPT -k //tensorflow/tools/pip_package:build_pip_package
bazel-bin/tensorflow/tools/pip_package/build_pip_package $OUT_DIR/tensorflow_pkg

#pip3 install --upgrade ~tmp/tensorflow_pkg/`ls ~/tmp/tensorflow_pkg/ | grep tensorflow`
