# ------------------
# multiblend 0.31beta   
# ------------------
# $Id: multiblend.sh 1908 2007-02-05 14:59:45Z ippei $
# Copyright (c) 2007, Ippei Ukai
# 2011, Harry van der Wolf

# prepare
source ../scripts/functions.sh
check_SetEnv

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
	ARCHFLAG="-m64"
    
    echo "## Now compiling $ARCH version ##\n"
    set -x
    env \
	PATH="$PATH" \
	CC=$CC CXX=$CXX \
	CFLAGS="-isysroot $MACSDKDIR -I. -I$REPOSITORYDIR/include -O2 $ARCHFLAG $ARCHARGs $OTHERARGs -dead_strip" \
	CXXFLAGS="-isysroot $MACSDKDIR -I. -I$REPOSITORYDIR/include -O2 $ARCHFLAG $ARCHARGs $OTHERARGs -dead_strip" \
	CPPFLAGS="-I. -I$REPOSITORYDIR/include -I/usr/include" \
	LDFLAGS="-ltiff -ljpeg -L$REPOSITORYDIR/lib -L/usr/lib -mmacosx-version-min=$OSVERSION -dead_strip $ARCHFLAG" \
	NEXT_ROOT="$MACSDKDIR" \
	$CXX -L$REPOSITORYDIR/lib/ -O2 -I$REPOSITORYDIR/include/ -I$MACSDKDIR/usr/include -isysroot $MACSDKDIR $ARCHFLAG $ARCHARGs $OTHERARGs \
	-ltiff -ljpeg -lpng multiblend.cpp -o multiblend || fail "compile step for $ARCH";
    
    mv multiblend $REPOSITORYDIR/bin 
    set +x
