#!/bin/zsh
# vim: noet sw=8 sw=8

ME="${0:t:r}"

NAME="${ME}"
while getopts X: c; do
	case "${c}" in
	* )	echo "Huh?" >&2; exit 1;;
	esac
done
shift $(( ${OPTIND} - 1 ))

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
git changelog >>${NAME}.spec
rm -rf RPM
mkdir -p RPM/{SOURCES,RPMS,SRPMS,BUILD,SPECS}
rpmbuild								\
	-D"_topdir ${PWD}/RPM"						\
	-D"_sourcedir ${PWD}"						\
	-D"_specdir ${PWD}"						\
	-ba								\
	${NAME}.spec
