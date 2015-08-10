#!/bin/zsh
ME="${0:t}"
USAGE="usage: ${ME} [name..]"

PROD="${PWD:a:t:r}"

PREFIX='/home/reynolds/src/h/howto.git'
BINDIR="${PREFIX}/bin"
RULEDIR="${PREFIX}/howtos"
HOWTO="${RULEDIR}/howto-${PROD}"

PATH="${BINDIR}:${PATH}"			export PATH

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
	configure -m '<PROD>'						\
	"$@"
fi
EOF
	chmod 0755 "${HOWTO}"
}

RETVAL=0

ACTIONS=''
while getopts elnr c; do
	case "${c}" in
	e )	ACTIONS+='e';;
	l )	ACTIONS+='l';;
	n )	ACTIONS+='n';;
	r )	ACTIONS+='r';;
	* )	echo "${USAGE}" >&2; exit 1;;
	esac
done
shift $(( ${OPTIND} - 1 ))

if [[ $# -gt 0 ]]; then
	PROD="${1}"
	shift
fi

if [[ -z "${ACTIONS}" ]]; then
	ACTIONS='r'
fi

if [[ ! -f "${HOWTO}" ]]; then
	ACTIONS+='c'
fi

# Take the ACTIONS, in a logical order

if [[ "${ACTIONS}" =~ 'c' ]]; then
	[[ "${ACTIONS}" =~ 'n' ]] && echo setup || setup
	ACTIONS+='e'
fi

if [[ "${ACTIONS}" =~ 'e' ]]; then
	[[ "${ACTIONS}" =~ 'n' ]] && echo edit || edit
fi

if [[ "${ACTIONS}" =~ 'l' ]]; then
	[[ "${ACTIONS}" =~ 'n' ]] && echo list || cat "${HOWTO}"
fi

if [[ "${ACTIONS}" =~ 'r' ]]; then
	[[ "${ACTIONS}" =~ 'n' ]] && echo run || (
		"${HOWTO}" "$@" 2>&1 | tee howto.log
	)
fi
exit "${RETVAL}"