#!/bin/zsh

ME=${0:t:r}

VPATH=.
if [[ ! -z "$1" ]]; then
	VPATH="${1}"
fi
if [[ ! -d "${VPATH}" ]]; then
	echo "${ME}: VPATH (${VPATH}) does not exist." >&2
	exit 1
fi
export VPATH

if [[ -f configure.ac ]] || [[ -f configure.in ]]; then
	echo "${ME}: Running aclocal..."
	aclocal  -I m4 --install
	echo "${ME}: Running autoconf..."
	autoconf -I m4 --force
fi

if [[ -f Makefile.am ]]; then
	echo "${ME}: Running automake..."
	automake --add-missing --copy --force-missing
fi

if [[ ! -x configure ]]; then
	echo "${ME}: did not produce a ./configure script." >&2
	exit 1
fi
exit 0
