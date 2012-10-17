# ------------------
# enblend-openmp 4.0   
# ------------------
# $Id: enblend3.sh 1908 2007-02-05 14:59:45Z ippei $
# Copyright (c) 2007, Ippei Ukai

# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
# 20091209.0 sg Script enhanced to build Enblemd-Enfuse 4.0
# 20091210.0 hvdw Removed code that downgraded optimization from -O3 to -O2
# 20091223.0 sg Added argument to configure to locate missing TTF
#               Building enblend documentation requires tex. Check if possible.
# 20100402.0 hvdw Adapt to build openmp enabled versions. Needs the Setenv-leopard-openmp.txt file
# -------------------------------

# init
fail()
{
    echo "** Failed at $1 **"
    exit 1
}

# Fancy doc builds on Enblend 3.2 are doomed to failure, so don't even try...
AC_INIT=$(grep AC_INIT Configure.in)
TEX=$(which tex)

# If NOT 3.2 and if tex is installed, and if FreeSans.ttf is in the right place...
if [ -z "$(echo $AC_INIT|grep 3.2,)" ] && \
    [ -n "$TEX" ]  && [ -f "/Users/$LOGNAME/Library/Fonts/FreeSans.ttf" ]; then 
    buildDOC="yes"
    extraConfig="--with-ttf-path=/Users/$LOGNAME/Library/Fonts --enable-split-doc=no"
    extraBuild="ps pdf xhtml"
    extraInstall="install-ps install-pdf install-xhtml"
else
    buildDOC="no"
    extraConfig=""
    extraBuild=""
    extraInstall=""
fi 

let NUMARCH="0"

for i in $ARCHS
do
    NUMARCH=$(($NUMARCH + 1))
done

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# compile

