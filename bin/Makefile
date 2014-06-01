TARGETS=all check clean clobber distclean install uninstall
TARGET=all

PREFIX=${DESTDIR}/opt
BINDIR=${PREFIX}/bin
SUBDIRS=

SHELL	=/bin/zsh
export	SHELL

PREFIX	=$(shell dirname $$(/bin/pwd))

INSTALL	=install

.PHONY: ${TARGETS} ${SUBDIRS}

SCRIPTS	:=$(wildcard *.zsh) howto.zsh

all::	${SCRIPTS}

${TARGETS}::

clobber distclean:: clean

howto.zsh:: howto.zsh.in
	sed -r -e "s;<PREFIX>;${PREFIX};g" howto.zsh.in >howto.zsh
	chmod +x howto.zsh

clobber::
	${RM} howto.zsh

install:: ${SCRIPTS}
	@for s in ${SCRIPTS}; do					\
		e=$${s:t:r};						\
		${SHELL} -c "${INSTALL} -D $${s} ${BINDIR}/$${e}";	\
	done

uninstall::
	cd "${BINDIR}" && ${RM} ${SCRIPTS}

ifneq	(,${SUBDIRS})
${TARGETS}::
	${MAKE} TARGET=$@ ${SUBDIRS}
${SUBDIRS}::
	${MAKE} -C $@ ${TARGET}
endif
