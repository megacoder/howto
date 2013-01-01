#!/bin/zsh
ME="${0:t}"
USAGE="usage: ${ME} [name..]"
PROD="${PWD:a:t:r}"
PREFIX="${HOME}/src/h/howto.git"
PATH="${PREFIX}/bin:${PATH}"			export PATH
HOWTOS="${PREFIX}/howtos"
NEW=
while getopts en c; do
	case "${c}" in
	e )	NEW="edit";;
	n )	NEW="create";;
	* )	echo "${USAGE}" >&2; exit 1;;
	esac
done
shift $(( ${OPTIND} - 1 ))
if [ $# -gt 0 ]; then
	PROD="${1}"
	shift
fi
HOWTO="${HOWTOS}/howto-${PROD}"
if [ ! -r "${HOWTO}" -o "${NEW}" ]; then
	if [ "${NEW}" = "create" ]; then
		sed -e "s/<PROD>/${PROD}/g" >"${HOWTO}" <<EOF
#!/bin/zsh
# vi: ts=8 sw=8 noet
if [ -f configure ]; then
	autoreconf -fvim
else
	configure -m "<PROD>"						\\
		"\$@"
fi
EOF
	fi
	${EDITOR:-gvim-cvs} "${HOWTO}"
	chmod 0755 "${HOWTO}"
fi
exec ${HOWTO} "$@" 2>&1 | tee howto.log
