#!/bin/zsh
[[ "${BOOTSTRAP_VERBOSE}" = "" ]] || set -x
ME="${0:t}"
VERBOSE=
VPATH=.

while getopts v: c; do
	case "${c}" in
	v )	VERBOSE=yes;;
	* )	echo "Huh?" >&2; exit 1;;
	esac
done
shift $(( ${OPTIND} - 1 ))

if [[ ! -z "$1" ]]; then
	VPATH="${1}"
	shift
fi
if [[ ! -d "${VPATH}" ]]; then
	echo "${ME}: VPATH (${VPATH}) does not exist." >&2
	exit 1
fi

[[ -z "${VERBOSE}" ]] || echo 'Deleting config.cache'
find . -name config.cache -exec /bin/rm -rf {} + -print

[[ -z "${VERBOSE}" ]] || echo 'Deleting autom4te.cache'
find . -name autom4te.cache -exec /bin/rm -rf {} + -print

tool="autoreconf -fvi ${VPATH}"
for trial in bootstrap{,.{zsh,sh}}; do
	if [[ -x "${VPATH}/${trial}" ]]; then
		tool="${VPATH}/${trial} ${VPATH}"
	fi
done

[[ -z "${VERBOSE}" ]] || echo "${tool}"
eval ${tool}

if [[ ! -x ./configure ]]; then
	echo "Could not find or produce a ./configure file!"
	exit 1
fi
exit 0
