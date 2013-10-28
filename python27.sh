# ------------------
#      python2.7
# ------------------
# $Id:  $
# Copyright (c) 2007, Ippei Ukai

# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20120418.0 hvdw build python as part of Hugin
# -------------------------------

# init

fail()
{
        echo "** Failed at $1 **"
        exit 1
}

# too many times Have I failed beacuase of that
if [ -f $HOME/.pydistutils.cfg ]; then
	line=$(grep -v '^#' $HOME/.pydistutils.cfg | wc -l | print '{$1}')
	if [ ! $line -eq "0" ]; then
		echo "You have defintions in \$HOME/.pydistutils.cfg, it will cause trouble"
		exit 1
	fi
fi

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

# Use the settings of the x86_64 build
# for 10.6 compatibility, libpano needs to be built against 10.6 sdk
SDK_BASE_PATH=$(xcode-select -print-path)/Platforms/MacOSX.platform
MACSDKDIR106="$SDK_BASE_PATH/Developer/SDKs/MacOSX10.6.sdk"

TARGET=$x64TARGET
MACSDKDIR=$MACSDKDIR106 #$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX

mkdir -p build-$ARCH
cd build-$ARCH
# --with-universal-archs="intel" --enable-universalsdk=$MACSDKDIR 
# Specifying both --enable-shared and --enable-framework is not supported
# --prefix=$REPOSITORYDIR
unset PYTHONHOME
unset PYTHONPATH
env \
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR  -arch x86_64 $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CXXFLAGS="-isysroot $MACSDKDIR -arch x86_64 $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CPPFLAGS="-I$REPOSITORYDIR/include -isysroot $MACSDKDIR -I$MACSDKDIR/usr/include" \
    LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -prebind -isysroot $MACSDKDIR -I$MACSDKDIR/usr/include" \
    NEXT_ROOT="$MACSDKDIR" \
    ../configure --enable-framework=$REPOSITORYDIR/Frameworks --with-framework-name=Python27 \
        --with-libs='-lz' \
        --enable-toolbox-glue --enable-ipv6 --enable-unicode \
        --with-cxx-main=$CXX \
    || fail "configure step for python 2.7";

make clean;
make || fail "failed at make step of python 2.7";
make install || fail "make install step of python 2.7";

#chmod u+w $REPOSITORYDIR/lib/libpython2.7.dylib
rm -rf $REPOSITORYDIR/Frameworks/Python27.framework/Versions/2.7/lib/python2.7/test

# clean
rm -rf build-fw

notify python
