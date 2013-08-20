# ------------------
#     wxPython 2.9
# ------------------
# $Id: wxmac28.sh 1902 2007-02-04 22:27:47Z ippei $
# Copyright (c) 2007-2008, Ippei Ukai

# prepare
source ../scripts/functions.sh
check_SetEnv

fail()
{
    echo "** Failed at $1 **"
    exit 1
}


mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# for 10.6 compatibility, wx needs to be built against 10.6 sdk
SDK_BASE_PATH=$(xcode-select -print-path)/Platforms/MacOSX.platform
MACSDKDIR106="$SDK_BASE_PATH/Developer/SDKs/MacOSX10.6.sdk"

# compile
TARGET=$x64TARGET
MACSDKDIR=$MACSDKDIR106 #x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX

PYTHON=$REPOSITORYDIR/Frameworks/Python27.framework/Versions/Current/bin/python

# wxPython checks for isysroot in $CC and $CXX, not $CFLAGS or $CXXFLAGS
env \
    CC="$CC -isysroot $MACSDKDIR" \
    CXX="$CXX -isysroot $MACSDKDIR" \
    CFLAGS="-Wall $OTHERARGs -O2 -dead_strip" \
    CXXFLAGS="-Wall $OTHERARGs -O2 -dead_strip" \
    CPPFLAGS="-Wall -isysroot $MACSDKDIR $OTHERARGs -O2 -dead_strip -I$REPOSITORYDIR/include" \
    OBJCFLAGS="$CFLAGS -arch $ARCH" \
    OBJCXXFLAGS="$CXXFLAGS -arch $ARCH" \
    LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
    WXWIN=$HOME/Sources/Hugin/External/Build/wxWidgets.git \
    $PYTHON setup.py build WX_CONFIG=$REPOSITORYDIR/bin/wx-config WXPORT=osx_cocoa MONOLITHIC=1

env \
    WXWIN=$HOME/Sources/Hugin/External/Build/wxWidgets.git \
    $PYTHON setup.py install WX_CONFIG=$REPOSITORYDIR/bin/wx-config WXPORT=osx_cocoa MONOLITHIC=1
