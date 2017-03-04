TARGETS=all check clean clobber distclean install uninstall
TARGET=all

PREFIX=${DESTDIR}/opt
BINDIR=${PREFIX}/bin
SUBDIRS=

SHELL	=/bin/zsh
export	SHELL

MYDIR	=$(shell dirname $$(/bin/pwd))

INSTALL	=install

.PHONY: ${TARGETS} ${SUBDIRS}

SCRIPTS	:=$(wildcard *.zsh) howto.zsh $(wildcard *.py)

all::	${SCRIPTS}

${TARGETS}::

clobber distclean:: clean

howto.zsh:: howto.zsh.in
	sed -r -e "s;<MYDIR>;${MYDIR};g" howto.zsh.in >howto.zsh
	chmod +x howto.zsh

clobber::
	${RM} howto.zsh

install:: ${SCRIPTS}
	for s in ${SCRIPTS}; do						\
		e=$${s:t:r};						\
		${INSTALL} -D "$${s}" "${BINDIR}/$${e}";		\
	done

uninstall::
	cd "${BINDIR}" && ${RM} ${SCRIPTS}

ifneq	(,${SUBDIRS})
${TARGETS}::
	${MAKE} TARGET=$@ ${SUBDIRS}
${SUBDIRS}::
	${MAKE} -C $@ ${TARGET}
endif
