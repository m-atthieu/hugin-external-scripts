mkdir -p build
cd build
env CC=$x64CC CXX=$x64CXX \
    ../configure --prefix=$REPOSITORYDIR/local-gcc \
    --with-local-prefix=$REPOSITORYDIR/local-gcc \
    --with-mpfr=$REPOSITORYDIR/local-gcc \
    --with-gmp=$REPOSITORYDIR/local-gcc \
    --with-mpc=$REPOSITORYDIR/local-gcc \
    --program-suffix=-4.8 \
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
