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

echo "${ME}: resid = $@"

set -v
[[ -z "${RUNDIR}" ]] || cd "${RUNDIR}"

if [[ /bin/pump ]]; then
	eval $(/bin/pump --startup)
	ZSHEXIT()	{
		/bin/pump --shutdown
	}
fi
echo "Running configure with basic arguments"
CFLAGS+=" -std=gnu99 -march=native -pipe -Os -D_FORTIFY_SOURCE=2"
export CFLAGS
CXXFLAGS+=" -march=native -pipe -Os"
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
echo "${ME}: running ./configure script."
echo "$ ./configure --prefix=/opt/${NAME} $@"
./configure --prefix=/opt/${NAME} "$@"
#
# Build the item if asked
#
if [[ ! -z "${want_make}" ]]; then
	echo "${ME}: running make(1), as requested."
	make ${JOBS}
fi
