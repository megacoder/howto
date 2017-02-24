#!/bin/zsh
ME="${0:t:r}"
USAGE="usage: ${ME} [name..]"

PROD="${PWD:a:t:r}"

PREFIX='/home/reynolds/src/h/howto'
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
if [[ -x /bin/pump ]]; then
	# If we have pump(1) available, do its initialization now and
	# register an exit function to gracefully shut it down.  This
	# is so-o-o cool!
	eval $( /bin/pump --startup )
	ZSHEXIT()       {
		/bin/pump --shutdown
	}
fi
if [[ -f configure ]]; then
	autoreconf -fvim
else
	configure -m '<PROD>'						\
	"$@"
fi
EOF
	chmod 0755 "${HOWTO}"
}

destroy()	{
	[[ "${ACTIONS}" =~ 'n' ]] && echo rm -f "${HOWTO}" || rm -f "${HOWTO}"
}

RETVAL=0

ACTIONS=''
while getopts elnrvx c; do
	case "${c}" in
	e )	ACTIONS+='e';;
	l )	ACTIONS+='l';;
	n )	ACTIONS+='n';;
	r )	ACTIONS+='r';;
	v )	ACTIONS+='v';;
	x )	ACTIONS+='x';;
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

if [[ "${ACTIONS}" =~ 'v' ]]; then
	show()	{
		local	v
		for v in "${@}"; do
			printf '%15s="%s"\n' ${v} "$(eval echo \$${v})"
		done
	}

	show ACTIONS
	show BINDIR
	show HOWTO
	show ME
	show PATH
	show PREFIX
	show PROD
	show RULEDIR
	show USAGE

	exit 0
fi

if [[ "${ACTIONS}" =~ 'x' ]]; then
	[[ "${ACTIONS}" =~ 'n' ]] && echo setup || setup
fi

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
