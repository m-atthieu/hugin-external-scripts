# ------------------
#      python2.7
# ------------------
# $Id:  $
# Copyright (c) 2007, Ippei Ukai

# prepare
source ../scripts/functions.sh
check_SetEnv

# export REPOSITORYDIR="/PATH2HUGIN/mac/ExternalPrograms/repository" \
# ARCHS="ppc i386" \
#  ppcTARGET="powerpc-apple-darwin8" \
#  i386TARGET="i386-apple-darwin8" \
#  ppcMACSDKDIR="/Developer/SDKs/MacOSX10.4u.sdk" \
#  i386MACSDKDIR="/Developer/SDKs/MacOSX10.4u.sdk" \
#  ppcONLYARG="-mcpu=G3 -mtune=G4" \
#  i386ONLYARG="-mfpmath=sse -msse2 -mtune=pentium-m -ftree-vectorize" \
#  ppc64ONLYARG="-mcpu=G5 -mtune=G5 -ftree-vectorize" \
#  OTHERARGs="";

# -------------------------------
# 20120418.0 hvdw build python as part of Hugin
# -------------------------------

# init

fail()
{
        echo "** Failed at $1 **"
        exit 1
}


let NUMARCH="0"

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# compile
# For python we have a completely different approach
mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

ARCHARGs=""
MACSDKDIR=""

#Use the settings of the x86_64 build
# for 10.6 compatibility, libpano needs to be built against 10.6 sdk
#SDK_BASE_PATH=$(xcode-select -print-path)/Platforms/MacOSX.platform
#MACSDKDIR106="$SDK_BASE_PATH/Developer/SDKs/MacOSX10.6.sdk"

TARGET=$x64TARGET
MACSDKDIR=$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX

mkdir -p build-fw
cd build-fw
# --with-universal-archs="intel" --enable-universalsdk=$MACSDKDIR 
# Specifying both --enable-shared and --enable-framework is not supported
env \
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR  -arch x86_64 $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CXXFLAGS="-isysroot $MACSDKDIR -arch x86_64 $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CPPFLAGS="-I$REPOSITORYDIR/include" \
    LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
    NEXT_ROOT="$MACSDKDIR" \
    ../configure --enable-framework=$REPOSITORYDIR/Frameworks --with-framework-name=Python27 \
        --prefix=$REPOSITORYDIR \
        --with-libs='-lz' \
        --enable-toolbox-glue --enable-ipv6 --enable-unicode \
        --with-cxx-main=$CXX \
    || fail "configure step for python 2.7 multi arch";

make clean;
make || fail "failed at make step of python 2.7 multi arch";
make install || fail "make install step of python 2.7 multi arch";

#chmod u+w $REPOSITORYDIR/lib/libpython2.7.dylib
rm -rf $REPOSITORYDIR/Frameworks/Python27.framework/Versions/2.7/lib/python2.7/test

# clean
rm -rf build-fw