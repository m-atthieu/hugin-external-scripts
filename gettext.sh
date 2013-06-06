# ------------------
#    gettext 
# ------------------
# Based on the works of (c) 2007, Ippei Ukai
# Created for Hugin by Harry van der Wolf 2009

# download location ftp.gnu.org/gnu/gettext/

# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
# 20100116.0 HvdW Correct script for libintl install_name in libgettext*.dylib
# 20100624.0 hvdw More robust error checking on compilation
# 20111102.0 mde bump to 0.18.1.1
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


# patch
# if lion + xcode 4.3 + sdk 10.7+
# if lion and sdk 10.6, no
osx_version=$(sw_vers -productVersion|cut -d '.' -f 1,2)
case "$osx_version" in
	10.7 | 10.8)
	#patch -Np0 < ../scripts/patches/gettext-0.18.1.1-lion.patch
	;;
esac

# compile
ARCH=$ARCHS
    
mkdir -p build-$ARCH
cd build-$ARCH

ARCHARGs=""
MACSDKDIR=""
    
TARGET=$x64TARGET
MACSDKDIR=$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX
ARCHFLAG="-m64"
    
env \
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR $ARCHFLAG -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CXXFLAGS="-isysroot $MACSDKDIR $ARCHFLAG -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CPPFLAGS="-I$REPOSITORYDIR/include -I/usr/include " \
    LDFLAGS="-L$REPOSITORYDIR/lib -L/usr/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
    NEXT_ROOT="$MACSDKDIR" \
    ../configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
    --host="$TARGET" \
    --enable-shared --disable-static --disable-csharp --disable-java \
    --with-included-gettext --with-included-glib --disable-openmp \
    --with-included-libxml --without-examples --with-libexpat-prefix=$REPOSITORYDIR \
    --with-included-libcroco  --without-emacs --with-libiconf-prefix=$REPOSITORYDIR || fail "configure step for $ARCH" ;

make clean;
make || fail "failed at make step of $ARCH";
make install || fail "make install step of $ARCH";

# clean
make distclean
