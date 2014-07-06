# ------------------
#     wxPython 2.9
# ------------------
# $Id: wxmac28.sh 1902 2007-02-04 22:27:47Z ippei $
# Copyright (c) 2007-2008, Ippei Ukai

# prepare
if [ -f ../../scripts/functions.sh ]; then
    source ../../scripts/functions.sh
else
    source ../scripts/functions.sh
fi
check_SetEnv

fail()
{
    echo "** Failed at $1 **"
    exit 1
}


mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# For 10.6 compatibility, wx needs to be built against 10.6 sdk

# compile
TARGET=$x64TARGET
MACSDKDIR=$MACSDKDIR106
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX

if [ -d $REPOSITORYDIR/Frameworks/Python27.framework ]; then
    PYTHON=$REPOSITORYDIR/Frameworks/Python27.framework/Versions/Current/bin/python
else 
    PYTHON=$REPOSITORYDIR/Frameworks/Python3.framework/Versions/Current/bin/python3.3
fi

WXWIN=$HOME/Sources/Hugin/External/Build/wxWidgets-3.0.0

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
    WXWIN=$WXWIN \
    $PYTHON setup.py build WX_CONFIG=$REPOSITORYDIR/bin/wx-config WXPORT=osx_cocoa MONOLITHIC=1 \
	|| fail "building wxPython"

env \
    WXWIN=$WXWIN \
    $PYTHON setup.py install WX_CONFIG=$REPOSITORYDIR/bin/wx-config WXPORT=osx_cocoa MONOLITHIC=1
