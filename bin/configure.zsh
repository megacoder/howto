#!/bin/zsh

ME=${0:t}
USAGE="usage: ${ME} [-c custom] [-d] [-f] [-j #] [-m] [-n name] [-v] [options]"

PUMP=/bin/pump
VERBOSE=""
want_make=
jobs=$(rpm -E '%_smp_mflags')
NAME=${PWD:t:r}

distrib=yes
force=no
while getopts dfj:mn:pv c; do
	case "${c}" in
	d )	distrib=;;
	f )	force="yes";;
	j )	jobs="-j${OPTARG}";;
	m )	want_make=yes;;
	n )	NAME="${OPTARG}";;
	p )	PUMP=;;
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
	export CFLAGS
	CFLAGS+=" -std=gnu99 -march=native -pipe -Os -D_FORTIFY_SOURCE=2"
	export CXXFLAGS
	CXXFLAGS+=" -march=native -pipe -Os"
	unset	CCACHE_PREFIX
	export	CC=/bin/gcc
	export	CXX=/bin/g++
	#
	if [[ "${force}" = "yes" ]]; then
		rm -f configure
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
	#
	if [[ ! -z "${want_make}" ]]; then
		eval ${PUMP} make -j${JOBS}
	fi
) 2>&1 | tee "${NAME}-action.log"
