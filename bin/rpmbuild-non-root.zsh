#!/bin/zsh
# vim: noet sw=8 sw=8

ME="${0:t:r}"

DOCHANGELOG=false
BUILD=true
NAME="${0:t:r}"

while getopts X:bcn: c; do
	case "${c}" in
		b )	BUILD=false;;
		c )	DOCHANGELOG=true;;
		n )	NAME="${OPTARG}";;
		* )	echo "Huh?" >&2; exit 1;;
	esac
done
shift $(( OPTIND - 1 ))

if [[ $# -gt 0 ]]; then
	NAME="${0}"
	shift 1
fi

if [[ $# -gt 0 ]]; then
	echo "Too many arguments." >&2
fi

autoreconf -fvim
./configure
make -j20 dist

if ${DOCHANGELOG}; then
	git changelog >>${NAME}.spec
fi

rm -rf RPM
mkdir -p RPM/{SOURCES,RPMS,SRPMS,BUILD,SPECS}

if ${DOBUILD}; then
	rpmbuild							\
		-D"_topdir ${PWD}/RPM"					\
		-D"_sourcedir ${PWD}"					\
		-D"_specdir ${PWD}"					\
		-ba							\
		${NAME}.spec
fi
