# ------------------
#      ZThread
# ------------------
# $Id:  $
# Copyright (c) 2007, 2011, Ippei Ukai, Matthieu DESILE

# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20111017.0 initial 2.3.2
# -------------------------------

# init

fail()
{
    echo "** Failed at $1 **"
    exit 1
}

LIBNAME="ZThread"
LIBVER_M="2"
LIBVER_FULL="$LIBVER_M.3.2.0.0"

let NUMARCH="0"

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

for i in $ARCHS
do
    NUMARCH=$(($NUMARCH + 1))
done

#
# patch
#
patch -Np1 < ../scripts/patches/zthread-2.3.2-gcc4.4.diff
patch -Np1 < ../scripts/patches/zthread-2.3.2-executor.diff
patch -Np1 < ../scripts/patches/zthread-2.3.2-exec_prefix.diff

#
# compile
#
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
    elif [ $ARCH = "ppc" -o $ARCH = "ppc750" -o $ARCH = "ppc7400" ] ; then
	TARGET=$ppcTARGET
	MACSDKDIR=$ppcMACSDKDIR
	ARCHARGs="$ppcONLYARG"
	OSVERSION="$ppcOSVERSION"
	CC=$ppcCC
	CXX=$ppcCXX
    elif [ $ARCH = "ppc64" -o $ARCH = "ppc970" ] ; then
	TARGET=$ppc64TARGET
	MACSDKDIR=$ppc64MACSDKDIR
	ARCHARGs="$ppc64ONLYARG"
	OSVERSION="$ppc64OSVERSION"
	CC=$ppc64CC
	CXX=$ppc64CXX
    elif [ $ARCH = "x86_64" ] ; then
	TARGET=$x64TARGET
	MACSDKDIR=$x64MACSDKDIR
	ARCHARGs="$x64ONLYARG"
	OSVERSION="$x64OSVERSION"
	CC=$x64CC
	CXX=$x64CXX
    fi
    
    env \
	CC=$CC CXX=$CXX \
	CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip -fpermissive" \
	CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip -fpermissive" \
	CPPFLAGS="-I$REPOSITORYDIR/include" \
	LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
	NEXT_ROOT="$MACSDKDIR" \
	ARCH=$ARCH \
	./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
	--host="$TARGET" --exec-prefix="$REPOSITORYDIR/arch/$ARCH" || fail "configure step for $ARCH";
    
    make clean;
    make || fail "failed at make step of $ARCH";
    if [ "$ARCH" = 'i386' -o "$ARCH" = 'x86_64' ] ; then
	echo 'self compiling'
	cd src
	env \
            CC=$CC CXX=$CXX \
            CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip -fpermissive" \
            CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip -fpermissive" \
            CPPFLAGS="-I$REPOSITORYDIR/include" \
            LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
            NEXT_ROOT="$MACSDKDIR" \
	    $CXX -dynamiclib -single_module -Wl,-flat_namespace -Wl,-undefined -Wl,suppress \
	    -o .libs/lib$LIBNAME-$LIBVER_FULL.dylib  .libs/AtomicCount.o .libs/Condition.o .libs/ConcurrentExecutor.o \
	    .libs/CountingSemaphore.o .libs/FastMutex.o .libs/FastRecursiveMutex.o .libs/Mutex.o \
	    .libs/RecursiveMutexImpl.o .libs/RecursiveMutex.o .libs/Monitor.o .libs/PoolExecutor.o \
	    .libs/PriorityCondition.o .libs/PriorityInheritanceMutex.o .libs/PriorityMutex.o \
	    .libs/PrioritySemaphore.o .libs/Semaphore.o .libs/SynchronousExecutor.o .libs/Thread.o \
	    .libs/ThreadedExecutor.o .libs/ThreadImpl.o .libs/ThreadLocalImpl.o .libs/ThreadQueue.o \
	    .libs/Time.o .libs/ThreadOps.o -L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION \
	    -install_name $REPOSITORYDIR/arch/$ARCH/lib/lib$LIBNAME-2.3.2.dylib \
	    -Wl,-compatibility_version -Wl,3 -Wl,-current_version -Wl,3.0 -arch $ARCH
	cd ..
    fi
    make install || fail "make install step of $ARCH";
done

#
# merge libs
#
for liba in lib/lib$LIBNAME.a lib/lib$LIBNAME-$LIBVER_FULL.dylib
do
    if [ $NUMARCH -eq 1 ] ; then
	if [ -f $REPOSITORYDIR/arch/$ARCHS/$liba ] ; then
	    echo "Moving arch/$ARCHS/$liba to $liba"
  	    mv "$REPOSITORYDIR/arch/$ARCHS/$liba" "$REPOSITORYDIR/$liba";
	    # Power programming: if filename ends in "a" then ...
	    [ ${liba##*.} = a ] && ranlib "$REPOSITORYDIR/$liba";
  	    continue
	else
	    echo "Program arch/$ARCHS/$liba not found. Aborting build";
	    exit 1;
	fi
    fi
    
    LIPOARGs=""
    for ARCH in $ARCHS
    do
	if [ -f $REPOSITORYDIR/arch/$ARCH/$liba ] ; then
	    echo "Adding arch/$ARCH/$liba to bundle"
	    LIPOARGs="$LIPOARGs $REPOSITORYDIR/arch/$ARCH/$liba"
	else
	    echo "File arch/$ARCH/$liba was not found. Aborting build";
	    exit 1;
	fi
    done
    
    lipo $LIPOARGs -create -output "$REPOSITORYDIR/$liba";
    # Power programming: if filename ends in "a" then ...
    [ ${liba##*.} = a ] && ranlib "$REPOSITORYDIR/$liba";
    
done


if [ -f "$REPOSITORYDIR/lib/lib$LIBNAME-$LIBVER_FULL.dylib" ]
then
    install_name_tool -id "$REPOSITORYDIR/lib/lib$LIBNAME-$LIBVER_FULL.dylib" "$REPOSITORYDIR/lib/lib$LIBNAME-$LIBVER_FULL.dylib"
    ln -sfn lib$LIBNAME-$LIBVER_FULL.dylib $REPOSITORYDIR/lib/lib$LIBNAME-$LIBVER_M.dylib;
    ln -sfn lib$LIBNAME-$LIBVER_FULL.dylib $REPOSITORYDIR/lib/lib$LIBNAME.dylib;
fi

# clean
make distclean 1> /dev/null