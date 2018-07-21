#!/bin/zsh

ME=${0:t}
USAGE="usage: ${ME} [-C dir] [-d] [-f] [-j #] [-m] [-n name] [-v] <pass-thru-args>"

VERBOSE=""
want_make=
JOBS=$(rpm -E '%_smp_mflags')
NAME=${PWD:t:r}

distrib=yes
force=no
RUNDIR=
while [[ $# -gt 0 ]] && [[ "${1}" =~ '^-.*$' ]]; do
	case "${1}" in
	-C  )	RUNDIR="${2}"; shift		;;
	-d  )	distrib=			;;
	-f  )	force='yes'			;;
	-j  )	JOBS="-j${2}"; shift		;;
	-m  )	want_make='yes'			;;
	-n  )	NAME="${2}"; shift		;;
	-v  )	VERBOSE='yes'			;;
	--  )	shift; break			;;
	*   )	break				;;
	esac
	shift
done

[[ -z "${RUNDIR}" ]] || cd "${RUNDIR}"

if [[ -x /bin/pump ]]; then
	eval $(/bin/pump --startup)
	zshexit()	{
		/bin/pump --shutdown
	}
fi
echo "Running configure with basic arguments"
CFLAGS+=" -std=gnu99 -march=native -pipe -O3 -ffast-math -D_FORTIFY_SOURCE=2"
export CFLAGS
CXXFLAGS+=" -march=native -pipe -O3 -ffast-math"
export CXXFLAGS
unset	CCACHE_PREFIX
export	CC=gcc
export	CXX=g++
#
if [[ "${force}" = "yes" ]]; then
	echo "${ME}: removing ./configure to force reconstruction."
	rm -f configure
fi
#
if [[ ! -x ./configure ]]; then
	echo "${ME}: building basic ./configure script."
	bootstrap
fi
#
# Make a default configuration, for now.
#
if [[ "$(arch)" = "x86_64" ]]; then
	LIBDIR=lib64
else
	LIBDIR=lib
fi
echo "${ME}: running ./configure script."
echo "$ ./configure --prefix=/opt/${NAME} --libdir=/opt/${NAME}/${LIBDIR} $@"
./configure --prefix=/opt/${NAME} --libdir=/opt/${NAME}/${LIBDIR} "$@"
#
# Build the item if asked
#
if [[ ! -z "${want_make}" ]]; then
	echo "${ME}: running make(1), as requested."
	make ${JOBS}
fi
