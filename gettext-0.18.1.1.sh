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


let NUMARCH="0"

for i in $ARCHS
do
  NUMARCH=$(($NUMARCH + 1))
done

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

GETTEXTVER_M="0"
GEETTEXTVER_FULL="$GETTEXTVER_M.11"
MAIN_LIB_VER="0"
FULL_LIB_VER="$MAIN_LIB_VER.18.1"
ASPRINTFVER_F="0"
ASPRINTFVER_M="0"
GETTEXTVERPO_M="0"
GETTEXTVERPO_F="0"
LIBINTLVER_F="8"
LIBINTLVER_M="8"

# patch
# lion + xcode 4.3
#patch -Np0 < ../scripts/patches/gettext-0.18.1.1-lion.patch

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
	CC=$i386CC
	CXX=$i386CXX
	ARCHFLAG="-m32"
    elif [ $ARCH = "x86_64" ] ; then
	TARGET=$x64TARGET
	MACSDKDIR=$x64MACSDKDIR
	ARCHARGs="$x64ONLYARG"
	OSVERSION="$x64OSVERSION"
	CC=$x64CC
	CXX=$x64CXX
	ARCHFLAG="-m64"
    fi
    
    #export PATH=/usr/bin:$PATH
    
    env \
	CC=$CC CXX=$CXX \
	CFLAGS="-isysroot $MACSDKDIR $ARCHFLAG -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CXXFLAGS="-isysroot $MACSDKDIR $ARCHFLAG -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CPPFLAGS="-I$REPOSITORYDIR/include -I/usr/include " \
	LDFLAGS="-L$REPOSITORYDIR/lib -L/usr/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
	NEXT_ROOT="$MACSDKDIR" \
	./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
	--host="$TARGET" --exec-prefix=$REPOSITORYDIR/arch/$ARCH \
	--enable-shared --enable-static --disable-csharp --disable-java \
	--with-included-gettext --with-included-glib --disable-openmp \
	--with-included-libxml --without-examples --with-libexpat-prefix=$REPOSITORYDIR \
	--with-included-libcroco  --without-emacs --with-libiconf-prefix=$REPOSITORYDIR || fail "configure step for $ARCH" ;
    
    make clean;
    make || fail "failed at make step of $ARCH";
    make install || fail "make install step of $ARCH";
done

# merge libgettext
merge_libraries "lib/libgettextlib-$FULL_LIB_VER.dylib" "lib/libgettextpo.$GETTEXTVERPO_F.dylib" "lib/libgettextsrc-$FULL_LIB_VER.dylib"
merge_libraries "lib/libasprintf.$ASPRINTFVER_F.dylib" "lib/libasprintf.a" "lib/libintl.$LIBINTLVER_F.dylib" "lib/libintl.a"

if [ -f "$REPOSITORYDIR/lib/libgettextlib-$FULL_LIB_VER.dylib" ] ; then
 install_name_tool -id "$REPOSITORYDIR/lib/libgettextlib-$FULL_LIB_VER.dylib" "$REPOSITORYDIR/lib/libgettextlib-$FULL_LIB_VER.dylib"
 ln -sfn libgettextlib-$FULL_LIB_VER.dylib $REPOSITORYDIR/lib/libgettextlib.dylib;
fi

if [ -f "$REPOSITORYDIR/lib/libgettextsrc-$FULL_LIB_VER.dylib" ] ; then
 install_name_tool -id "$REPOSITORYDIR/lib/libgettextsrc-$FULL_LIB_VER.dylib" "$REPOSITORYDIR/lib/libgettextsrc-$FULL_LIB_VER.dylib"
 ln -sfn libgettextsrc-$FULL_LIB_VER.dylib $REPOSITORYDIR/lib/libgettextsrc.dylib;
fi

