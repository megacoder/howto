#!/bin/zsh

ME=${0:t}
USAGE="usage: ${ME} [-d] [-f] [-j #] [-m] [-n name] [-v] [options]"

VERBOSE=""
want_make=
JOBS=$(rpm -E '%_smp_mflags')
NAME=${PWD:t:r}

distrib=yes
force=no
while [[ $# -gt 0 ]] && [[ "${1}" =~ '^-.*$' ]]; do
	case "${1}" in
	-d )	distrib=			;;
	-f )	force='yes'			;;
	-j )	JOBS="-j${2}"; shift		;;
	-m )	want_make='yes'			;;
	-n )	NAME="${2}"; shift		;;
	-v )	VERBOSE='yes'			;;
	-- )	shift; break			;;
	*  )	echo "${USAGE}" >&2; exit 1	;;
	esac
	shift
done

if [[ -z "${NAME}" ]] && [[  $# -ge 1 ]]; then
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
	export	CC=gcc
	export	CXX=g++
	#
	if [[ "${force}" = "yes" ]]; then
		rm -f configure
	fi
	#
	if [[ ! -x ./configure ]]; then
		bootstrap
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
		make ${JOBS}
	fi
) 2>&1 | tee "${NAME}-action.log"
