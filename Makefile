CC        = gcc
CXX      = g++
AR       = ar
AWK      = awk
CFLAGS   = -g -Wall -O2 -pedantic -std=c99 -D_XOPEN_SOURCE=600
CPPFLAGS = -std=c++11 -g -Wall -O3 -fopenmp
LDFLAGS  =
LIBS     =

OBJ = Haplotag.o ParsingBam.o Util.o HaplotagProcess.o PhasingProcess.o Phasing.o PhasingGraph.o ModCall.o ModCallParsingBam.o ModCallProcess.o main.o

PROGRAMS = longphase

all: subprojects

subprojects:
	$(MAKE)	-C	./jemalloc -ld
	$(MAKE)	-C	./htslib
	$(MAKE)	$(PROGRAMS)

ALL_CPPFLAGS = -I. $(CPPFLAGS) -Ihtslib -Ijemalloc
ALL_LDFLAGS  = $(LDFLAGS) -Lhtslib/htslib -Ljemalloc/lib

# Usually config.mk and config.h are generated by running configure
# or config.status, but if those aren't used create defaults here.

config.mk:
	@sed -e '/^prefix/,/^LIBS/d;s/@Hsource@//;s/@Hinstall@/#/;s#@HTSDIR@#htslib#g;s/@HTSLIB_CPPFLAGS@/-I$$(HTSDIR)/g;s/@CURSES_LIB@/-lcurses/g' config.mk.in > $@

config.h:
	echo '/* Basic config.h generated by Makefile */' > $@
	echo '#define HAVE_CURSES' >> $@
	echo '#define HAVE_CURSES_H' >> $@

include config.mk
JEMDIR = jemalloc
JEMLIB = $(JEMDIR)/lib/libjemalloc.a -ldl

$(PROGRAMS): $(OBJ)
	$(CXX) $(ALL_CPPFLAGS) $(ALL_LDFLAGS)	-o $@ $^ $(HTSLIB_LIB) $(JEMLIB)

%.o: %.cpp
	$(CXX) $(ALL_CPPFLAGS) -o $@ -c $^

mostlyclean:
	-rm -f *.o

clean: mostlyclean
	-rm -f $(PROGRAMS)

distclean: clean
	-rm -f config.cache config.h config.log config.mk config.status
	-rm -f TAGS
	-rm -rf autom4te.cache

clean-jemalloc:
	$(MAKE)	-C	./jemalloc clean

distclean-jemalloc:
	$(MAKE)	-C	./jemalloc distclean

relclean-jemalloc:
	$(MAKE)	-C	./jemalloc distclean

clean-all: clean clean-htslib clean-jemalloc

distclean-all: distclean distclean-htslib distclean-jemalloc

mostlyclean-all: mostlyclean mostlyclean-htslib


tags:
	ctags -f TAGS *.[ch] misc/*.[ch]

force:

.PHONY: all subprojects
.PHONY: mostlyclean clean distclean
.PHONY: clean-jemalloc distclean-jemalloc relclean-jemalloc
.PHONY: clean-all distclean-all mostlyclean-all
.PHONY: tags force
