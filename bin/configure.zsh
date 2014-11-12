#!/bin/zsh

ME=${0:t}
USAGE="usage: ${ME} [-c custom] [-d] [-j #] [-m] [-n name] [-v] [options]"

distcc="yes"
VERBOSE=""
want_make=
jobs=$(rpm -E '%_smp_mflags')
NAME=${PWD:t:r}

distrib=yes
while getopts dj:mn:v c; do
	case "${c}" in
	d )	distrib=;;
	j )	jobs="-j${OPTARG}";;
	m )	want_make=yes;;
	n )	NAME="${OPTARG}";;
	v )	VERBOSE="yes";;
	* )	echo "${USAGE}" >&2; exit 1;;
	esac
done
shift $((OPTIND - 1))

if [[ $# -ge 1 ]]; then
	NAME="${1}"
	shift
fi

(
	echo "Running configure with basic arguments"
	if [[ ! -z "${distrib}" ]]; then
		export	CCACHE_PREFIX=distcc
		export	CC="ccache gcc -std=gnu99 -march=native"
		export	CFLAGS="${CFLAGS} -pipe -Os -D_FORTIFY_SOURCE=2"
		export	CXX="ccache g++ -march=native"
		export	CXXFLAGS="${CXXFLAGS} -pipe -Os"
	else
		unset	CCACHE_PREFIX
		export	CC="gcc -std=gnu99 -march=native"
		export	CFLAGS="${CFLAGS} -pipe -Os -D_FORTIFY_SOURCE=2"
		export	CXX="g++ -march=native"
		export	CXXFLAGS="${CXXFLAGS} -pipe -Os"
	fi
	#
	if [[ ! -x ./configure ]]; then
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

	[[ ! -z "${want_make}" ]] && make ${JOBS}
) 2>&1 | tee "${NAME}-action.log"
