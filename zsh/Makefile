PREFIX	=${HOME}
ZDIR	=${PREFIX}/.zfunc

INSTALL	=install

all::	howto

check::	howto
	./howto ${ARGS}

install:: howto
	${INSTALL} -D howto ${ZDIR}/howto

uninstall::
	${RM} ${ZDIR}/howto
