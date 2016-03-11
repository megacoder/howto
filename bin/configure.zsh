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
	CFLAGS+=" -std=gnu99 -march=native -pipe -Os -D_FORTIFY_SOURCE=2"
	CXXFLAGS+=" -march=native -pipe -Os"
	export CFLAGS
	export CXXFLAGS
	if [[ -z "${distrib}" ]]; then
		unset	CCACHE_PREFIX
		CC="gcc -std=gnu99 -march=native"
		CXX="g++"
	else
		export	CCACHE_PREFIX='pump distcc'
		export	CC="gcc"
		export	CXX="g++"
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