for ARCH in $ARCHS
do
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/bin";
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/lib";
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/include";
    
    ARCHARGs=""
    MACSDKDIR=""
    
    if [ $ARCH = "i386" -o $ARCH = "i686" ] ; then
	TARGET=$i386TARGET
	MACSDKDIR=$i386MACSDKDIR
	ARCHARGs="$i386ONLYARG"
	OSVERSION="$i386OSVERSION"
	CC=gcc-4.7 # i386CC
	CXX=g++-4.7 # i386CXX
	CPP=cpp-4.7
	CXXCPP=cpp-4.7
	MARCH=-m32
    elif [ $ARCH = "x86_64" ] ; then
	TARGET=$x64TARGET
	MACSDKDIR=$x64MACSDKDIR
	ARCHARGs="$x64ONLYARG"
	OSVERSION="$x64OSVERSION"
	CC=gcc-4.7 # $x64CC
	CXX=g++-4.7 # $x64CXX
	CPP=cpp-4.7
	CXXCPP=cpp-4.7
	MARCH=-m64
    fi
    
    # To build documentation, you will need to install the following (port) packages:
    #   freefont-ttf
    #   gnuplot
    #   ghostscript
    #   texi2html
    #   transfig
    #   tidy
    #  *teTeX
    # This script presumes you have installed the fonts in ~/Library/Fonts. 
    # See <http://trac.macports.org/ticket/16938> for how to do this.
    # (Port installs the fonts here: /opt/local/share/fonts/freefont-ttf/)
    # The port version of teTeX did not install cleanly for me. Instead, I downloaded a pre-built distro
    # called MacTeX <http://www.tug.org/mactex/2009/>. After installing, you will need to add this
    # directory to your PATH, as shown on the next line: 
    # export PATH=/usr/local/texlive/2009/bin/universal-darwin:$PATH
    # To make the change permanent, edit ~/.profile.

    mkdir -p build-$ARCH
    cd build-$ARCH
    rm -f CMakeCache.txt

    #env \
	#CC=$CC CXX=$CXX CPP=$CPP CXXCPP=$CXXCPP \
       #CFLAGS="-fopenmp -isysroot $MACSDKDIR -I$REPOSITORYDIR/include $MARCH $ARCHARGs $OTHERARGs -dead_strip" \
	#CXXFLAGS="-fopenmp -isysroot $MACSDKDIR -I$REPOSITORYDIR/include $MARCH $ARCHARGs $OTHERARGs -dead_strip" \
	#CPPFLAGS="-fopenmp -I$REPOSITORYDIR/include -I$REPOSITORYDIR/include/OpenEXR -I/usr/include" \
	#LIBS="-lGLEW -framework GLUT -lobjc -framework OpenGL -framework AGL" \
	#LDFLAGS="-L$REPOSITORYDIR/lib -L/usr/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
	#NEXT_ROOT="$MACSDKDIR" \
	#PKG_CONFIG_PATH="$REPOSITORYDIR/lib/pkgconfig" \
	#./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
	#--host="$TARGET" --exec-prefix=$REPOSITORYDIR/arch/$ARCH --with-apple-opengl-framework \
	#--disable-image-cache --enable-openmp=yes \
	#--with-glew $extraConfig --with-openexr || fail "configure step for $ARCH"
    env \
	CC=$CC CXX=$CXX CPP=$CPP CXXCPP=$CXXCPP \
	cmake \
        -DCMAKE_VERBOSE_MAKEFILE:BOOL="ON" \
        -DCMAKE_INSTALL_PREFIX:PATH="$REPOSITORYDIR/arch/$ARCH" \
        -DCMAKE_BUILD_TYPE:STRING="Release" \
        -DCMAKE_C_FLAGS_RELEASE:STRING="-fopenmp $MARCH $ARCHARGs -mmacosx-version-min=$OSVERSION -isysroot $MACSDKDIR -DNDEBUG -O3 $OPTIMIZE" \
        -DCMAKE_CXX_FLAGS_RELEASE:STRING="-fopenmp $MARCH $ARCHARGs -mmacosx-version-min=$OSVERSION -isysroot $MACSDKDIR -DNDEBUG -O3 $OPTIMIZE" \
        -DJPEG_INCLUDE_DIR="$REPOSITORYDIR/include" \
        -DJPEG_LIBRARIES="$REPOSITORYDIR/lib/libjpeg.dylib" \
        -DPNG_INCLUDE_DIR="$REPOSITORYDIR/include" \
        -DPNG_LIBRARIES="$REPOSITORYDIR/lib/libpng.dylib" \
        -DTIFF_INCLUDE_DIR="$REPOSITORYDIR/include" \
        -DTIFF_LIBRARIES="$REPOSITORYDIR/lib/libtiff.dylib" \
        -DZLIB_INCLUDE_DIR="/usr/include" \
        -DZLIB_LIBRARIES="/usr/lib/libz.dylib" \
	-DVIGRA_INCLUDE_DIR="$REPOSITORYDIR/include" \
	-DVIGRA_LIBRARIES="$REPOSITORYDIR/lib/libvigraimpex.dylib" \
	-DENABLE_OPENMP:BOOL="ON" \
	-DENABLE_IMAGECACHE:BOOL="OFF" \
	-DENABLE_GPU:BOOL="OFF" \
        .. || fail "configuring for $ARCH"
    
    make clean || fail "make clean for $ARCH";
    make all $extraBuild || fail "make all for $ARCH"
    make install $extraInstall || fail "make install for $ARCH";
    cd ..
done

# merge execs
for program in bin/enblend bin/enfuse
do
    if [ $NUMARCH -eq 1 ] ; then
	if [ -f $REPOSITORYDIR/arch/$ARCHS/$program ] ; then
	    echo "Moving arch/$ARCHS/$program to $program"
  	    mv "$REPOSITORYDIR/arch/$ARCHS/$program" "$REPOSITORYDIR/$program";
  	    strip -x "$REPOSITORYDIR/$program";
  	    continue
	else
	    echo "Program arch/$ARCHS/$program not found. Aborting build";
	    exit 1;
	fi
    fi
    
    LIPOARGs=""
    
    for ARCH in $ARCHS
    do
 	if [ -f $REPOSITORYDIR/arch/$ARCH/$program ] ; then
	    echo "Adding arch/$ARCH/$program to bundle"
 	    LIPOARGs="$LIPOARGs $REPOSITORYDIR/arch/$ARCH/$program"
	else
	    echo "File arch/$ARCH/$program was not found. Aborting build";
	    exit 1;
	fi
    done
    
    lipo $LIPOARGs -create -output "$REPOSITORYDIR/$program";
    strip -x "$REPOSITORYDIR/$program";
done
