#!/bin/zsh
[ "${BOOTSTRAP_VERBOSE}" = "" ] || set -x
ME=${0:t}

VPATH=.
if [ "$1" ]; then
	VPATH="${1}"
fi
if [ ! -d "${VPATH}" ]; then
	echo "${ME}: VPATH (${VPATH}) does not exist." >&2
	exit 1
fi
echo "Cleaning up any prior configuration."
find . -name config.cache -print | xargs rm -f
find . -name autom4te.cache -print | xargs rm -rf
echo "Making sure we have new configure script."
rm -f configure
if [ -x ${VPATH}/bootstrap.sh ]; then
	echo "... ${VPATH}/via bootstrap.sh"
	${VPATH}/bootstrap.sh --help
elif [ -x ${VPATH}/autogen.sh ]; then
	echo "... via ${VPATH}/autogen.sh"
	${VPATH}/autogen.sh --help
elif [ -x ${VPATH}/bootstrap ]; then
	echo "... via ${VPATH}/bootstrap"
	${VPATH}/bootstrap --help
else
	echo "... via autoreconf"
	autoreconf -fvim ${VPATH}
fi
if [ ! -x ./configure ]; then
	echo "Could not find or produce a ./configure file!"
	exit 1
fi
echo "Running configure with default arguments"
export	CC="ccache gcc -std=gnu99 -march=native"
export	CFLAGS='-pipe -Os'
export	CXX="ccache g++"
export	CXXFLAGS='-pipe -Os'
./configure								\
	--enable-silent-rules						\
	$@

