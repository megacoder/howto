#!/bin/zsh

ME=${0:t}
USAGE="usage: ${ME} [-c custom] [-d] [-j #] [-m] [-n name] [-v] [options]"

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
	if [[ /bin/pump ]]; then
		eval $(/bin/pump --startup)
		ZSHEXIT()	{
			/bin/pump --shutdown
		}
	fi
	echo "Running configure with basic arguments"
	export CFLAGS
	CFLAGS+=" -std=gnu99 -march=native -pipe -Os -D_FORTIFY_SOURCE=2"
	export CXXFLAGS
	CXXFLAGS+=" -march=native -pipe -Os"
	unset	CCACHE_PREFIX
	export	CC=/bin/gcc
	export	CXX=/bin/g++
	#
	# If no local "configure" script exists, make a default one
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
	# Make a default configuration, for now.
	#
	./configure							\
		--prefix=/opt/${NAME}					\
		"$@"
	#
	# Build the item if asked
	#
	if [[ ! -z "${want_make}" ]]; then
		make -j${JOBS}
	fi
) 2>&1 | tee "${NAME}-action.log"
