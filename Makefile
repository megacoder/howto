PREFIX	=${HOME}
HOWDIR	=${PREFIX}/howto

HFILES	:=$(wildcard howto-*)

TARGETS	=all clean distclean clobber install uninstall

.PHONY:	${TARGETS}

${TARGETS}::

all::	${HFILES}

install:: ${HFILES}
	chmod +x ${HFILES}

uninstall::
	@echo -e '\t"rm -rf ." yourself, buddy!'
