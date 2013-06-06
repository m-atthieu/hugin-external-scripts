mkdir -p build
cd build
env CC=$x64CC CXX=$x64CXX \
    ../configure --prefix=$GCCMP_REPOSITORY_DIR \
    --with-gmp=$GCCMP_REPOSITORY_DIR
make install
make distclean
