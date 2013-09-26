# ------------------
#      swig
# ------------------
# $Id:  $
# Copyright (c) 2007, 2011, Ippei Ukai, Matthieu DESILE

# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20111310.0 initial 2.0.4, based on pcre-8.13
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

# remove 64-bit archs from ARCHS
#remove_64bits_from_ARCH

for ARCH in $ARCHS
do
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/bin";
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/lib";
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/include";
    
    ARCHARGs=""
    MACSDKDIR=""
    
    compile_setenv

    env \
	CC=$CC CXX=$CXX \
	CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CPPFLAGS="-I$REPOSITORYDIR/include" \
	LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
	NEXT_ROOT="$MACSDKDIR" \
	./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
	--disable-ccache --with-boost=$myREPOSITORYDIR/ --without-pcre \
	--with-python --without-java --without-ruby --without-tcl --without-php --without-perl5 \
	--host="$TARGET" --exec-prefix=$REPOSITORYDIR/arch/$ARCH || fail "configure step for $ARCH";
    
    make clean;
    make || fail "failed at make step of $ARCH";
    make install || fail "make install step of $ARCH";
done

# merge execs
merge_execs bin/swig

notify swig