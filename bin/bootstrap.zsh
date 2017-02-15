#!/bin/zsh
[[ "${BOOTSTRAP_VERBOSE}" = "" ]] || set -x
ME=${0:t:r}

VPATH=.
if [[ ! -z "$1" ]]; then
	VPATH="${1}"
fi
if [[ ! -d "${VPATH}" ]]; then
	echo "${ME}: VPATH (${VPATH}) does not exist." >&2
	exit 1
fi
echo "Cleaning up any prior configuration."
for name in config.cache autom4te.cache; do
	find . -name "${name}" -exec rm -rf {} + -print
done
tool="autoreconf -fvim ${VPATH}"
for trial in bootstrap{,.{zsh,sh}}; do
	if [[ -x "${VPATH}/${trial}" ]]; then
		tool="${VPATH}/${trial}"
	fi
done
eval ${tool}
if [[ ! -x ./configure ]]; then
	echo "Could not find or produce a ./configure file!"
	exit 1
fi
echo "Running configure with default arguments"
export	CC="gcc -std=gnu99 -march=native"
export	CFLAGS="${CFLAGS} -pipe -Os"
export	CXX="g++ -march=native"
export	CXXFLAGS="${CXXFLAGS} -pipe -Os"
if [[ /bin/pump ]]; then
	eval $(/bin/pump --startup)
	ZSHEXT()	{
		/bin/pump --shutdown
	}
fi
./configure								\
	--enable-silent-rules						\
	"$@"
if [[ -f Makefile ]]; then
	[[ -x /bin/pump ]] && pump make -j20 || make -j20
fi
