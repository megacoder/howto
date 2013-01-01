TARGETS=all check clean clobber distclean install uninstall
TARGET=all

PREFIX=${DESTDIR}/opt
BINDIR=${PREFIX}/bin
SUBDIRS=

SHELL	=/bin/zsh
export	SHELL

INSTALL=install

.PHONY: ${TARGETS} ${SUBDIRS}

SCRIPTS	=$(wildcard *.zsh)

all::	${SCRIPTS}

${TARGETS}::

clobber distclean:: clean

install:: ${SCRIPTS}
	@for s in ${SCRIPTS}; do					\
		e=$${s:t:r};						\
		${SHELL} -xc "${INSTALL} -D $${s} ${BINDIR}/$${e}";	\
	done

uninstall::
	${RM} ${BINDIR}/FIXME

ifneq	(,${SUBDIRS})
${TARGETS}::
	${MAKE} TARGET=$@ ${SUBDIRS}
${SUBDIRS}::
	${MAKE} -C $@ ${TARGET}
endif