if [ -f "$REPOSITORYDIR/lib/libgettextpo.$GETTEXTVERPO_F.dylib" ] ; then
 install_name_tool -id "$REPOSITORYDIR/lib/libgettextpo.$GETTEXTVERPO_F.dylib" "$REPOSITORYDIR/lib/libgettextpo.$GETTEXTVERPO_F.dylib"
 ln -sfn libgettextpo.$GETTEXTVERPO_F.dylib $REPOSITORYDIR/lib/libgettextpo.0.dylib;
 ln -sfn libgettextpo.$GETTEXTVERPO_F.dylib $REPOSITORYDIR/lib/libgettextpo.dylib;
fi

if [ -f "$REPOSITORYDIR/lib/libasprintf.$ASPRINTFVER_F.dylib" ] ; then
 install_name_tool -id "$REPOSITORYDIR/lib/libasprintf.$ASPRINTFVER_F.dylib" "$REPOSITORYDIR/lib/libasprintf.$ASPRINTFVER_F.dylib"
 ln -sfn libasprintf.$ASPRINTFVER_F.dylib $REPOSITORYDIR/lib/libasprintf.0.dylib;
 ln -sfn libasprintf.$ASPRINTFVER_F.dylib $REPOSITORYDIR/lib/libasprintf.dylib;
fi

if [ -f "$REPOSITORYDIR/lib/libintl.$LIBINTLVER_F.dylib" ] ; then
 install_name_tool -id "$REPOSITORYDIR/lib/libintl.$LIBINTLVER_F.dylib" "$REPOSITORYDIR/lib/libintl.$LIBINTLVER_F.dylib"
 ln -sfn libintl.$LIBINTLVER_F.dylib $REPOSITORYDIR/lib/libintl.8.dylib;
 ln -sfn libintl.$LIBINTLVER_F.dylib $REPOSITORYDIR/lib/libintl.dylib;
fi

#Copy shell script
for ARCH in $ARCHS
do
    mkdir -p "$REPOSITORYDIR/bin";
    cp "$REPOSITORYDIR/arch/$ARCH/bin/gettext.sh" "$REPOSITORYDIR/bin/gettext.sh";
    sed 's/^exec_prefix.*$/exec_prefix=\$\{prefix\}/' "$REPOSITORYDIR/arch/$ARCH/bin/gettextize" > "$REPOSITORYDIR/bin/gettextize";
    sed 's/^exec_prefix.*$/exec_prefix=\$\{prefix\}/' "$REPOSITORYDIR/arch/$ARCH/bin/autopoint" > "$REPOSITORYDIR/bin/autopoint";
    break;
done
chmod a+x "$REPOSITORYDIR/bin/gettextize" "$REPOSITORYDIR/bin/autopoint"


# merge execs
merge_execs bin/gettext bin/ngettext bin/xgettext bin/msgattrib 
merge_execs bin/msgcmp bin/msgconv   bin/msgexec bin/msgfmt 
merge_execs bin/msginit bin/msgunfmt bin/msgcat   bin/msgcomm bin/msgen
merge_execs bin/msgfilter bin/msggrep bin/msgmerge 
merge_execs bin/msguniq bin/envsubst bin/recode-sr-latin 

# Last step for gettext libs. They are linked during build against libinitl and therefore have an install_name
# based on the arch/$ARCH directory. We need to change that. Unfortunately we need to do it for every arch even 
# though it is only mentioned once for one of the arc/$ARCHs this due to the order in which the $ARCHS are processed
# lipo merged (This should be deductable as the install_name should be the last in the ARCHS="..." variable, but I 
# don't care.

for ARCH in $ARCHS
do
    for gettextlib in $REPOSITORYDIR/lib/libgettextlib-$FULL_LIB_VER.dylib $REPOSITORYDIR/lib/libgettextpo.$GETTEXTVERPO_F.dylib $REPOSITORYDIR/lib/libgettextsrc-$FULL_LIB_VER.dylib
    do
	for lib in $(otool -L $gettextlib | grep $REPOSITORYDIR/arch/$ARCH/lib | sed -e 's/ (.*$//' -e 's/^.*\///')
	do
	    echo " Changing install name for: $lib inside : $gettextlib"
	    install_name_tool -change "$REPOSITORYDIR/arch/$ARCH/lib/$lib" "$REPOSITORYDIR/lib/$lib" $gettextlib
	done
    done
done


