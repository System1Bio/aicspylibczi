#!/bin/bash
set -e -x

# Install a system package required by our library
yum install -y libpng-devel zlib-devel

# Install newer devtools that work on manylinux
#GCCLOC=https://github.com/squeaky-pl/centos-devtools/releases/download/6.3
#GCCAR=gcc-6.3.0-binutils-2.27-x86_64.tar.bz2
#export CC=/opt/devtools-6.3/bin/gcc
#export CXX=/opt/devtools-6.3/bin/g++
GCCLOC=https://github.com/Noctem/pogeo-toolchain/releases/download/v1.5
GCCAR=gcc-7.3-centos5-x86-64.tar.bz2
export CC=/toolchain/bin/gcc
export CXX=/toolchain/bin/g++
curl -o ${GCCAR} -L ${GCCLOC}/${GCCAR}
tar xvjf ${GCCAR}

# Compile wheels
for PYBIN in /opt/python/cp3*/bin; do
    "${PYBIN}/pip" install -r /io/dev-requirements.txt
    "${PYBIN}/pip" wheel /io/ -w wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair "$whl" -w /io/wheelhouse/
done

# Install packages and test
for PYBIN in /opt/python/cp3*/bin/; do
    "${PYBIN}/pip" install pylibczi --no-index -f /io/wheelhouse
    #(cd "$HOME"; "${PYBIN}/nosetests" pymanylinuxdemo)
done