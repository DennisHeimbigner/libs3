rm -fr build
mkdir build
UL=/usr/local
PPATH="$UL"
FLAGS="-DCMAKE_PREFIX_PATH=$PPATH"
FLAGS="$FLAGS -DCMAKE_INSTALL_PREFIX=${UL}"
cd build
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
cmake $FLAGS ..
cmake --build .
#cmake --build . --target test
