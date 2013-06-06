# ------------------
#     libglib2
# ------------------
# $Id: libglib2.sh 1902 2008-01-02 22:27:47Z Harry $
# Copyright (c) 2007, Ippei Ukai
# script skeleton Copyright (c) 2007, Ippei Ukai
# libglib2 specifics 2012, Harry van der Wolf


# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20120411.0 HvdW Script tested
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

    #mkdir -p build-$ARCH
    #cd build-$ARCH
    
 	TARGET=$x64TARGET
	MACSDKDIR=$x64MACSDKDIR
	ARCHARGs="$x64ONLYARG"
	OSVERSION="$x64OSVERSION"
	CC=$x64CC
	CXX=$x64CXX
	ARCHFLAG="-m64"
    
    env \
	CC=$CC CXX=$CXX \
	CFLAGS="-isysroot $MACSDKDIR $ARCHFLAG $ARCHARGs $OTHERARGs -O3 -dead_strip -fstrict-aliasing" \
	CXXFLAGS="-isysroot $MACSDKDIR $ARCHFLAG $ARCHARGs $OTHERARGs -O3 -dead_strip -fstrict-aliasing" \
	CPPFLAGS="-I$REPOSITORYDIR/include" \
	LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -L$MACSDKDIR/usr/lib -dead_strip -lresolv -bind_at_load $ARCHFLAG" \
	NEXT_ROOT="$MACSDKDIR" \
	./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
	--host="$TARGET" \
	ZLIB_CFLAGS="-I$MACSDKDIR/usr/include" ZLIB_LIBS="-L$MACSDKDIR/usr/lib" \
	GETTEXT_CFLAGS="-I$REPOSITORYDIR/include" GETTEXT_LIBS="-L$REPOSITORYDIR/lib" \
	--disable-selinux --disable-fam --disable-xattr \
	--disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf \
	--disable-man --disable-dtrace --disable-systemtap \
	--disable-static --enable-shared || fail "configure step of $ARCH"
    
    make clean
    make || fail "failed at make step of $ARCH"
    make $OTHERMAKEARGs install || fail "make install step of $ARCH"

# clean
echo "## distclean ##"
make distclean 
