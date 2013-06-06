# ------------------
#     libexiv2
# ------------------
# $Id: $
# Copyright (c) 2008, Ippei Ukai


# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20120709.0 mde initial script for version 1.7.1
# -------------------------------

# init

fail()
{
    echo "** Failed at $1 **"
    exit 1
}

check_numarchs

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# compile
ARCH=$ARCHS
    
ARCHARGs=""
MACSDKDIR=""

TARGET=$x64TARGET
MACSDKDIR=$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX

mkdir -p build-$ARCH
cd build-$ARCH
rm -f CMakeCache.txt

env \
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CPPFLAGS="-I$REPOSITORYDIR/include" \
    LDFLAGS="-L$REPOSITORYDIR/lib -arch $ARCH -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
    NEXT_ROOT="$MACSDKDIR" \
    cmake -DCMAKE_INSTALL_PREFIX:PATH="$REPOSITORYDIR" \
    -DLATEX_OUTPUT_PATH:PATH="$REPOSITORYDIR/share/doc" \
    -DCMAKE_BUILD_TYPE:STRING='Release' \
    -DBUILD_C_BINDINGS:BOOL="OFF" \
    -DBUILD_PYTHON_BINDINGS:BOOL="OFF" \
    -DBUILD-MATLAB_BINDINGS:BOOL="OFF" \
    -DBUILD_CUDA_LIB:BOOL="OFF" \
    -DUSE_MPI:BOOL="OFF" .. || fail "configure step for $ARCH";

make clean;
make || fail "build step for $ARCH"
make install || fail "make install step of $ARCH";

install_name_tool -id $REPOSITORYDIR/lib/libflann_cpp.1.8.dylib $REPOSITORYDIR/lib/libflann_cpp.1.8.dylib

make distclean