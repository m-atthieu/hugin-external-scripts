# ------------------
# enblend 4.0   
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
# 20100624.0 hvdw More robust error checking on compilation
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
    
    compile_setenv

    env \
	CC=$CC CXX=$CXX \
	CFLAGS="-isysroot $MACSDKDIR -I$REPOSITORYDIR/include -I$REPOSITORYDIR/include/OpenEXR -I$REPOSITORYDIR/include/boost -arch $ARCH $ARCHARGs $OTHERARGs -dead_strip" \
	CXXFLAGS="-isysroot $MACSDKDIR -I$REPOSITORYDIR/include -I$REPOSITORYDIR/include/OpenEXR -I$REPOSITORYDIR/include/boost -arch $ARCH $ARCHARGs $OTHERARGs -dead_strip" \
	CPPFLAGS="-I$REPOSITORYDIR/include -I$REPOSITORYDIR/include/OpenEXR -I/usr/include" \
	LIBS="-lGLEW -framework GLUT -lobjc -framework OpenGL -framework AGL" \
	LDFLAGS="-L$REPOSITORYDIR/lib -L/usr/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
	NEXT_ROOT="$MACSDKDIR" \
	PKG_CONFIG_PATH="$REPOSITORYDIR/lib/pkgconfig" \
	./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking --enable-image-cache=yes \
	--host="$TARGET" --exec-prefix=$REPOSITORYDIR/arch/$ARCH --with-apple-opengl-framework \
	--with-glew $extraConfig --with-openexr || fail "configure step for $ARCH";
    
    # hack; AC_FUNC_MALLOC sucks!!
    mv ./config.h ./config.h-copy; 
    sed -e 's/HAVE_MALLOC\ 0/HAVE_MALLOC\ 1/' \
	-e 's/rpl_malloc/malloc/' \
	"./config.h-copy" > "./config.h";
    
    
    # Default to standard -O3 optimization as this improves performance
    # and shrinks the binary
    # If you prefer -O2, change -O3 to -O2 in the 3rd line (containing the sed command).
    [ -f src/Makefile.bak ] && rm src/Makefile.bak
    mv src/Makefile src/Makefile.bak
    sed -e "s/-O[0-9]/-O3/g" "src/Makefile.bak" > src/Makefile
    
    make clean;
    make all $extraBuild || fail "failed at make step of $ARCH";
    make install $extraInstall || fail "make install step of $ARCH";
done


# merge execs
merge_execs bin/enblend bin/enfuse