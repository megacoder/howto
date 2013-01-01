#!/bin/zsh

ME=${0:t}
USAGE="usage: ${ME} [-c custom] [-d] [-j #] [-m] [-n name] [-v] [options]"

distcc=
VERBOSE=""
want_make=
jobs=12
NAME=${PWD:t}

distrib=yes
while getopts dj:mn:v c; do
	case "${c}" in
	d )	distrib="yes";;
	j )	jobs="${OPTARG}";;
	m )	want_make=yes;;
	n )	NAME="${OPTARG}";;
	v )	VERBOSE="yes";;
	* )	echo "${USAGE}" >&2; exit 1;;
	esac
done
shift $((OPTIND - 1))

if [ $# -ge 1 ]; then
	NAME="${1}"
	shift
fi

(
	echo "Running configure with basic arguments"
	if [ "${distrib}" ]; then
		export	CCACHE_PREFIX=distcc
		export	CC="ccache gcc -std=gnu99 -march=native"
		export	CFLAGS='-pipe -Os -D_FORTIFY_SOURCE=2'
		export	CXX="ccache g++ -march=native"
		export	CXXFLAGS='-pipe -Os'
	else
		unset	CCACHE_PREFIX
		export	CC="gcc -std=gnu99 -march=native"
		export	CFLAGS='-pipe -Os -D_FORTIFY_SOURCE=2'
		export	CXX="g++ -march=native"
		export	CXXFLAGS='-pipe -Os'
	fi
	#
	if [ ! -x ./configure ]; then
		if [ "${VERBOSE}" ]; then
			export BOOTSTRAP_VERBOSE=yes
			bootstrap
		else
			unset BOOTSTRAP_VERBOSE
			bootstrap
		fi
	fi
	#
	./configure							\
		--prefix=/opt/${NAME}					\
		$@

	[ "${want_make}" ] && make -j${JOBS}
) 2>&1 | tee "${NAME}-action.log"
