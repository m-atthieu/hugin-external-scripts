mkdir -p build
cd build
env CC=$x64CC CXX=$x64CXX \
    ../configure --prefix=$GCCMP_REPOSITORY_DIR \
    --with-local-prefix=$GCCMP_REPOSITORY_DIR \
    --with-mpfr=$GCCMP_REPOSITORY_DIR \
    --with-gmp=$GCCMP_REPOSITORY_DIR \
    --with-mpc=$GCCMP_REPOSITORY_DIR \
    --program-suffix=-4.8.1 \
    --enable-checking=release \
    --enable-languages=c,c++,objc \
    --with-system-zlib \
    --disable-nls \
    --enable-lto \
    --disable-debug \
    --enable-threads \
    --enable-multilib
make
make install
make distclean