#!/bin/zsh

ME=${0:t}
USAGE="usage: ${ME} [-c custom] [-d] [-f] [-j #] [-m] [-n name] [-s std] [-v] [options]"

distcc=
VERBOSE=""
want_make=
jobs=12
NAME=${PWD:t}
FLAGS=wanted
STD=gnu99

distrib=yes
while getopts dfj:mn:s:v c; do
	case "${c}" in
	d )	distrib="yes";;
	f )	FLAGS=;;
	j )	jobs="${OPTARG}";;
	m )	want_make=yes;;
	n )	NAME="${OPTARG}";;
	s )	STD="${OPTARG}";;
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
	CC="gcc"
	CXX="g++"
	if [[ ! -z "${distrib}" ]]; then
		export	CCACHE_PREFIX=distcc
		export	CC="ccache ${CC}"
		export	CXX="ccache ${CXX}"
	else
		unset	CCACHE_PREFIX
	fi
	if [[ -z "${FLAGS}" ]]; then
		echo "Not setting my most reasonable flags." >&2
	else
		export	CC="${CC} -std=${STD}"
		export	CFLAGS='-march=native -pipe -Os -D_FORTIFY_SOURCE=2'
		export	CXXFLAGS='-march=native -pipe -Os'
	fi
	#
	if [ ! -x ./configure ]; then
		if [[ ! -z "${VERBOSE}" ]]; then
			export BOOTSTRAP_VERBOSE=yes
			bootstrap
		else
			unset BOOTSTRAP_VERBOSE
			bootstrap
		fi
	fi
	#
	if [[ ! -f configure ]]; then
		echo "${ME} failed to make a './configure' file!" >&2
		exit 1
	fi
	#
	./configure							\
		--prefix=/opt/${NAME}					\
		$@

	[[ ! -z "${want_make}" ]] && make -j${JOBS}
) 2>&1 | tee "${NAME}-action.log"
