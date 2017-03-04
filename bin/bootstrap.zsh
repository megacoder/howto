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

CONFIG=
for config in configure.ac configure.in; do
	if [[ -f "${config}" ]]; then
		CONFIG="${config}"
		break
	fi
done

if [[ ! -z "${CONFIG}" ]]; then
	if [[ -x /bin/libtoolize ]] && fgrep -q -s LT_INIT "${CONFIG}" ; then
		echo "${ME}: running libtoolize ..."
		/bin/libtoolize -f -i -q
	fi
	echo "${ME}: Running aclocal ..."
	aclocal  -I m4 --install
	echo "${ME}: Running autoconf ..."
	autoconf -I m4 --force
fi

if [[ -f Makefile.am ]]; then
	echo "${ME}: Running automake ..."
	automake --add-missing --copy --force-missing
fi

if [[ ! -x configure ]]; then
	echo "${ME}: did not produce a ./configure script." >&2
	exit 1
fi
exit 0
