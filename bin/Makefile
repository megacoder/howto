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

SCRIPTS	:=$(wildcard *.zsh) howto.zsh

define	INSTALL_template
.PHONY:	install-${1}
install-${1}:: ${1}
	install -C -m 0755 "${1}" "$${BINDIR}/`basename -s .zsh ${1}`"
install:: install-${1}
endef

all::	${SCRIPTS}

${TARGETS}::

clobber distclean:: clean

howto.zsh:: howto.zsh.in
	sed -r -e "s;<MYDIR>;${MYDIR};g" howto.zsh.in >howto.zsh
	chmod +x howto.zsh

clobber::
	${RM} howto.zsh

$(foreach s,${SCRIPTS},$(eval $(call INSTALL_template,${s})))

uninstall::
	cd "${BINDIR}" && ${RM} ${SCRIPTS}

ifneq	(,${SUBDIRS})
${TARGETS}::
	${MAKE} TARGET=$@ ${SUBDIRS}
${SUBDIRS}::
	${MAKE} -C $@ ${TARGET}
endif
