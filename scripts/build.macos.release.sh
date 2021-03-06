#!/bin/bash
set -xe

brew reinstall make cmake automake autoconf libtool
brew reinstall libpng yaml-cpp freetype rapidjson pcre libevent zlib bzip2

git clone https://github.com/curl/curl
cd curl
./buildconf > /dev/null
./configure --with-ssl=/usr/local/opt/openssl@1.1 --without-mbedtls --disable-ldap --disable-ldaps --disable-rtsp --without-libidn2 > /dev/null
make -j8 > /dev/null
cd ..

git clone https://github.com/pngwriter/pngwriter
cd pngwriter > /dev/null
cmake . > /dev/null
sudo make install -j8 > /dev/null
cd ..

cp curl/lib/.libs/libcurl.a .
cp /usr/local/lib/libevent.a .
cp /usr/local/opt/zlib/lib/libz.a .
cp /usr/local/opt/openssl@1.1/lib/libssl.a .
cp /usr/local/opt/openssl@1.1/lib/libcrypto.a .
cp /usr/local/lib/libyaml-cpp.a .
cp /usr/local/lib/libpcre.a .
cp /usr/local/lib/libpcrecpp.a .
cp /usr/local/opt/bzip2/lib/libbz2.a .
cp /usr/local/lib/libPNGwriter.a .
cp /usr/local/lib/libpng.a .
cp /usr/local/lib/libfreetype.a .

export CMAKE_CXX_FLAGS="-I/usr/local/include -I/usr/local/opt/openssl@1.1/include -I/usr/local/opt/curl/include"
cmake -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl@1.1 -DMACOS=on .
make -j8
c++ -Xlinker -unexported_symbol -Xlinker "*" -o base/stairspeedtest CMakeFiles/stairspeedtest.dir/src/*.o libpcrecpp.a libpcre.a libevent.a libcurl.a libPNGwriter.a libpng.a libfreetype.a libz.a libssl.a libcrypto.a libyaml-cpp.a libbz2.a -ldl -lpthread -O3

if [ "$TRAVIS_BRANCH" = "$TRAVIS_TAG" ];then
	bash scripts/build.macos.clients.sh

	cd base
	chmod +rx stairspeedtest *.sh
	chmod +r *

	tar czf ../stairspeedtest_reborn_darwin64.tar.gz *
	cd ..
fi

set +xe
