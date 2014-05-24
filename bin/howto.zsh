#!/bin/zsh
ME="${0:t}"
USAGE="usage: ${ME} [name..]"

edit()	{
	if [[ -z "${EDITOR}" ]]; then
		gvim -f "${HOWTO}"
	else
		"${EDITOR}" "${HOWTO}"
	fi
}

setup()	{
	sed -e "s/<PROD>/${PROD}/g" >"${HOWTO}" <<'EOF'
#!/bin/zsh
# vim: ts=8 sw=8 noet
if [[ -f configure ]]; then
	autoreconf -fvim
else
	configure -m "<PROD>"						\
	"$@"
fi
EOF
	chmod 0755 "${HOWTO}"
}

ACTION="run"
while getopts eln c; do
	case "${c}" in
	e )	ACTION="edit";;
	l )	ACTION="list";;
	n )	ACTION="create";;
	* )	echo "${USAGE}" >&2; exit 1;;
	esac
done
shift $(( ${OPTIND} - 1 ))

PROD="${PWD:a:t:r}"
PREFIX="${HOME}/src/h/howto.github"
PATH="${PREFIX}/bin:${PATH}"			export PATH
HOWTOS="${PREFIX}/howtos"

if [[ $# -gt 0 ]]; then
	PROD="${1}"
	shift
fi

HOWTO="${HOWTOS}/howto-${PROD}"
case "${ACTION}" in
run )
	if [[ ! -f "${HOWTO}" ]]; then
		setup
	fi
	;;
create )
	setup
	edit
	;;
edit )
	if [[ ! -f "${HOWTO}" ]]; then
		setup
	fi
	edit
	;;
list )
	cat   "${HOWTO}"
	exit 0
	;;
esac
exec "${HOWTO}" "$@" 2>&1 | tee howto.log
