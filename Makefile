#
# Auto-configuring Makefile for the Netwide Assembler.
#
# The Netwide Assembler is copyright (C) 1996 Simon Tatham and
# Julian Hall. All rights reserved. The software is
# redistributable under the license given in the file "LICENSE"
# distributed in the NASM archive.



top_srcdir	= .
srcdir		= .
objdir		= .

prefix		= /usr/local
exec_prefix	= ${prefix}
bindir		= ${exec_prefix}/bin
mandir		= ${datarootdir}/man
datarootdir	= ${prefix}/share

CC		= gcc
CFLAGS		= -g -O0 -fwrapv -U__STRICT_ANSI__ -fno-common -Werror=attributes -W -Wall -pedantic -Wc90-c99-compat -Wno-long-long -Werror=implicit -Werror=missing-braces -Werror=return-type -Werror=trigraphs -Werror=pointer-arith -Werror=missing-prototypes -Werror=missing-declarations -Werror=comment -Werror=vla
BUILD_CFLAGS	= $(CFLAGS) -DHAVE_CONFIG_H
INTERNAL_CFLAGS = -I$(srcdir) -I$(objdir) \
		  -I$(srcdir)/include -I$(objdir)/include \
		  -I$(srcdir)/x86 -I$(objdir)/x86 \
		  -I$(srcdir)/asm -I$(objdir)/asm \
		  -I$(srcdir)/disasm -I$(objdir)/disasm \
		  -I$(srcdir)/output -I$(objdir)/output
ALL_CFLAGS	= $(BUILD_CFLAGS) $(INTERNAL_CFLAGS)
LDFLAGS		= 
LIBS		= 

AR		= ar
RANLIB		= ranlib
STRIP		= strip

PERL		= perl
PERLFLAGS	= -I$(srcdir)/perllib -I$(srcdir)
RUNPERL         = $(PERL) $(PERLFLAGS)

INSTALL		= /usr/bin/install -c
INSTALL_PROGRAM	= ${INSTALL}
INSTALL_DATA	= ${INSTALL} -m 644

NROFF		= nroff
ASCIIDOC	= false
XMLTO		= false

MAKENSIS	= makensis

MKDIR		= mkdir
RM_F		= rm -f
RM_RF		= rm -rf
LN_S		= ln -s
FIND		= find

# Binary suffixes
O               = o
X               = 
A		= a

# Debug stuff
ifeq ($(TRACE),1)
	CFLAGS += -DNASM_TRACE
endif

.SUFFIXES: .c .i .s .$(O) .$(A) $(X) .1 .txt .xml

.PHONY: all doc rdf install clean distclean cleaner spotless install_rdf test
.PHONY: install_doc everything install_everything strip perlreq dist tags TAGS
.PHONY: manpages nsis

.c.$(O):
	$(CC) -c $(ALL_CFLAGS) -o $@ $<

.c.s:
	$(CC) -S $(ALL_CFLAGS) -o $@ $<

.c.i:
	$(CC) -E $(ALL_CFLAGS) -o $@ $<

.txt.xml:
	$(ASCIIDOC) -b docbook -d manpage -o $@ $<

.xml.1:
	$(XMLTO) man --skip-validation $< 2>/dev/null

# This rule is only used for rdoff, to allow common rules
.$(O)$(X):
	$(CC) $(LDFLAGS) -o $@ $< $(RDFLIB) $(NASMLIB) $(LIBS)

#-- Begin File Lists --#
NASM =	asm/nasm.$(O)
NDISASM = disasm/ndisasm.$(O)

LIBOBJ = stdlib/snprintf.$(O) stdlib/vsnprintf.$(O) stdlib/strlcpy.$(O) \
	stdlib/strnlen.$(O) \
	nasmlib/ver.$(O) \
	nasmlib/crc64.$(O) nasmlib/malloc.$(O) \
	nasmlib/md5c.$(O) nasmlib/string.$(O) \
	nasmlib/file.$(O) nasmlib/mmap.$(O) nasmlib/ilog2.$(O) \
	nasmlib/realpath.$(O) nasmlib/path.$(O) \
	nasmlib/filename.$(O) nasmlib/srcfile.$(O) \
	nasmlib/zerobuf.$(O) nasmlib/readnum.$(O) nasmlib/bsi.$(O) \
	nasmlib/rbtree.$(O) nasmlib/hashtbl.$(O) \
	nasmlib/raa.$(O) nasmlib/saa.$(O) \
	nasmlib/strlist.$(O) \
	nasmlib/perfhash.$(O) nasmlib/badenum.$(O) \
	common/common.$(O) \
	x86/insnsa.$(O) x86/insnsb.$(O) x86/insnsd.$(O) x86/insnsn.$(O) \
	x86/regs.$(O) x86/regvals.$(O) x86/regflags.$(O) x86/regdis.$(O) \
	x86/disp8.$(O) x86/iflag.$(O) \
	\
	asm/error.$(O) \
	asm/float.$(O) \
	asm/directiv.$(O) asm/directbl.$(O) \
	asm/pragma.$(O) \
	asm/assemble.$(O) asm/labels.$(O) asm/parser.$(O) \
	asm/preproc.$(O) asm/quote.$(O) asm/pptok.$(O) \
	asm/listing.$(O) asm/eval.$(O) asm/exprlib.$(O) asm/exprdump.$(O) \
	asm/stdscan.$(O) \
	asm/strfunc.$(O) asm/tokhash.$(O) \
	asm/segalloc.$(O) \
	asm/preproc-nop.$(O) \
	asm/rdstrnum.$(O) \
	\
	macros/macros.$(O) \
	\
	output/outform.$(O) output/outlib.$(O) output/legacy.$(O) \
	output/nulldbg.$(O) output/nullout.$(O) \
	output/outbin.$(O) output/outaout.$(O) output/outcoff.$(O) \
	output/outelf.$(O) \
	output/outobj.$(O) output/outas86.$(O) output/outrdf2.$(O) \
	output/outdbg.$(O) output/outieee.$(O) output/outmacho.$(O) \
	output/codeview.$(O) \
	\
	disasm/disasm.$(O) disasm/sync.$(O)

SUBDIRS  = stdlib nasmlib output asm disasm x86 common macros
XSUBDIRS = test doc nsis rdoff
#-- End File Lists --#

all: nasm$(X) ndisasm$(X) rdf

NASMLIB = libnasm.$(A)

$(NASMLIB): $(LIBOBJ)
	$(RM_F) $(NASMLIB)
	$(AR) cq $(NASMLIB) $(LIBOBJ)
	$(RANLIB) $(NASMLIB)

nasm$(X): $(NASM) $(NASMLIB)
	$(CC) $(LDFLAGS) -o nasm$(X) $(NASM) $(NASMLIB) $(LIBS)

ndisasm$(X): $(NDISASM) $(NASMLIB)
	$(CC) $(LDFLAGS) -o ndisasm$(X) $(NDISASM) $(NASMLIB) $(LIBS)

#-- Begin Generated File Rules --#

# These source files are automagically generated from data files using
# Perl scripts. They're distributed, though, so it isn't necessary to
# have Perl just to recompile NASM from the distribution.

# Perl-generated source files
PERLREQ = x86/insnsb.c x86/insnsa.c x86/insnsd.c x86/insnsi.h x86/insnsn.c \
	  x86/regs.c x86/regs.h x86/regflags.c x86/regdis.c x86/regdis.h \
	  x86/regvals.c asm/tokhash.c asm/tokens.h asm/pptok.h asm/pptok.c \
	  x86/iflag.c x86/iflaggen.h \
	  macros/macros.c \
	  asm/pptok.ph asm/directbl.c asm/directiv.h \
	  version.h version.mac version.mak nsis/version.nsh

INSDEP = x86/insns.dat x86/insns.pl x86/insns-iflags.ph

x86/iflag.c: $(INSDEP)
	$(RUNPERL) $(srcdir)/x86/insns.pl -fc \
		$(srcdir)/x86/insns.dat x86/iflag.c
x86/iflaggen.h: $(INSDEP)
	$(RUNPERL) $(srcdir)/x86/insns.pl -fh \
		$(srcdir)/x86/insns.dat x86/iflaggen.h
x86/insnsb.c: $(INSDEP)
	$(RUNPERL) $(srcdir)/x86/insns.pl -b \
		$(srcdir)/x86/insns.dat x86/insnsb.c
x86/insnsa.c: $(INSDEP)
	$(RUNPERL) $(srcdir)/x86/insns.pl -a \
		$(srcdir)/x86/insns.dat x86/insnsa.c
x86/insnsd.c: $(INSDEP)
	$(RUNPERL) $(srcdir)/x86/insns.pl -d \
		$(srcdir)/x86/insns.dat x86/insnsd.c
x86/insnsi.h: $(INSDEP)
	$(RUNPERL) $(srcdir)/x86/insns.pl -i \
		$(srcdir)/x86/insns.dat x86/insnsi.h
x86/insnsn.c: $(INSDEP)
	$(RUNPERL) $(srcdir)/x86/insns.pl -n \
		$(srcdir)/x86/insns.dat x86/insnsn.c

# These files contains all the standard macros that are derived from
# the version number.
version.h: version version.pl
	$(RUNPERL) $(srcdir)/version.pl h < $(srcdir)/version > version.h
version.mac: version version.pl
	$(RUNPERL) $(srcdir)/version.pl mac < $(srcdir)/version > version.mac
version.sed: version version.pl
	$(RUNPERL) $(srcdir)/version.pl sed < $(srcdir)/version > version.sed
version.mak: version version.pl
	$(RUNPERL) $(srcdir)/version.pl make < $(srcdir)/version > version.mak
nsis/version.nsh: version version.pl
	$(RUNPERL) $(srcdir)/version.pl nsis < $(srcdir)/version > nsis/version.nsh

# This source file is generated from the standard macros file
# `standard.mac' by another Perl script. Again, it's part of the
# standard distribution.
macros/macros.c: macros/macros.pl asm/pptok.ph version.mac \
	$(srcdir)/macros/*.mac $(srcdir)/output/*.mac
	$(RUNPERL) $(srcdir)/macros/macros.pl version.mac \
		$(srcdir)/macros/*.mac $(srcdir)/output/*.mac

# These source files are generated from regs.dat by yet another
# perl script.
x86/regs.c: x86/regs.dat x86/regs.pl
	$(RUNPERL) $(srcdir)/x86/regs.pl c \
		$(srcdir)/x86/regs.dat > x86/regs.c
x86/regflags.c: x86/regs.dat x86/regs.pl
	$(RUNPERL) $(srcdir)/x86/regs.pl fc \
		$(srcdir)/x86/regs.dat > x86/regflags.c
x86/regdis.c: x86/regs.dat x86/regs.pl
	$(RUNPERL) $(srcdir)/x86/regs.pl dc \
		$(srcdir)/x86/regs.dat > x86/regdis.c
x86/regdis.h: x86/regs.dat x86/regs.pl
	$(RUNPERL) $(srcdir)/x86/regs.pl dh \
		$(srcdir)/x86/regs.dat > x86/regdis.h
x86/regvals.c: x86/regs.dat x86/regs.pl
	$(RUNPERL) $(srcdir)/x86/regs.pl vc \
		$(srcdir)/x86/regs.dat > x86/regvals.c
x86/regs.h: x86/regs.dat x86/regs.pl
	$(RUNPERL) $(srcdir)/x86/regs.pl h \
		$(srcdir)/x86/regs.dat > x86/regs.h

# Assembler token hash
asm/tokhash.c: x86/insns.dat x86/regs.dat asm/tokens.dat asm/tokhash.pl \
	perllib/phash.ph
	$(RUNPERL) $(srcdir)/asm/tokhash.pl c \
		$(srcdir)/x86/insns.dat $(srcdir)/x86/regs.dat \
		$(srcdir)/asm/tokens.dat > asm/tokhash.c

# Assembler token metadata
asm/tokens.h: x86/insns.dat x86/regs.dat asm/tokens.dat asm/tokhash.pl \
	perllib/phash.ph
	$(RUNPERL) $(srcdir)/asm/tokhash.pl h \
		$(srcdir)/x86/insns.dat $(srcdir)/x86/regs.dat \
		$(srcdir)/asm/tokens.dat > asm/tokens.h

# Preprocessor token hash
asm/pptok.h: asm/pptok.dat asm/pptok.pl perllib/phash.ph
	$(RUNPERL) $(srcdir)/asm/pptok.pl h \
		$(srcdir)/asm/pptok.dat asm/pptok.h
asm/pptok.c: asm/pptok.dat asm/pptok.pl perllib/phash.ph
	$(RUNPERL) $(srcdir)/asm/pptok.pl c \
		$(srcdir)/asm/pptok.dat asm/pptok.c
asm/pptok.ph: asm/pptok.dat asm/pptok.pl perllib/phash.ph
	$(RUNPERL) $(srcdir)/asm/pptok.pl ph \
		$(srcdir)/asm/pptok.dat asm/pptok.ph

# Directives hash
asm/directiv.h: asm/directiv.dat nasmlib/perfhash.pl perllib/phash.ph
	$(RUNPERL) $(srcdir)/nasmlib/perfhash.pl h \
		$(srcdir)/asm/directiv.dat asm/directiv.h
asm/directbl.c: asm/directiv.dat nasmlib/perfhash.pl perllib/phash.ph
	$(RUNPERL) $(srcdir)/nasmlib/perfhash.pl c \
		$(srcdir)/asm/directiv.dat asm/directbl.c

#-- End Generated File Rules --#

perlreq: $(PERLREQ)

#-- Begin RDOFF Shared Rules --#

RDFLIBOBJ = rdoff/rdoff.$(O) rdoff/rdfload.$(O) rdoff/symtab.$(O) \
	    rdoff/collectn.$(O) rdoff/rdlib.$(O) rdoff/segtab.$(O) \
	    rdoff/hash.$(O)

RDFPROGS = rdoff/rdfdump$(X) rdoff/ldrdf$(X) rdoff/rdx$(X) rdoff/rdflib$(X) \
	   rdoff/rdf2bin$(X)
RDF2BINLINKS = rdoff/rdf2com$(X) rdoff/rdf2ith$(X) \
	    rdoff/rdf2ihx$(X) rdoff/rdf2srec$(X)

RDFLIB = rdoff/librdoff.$(A)
RDFLIBS = $(RDFLIB) $(NASMLIB)

rdoff/rdfdump$(X): rdoff/rdfdump.$(O) $(RDFLIBS)
rdoff/ldrdf$(X): rdoff/ldrdf.$(O) $(RDFLIBS)
rdoff/rdx$(X): rdoff/rdx.$(O) $(RDFLIBS)
rdoff/rdflib$(X): rdoff/rdflib.$(O) $(RDFLIBS)
rdoff/rdf2bin$(X): rdoff/rdf2bin.$(O) $(RDFLIBS)
rdoff/rdf2com$(X): rdoff/rdf2bin$(X)
	$(RM_F) rdoff/rdf2com$(X)
	cd rdoff && $(LN_S) rdf2bin$(X) rdf2com$(X)
rdoff/rdf2ith$(X): rdoff/rdf2bin$(X)
	$(RM_F) rdoff/rdf2ith$(X)
	cd rdoff && $(LN_S) rdf2bin$(X) rdf2ith$(X)
rdoff/rdf2ihx$(X): rdoff/rdf2bin$(X)
	$(RM_F) rdoff/rdf2ihx$(X)
	cd rdoff && $(LN_S) rdf2bin$(X) rdf2ihx$(X)
rdoff/rdf2srec$(X): rdoff/rdf2bin$(X)
	$(RM_F) rdoff/rdf2srec$(X)
	cd rdoff && $(LN_S) rdf2bin$(X) rdf2srec$(X)

#-- End RDOFF Shared Rules --#

rdf: $(RDFPROGS) $(RDF2BINLINKS)

$(RDFLIB): $(RDFLIBOBJ)
	$(RM_F) $(RDFLIB)
	$(AR) cq $(RDFLIB) $(RDFLIBOBJ)
	$(RANLIB) $(RDFLIB)

#-- Begin NSIS Rules --#

# NSIS is not built except by explicit request, as it only applies to
# Windows platforms
nsis/arch.nsh: nsis/getpearch.pl nasm$(X)
	$(PERL) $(srcdir)/nsis/getpearch.pl nasm$(X) > nsis/arch.nsh

# Should only be done after "make everything".
# The use of redirection here keeps makensis from moving the cwd to the
# source directory.
nsis: nsis/nasm.nsi nsis/arch.nsh nsis/version.nsh
	$(MAKENSIS) -Dsrcdir="$(srcdir)" -Dobjdir="$(objdir)" - < nsis/nasm.nsi

#-- End NSIS Rules --#

# Generated manpages, also pregenerated for distribution
manpages: nasm.1 ndisasm.1

install: nasm$(X) ndisasm$(X)
	$(MKDIR) -p $(INSTALLROOT)$(bindir)
	$(INSTALL_PROGRAM) nasm$(X) $(INSTALLROOT)$(bindir)/nasm$(X)
	$(INSTALL_PROGRAM) ndisasm$(X) $(INSTALLROOT)$(bindir)/ndisasm$(X)
	$(MKDIR) -p $(INSTALLROOT)$(mandir)/man1
	$(INSTALL_DATA) $(srcdir)/nasm.1 $(INSTALLROOT)$(mandir)/man1/nasm.1
	$(INSTALL_DATA) $(srcdir)/ndisasm.1 $(INSTALLROOT)$(mandir)/man1/ndisasm.1

clean:
	for d in . $(SUBDIRS) $(XSUBDIRS); do \
		$(RM_F) "$$d"/*.$(O) "$$d"/*.s "$$d"/*.i "$$d"/*.$(A) ; \
	done
	$(RM_F) nasm$(X) ndisasm$(X)
	$(RM_F) nasm-*-installer-*.exe
	$(RM_F) tags TAGS
	$(RM_F) nsis/arch.nsh
	$(RM_F) perlbreq.si
	$(RM_F) $(RDFPROGS) $(RDF2BINLINKS)

distclean: clean
	$(RM_F) config.log config.status config/config.h
	$(RM_F) Makefile
	for d in . $(SUBDIRS) $(XSUBDIRS); do \
		$(RM_F) "$$d"/*~ "$$d"/*.bak "$$d"/*.lst "$$d"/*.bin ; \
	done
	$(RM_F) test/*.$(O)
	$(RM_RF) autom4te*.cache

cleaner: clean
	$(RM_F) $(PERLREQ) *.1 nasm.spec
	cd doc && $(MAKE) clean

spotless: distclean cleaner
	$(RM_F) doc/Makefile

strip:
	$(STRIP) --strip-unneeded nasm$(X) ndisasm$(X)

TAGS:
	$(RM_F) TAGS
	$(FIND) . -name '*.[hcS]' -print | xargs etags -a

tags:
	$(RM_F) tags
	$(FIND) . -name '*.[hcS]' -print | xargs ctags -a

cscope:
	$(RM_F) cscope.out cscope.files
	$(FIND) . -name '*.[hcS]' -print > cscope.files
	cscope -b -f cscope.out

rdf_install install_rdf install_rdoff:
	$(MKDIR) -p $(INSTALLROOT)$(bindir)
	for f in $(RDFPROGS); do \
		$(INSTALL_PROGRAM) "$$f" '$(INSTALLROOT)$(bindir)'/ ; \
	done
	cd '$(INSTALLROOT)$(bindir)' && \
	for f in $(RDF2BINLINKS); do \
		bn=`basename "$$f"` && $(RM_F) "$$bn" && \
		$(LN_S) rdf2bin$(X) "$$bn" ; \
	done
	$(MKDIR) -p $(INSTALLROOT)$(mandir)/man1
	$(INSTALL_DATA) $(srcdir)/rdoff/*.1 $(INSTALLROOT)$(mandir)/man1/

doc:
	cd doc && $(MAKE) all

doc_install install_doc:
	cd doc && $(MAKE) install

everything: all manpages doc rdf

install_everything: everything install install_doc install_rdf

dist:
	$(MAKE) alldeps
	$(MAKE) spotless perlreq manpages spec
	autoheader
	autoconf
	$(RM_RF) ./autom4te*.cache

tar: dist
	tar -cvj --exclude CVS -C .. -f ../nasm-`cat version`-`date +%Y%m%d`.tar.bz2 `basename \`pwd\``

spec: nasm.spec

ALLPERLSRC := $(shell find $(srcdir) -type f -name '*.p[lh]')

perlbreq.si: $(ALLPERLSRC)
	sed -n -r -e 's/^[[:space:]]*use[[:space:]]+([^[:space:];]+).*$$/BuildRequires: perl(\1)/p' $(ALLPERLSRC) | \
	sed -r -e '/perl\((strict|warnings|Win32.*)\)/d' | \
	sort | uniq > perlbreq.si || ( rm -f perlbreq.si ; false )

nasm.spec: nasm.spec.in nasm.spec.sed version.sed perlbreq.si
	sed -f version.sed -f nasm.spec.sed \
	< nasm.spec.in > nasm.spec || ( rm -f nasm.spec ; false )

splint:
	splint -weak *.c

test: nasm$(X)
	cd test && $(RUNPERL) performtest.pl --nasm=../nasm *.asm

golden: nasm$(X)
	cd test && $(RUNPERL) performtest.pl --golden --nasm=../nasm *.asm

#
# This build dependencies in *ALL* makefiles.  Partially for that reason,
# it's expected to be invoked manually.
#
alldeps: perlreq tools/syncfiles.pl tools/mkdep.pl
	$(RUNPERL) tools/syncfiles.pl Makefile.in Mkfiles/*.mak
	$(RUNPERL) tools/mkdep.pl -M Makefile.in Mkfiles/*.mak -- \
		. include asm common config disasm macros nasmlib \
		output stdlib x86 rdoff
	./config.status

#-- Magic hints to mkdep.pl --#
# @object-ending: ".$(O)"
# @path-separator: "/"
#-- Everything below is generated by mkdep.pl - do not edit --#
asm/assemble.$(O): asm/assemble.c asm/assemble.h asm/directiv.h \
 asm/listing.h asm/pptok.h asm/preproc.h asm/tokens.h config/config.h \
 config/msvc.h config/unknown.h config/watcom.h include/compiler.h \
 include/disp8.h include/error.h include/iflag.h include/insns.h \
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h \
 include/perfhash.h include/strlist.h include/tables.h x86/iflaggen.h \
 x86/insnsi.h x86/regs.h
asm/directbl.$(O): asm/directbl.c asm/directiv.h config/config.h \
 config/msvc.h config/unknown.h config/watcom.h include/compiler.h \
 include/nasmint.h include/nasmlib.h include/perfhash.h
asm/directiv.$(O): asm/directiv.c asm/assemble.h asm/directiv.h asm/eval.h \
 asm/float.h asm/listing.h asm/pptok.h asm/preproc.h asm/stdscan.h \
 config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/error.h include/iflag.h include/labels.h \
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h \
 include/perfhash.h include/strlist.h include/tables.h output/outform.h \
 x86/iflaggen.h x86/insnsi.h x86/regs.h
asm/error.$(O): asm/error.c config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/nasmint.h \
 include/nasmlib.h
asm/eval.$(O): asm/eval.c asm/assemble.h asm/directiv.h asm/eval.h \
 asm/float.h asm/pptok.h asm/preproc.h config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/iflag.h include/labels.h include/nasm.h include/nasmint.h \
 include/nasmlib.h include/opflags.h include/perfhash.h include/strlist.h \
 include/tables.h x86/iflaggen.h x86/insnsi.h x86/regs.h
asm/exprdump.$(O): asm/exprdump.c asm/directiv.h asm/pptok.h asm/preproc.h \
 config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h \
 include/opflags.h include/perfhash.h include/strlist.h include/tables.h \
 x86/insnsi.h x86/regs.h
asm/exprlib.$(O): asm/exprlib.c asm/directiv.h asm/pptok.h asm/preproc.h \
 config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h \
 include/opflags.h include/perfhash.h include/strlist.h include/tables.h \
 x86/insnsi.h x86/regs.h
asm/float.$(O): asm/float.c asm/directiv.h asm/float.h asm/pptok.h \
 asm/preproc.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h x86/insnsi.h x86/regs.h
asm/labels.$(O): asm/labels.c asm/directiv.h asm/pptok.h asm/preproc.h \
 config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/error.h include/hashtbl.h include/labels.h \
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h \
 include/perfhash.h include/strlist.h include/tables.h x86/insnsi.h \
 x86/regs.h
asm/listing.$(O): asm/listing.c asm/directiv.h asm/listing.h asm/pptok.h \
 asm/preproc.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h x86/insnsi.h x86/regs.h
asm/nasm.$(O): asm/nasm.c asm/assemble.h asm/directiv.h asm/eval.h \
 asm/float.h asm/listing.h asm/parser.h asm/pptok.h asm/preproc.h \
 asm/stdscan.h asm/tokens.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/iflag.h \
 include/insns.h include/labels.h include/nasm.h include/nasmint.h \
 include/nasmlib.h include/opflags.h include/perfhash.h include/raa.h \
 include/saa.h include/strlist.h include/tables.h include/ver.h \
 output/outform.h x86/iflaggen.h x86/insnsi.h x86/regs.h
asm/parser.$(O): asm/parser.c asm/assemble.h asm/directiv.h asm/eval.h \
 asm/float.h asm/parser.h asm/pptok.h asm/preproc.h asm/stdscan.h \
 asm/tokens.h config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/error.h include/iflag.h include/insns.h \
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h \
 include/perfhash.h include/strlist.h include/tables.h x86/iflaggen.h \
 x86/insnsi.h x86/regs.h
asm/pptok.$(O): asm/pptok.c asm/pptok.h asm/preproc.h config/config.h \
 config/msvc.h config/unknown.h config/watcom.h include/compiler.h \
 include/hashtbl.h include/nasmint.h include/nasmlib.h
asm/pragma.$(O): asm/pragma.c asm/assemble.h asm/directiv.h asm/pptok.h \
 asm/preproc.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/iflag.h \
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h \
 include/perfhash.h include/strlist.h include/tables.h x86/iflaggen.h \
 x86/insnsi.h x86/regs.h
asm/preproc-nop.$(O): asm/preproc-nop.c asm/directiv.h asm/listing.h \
 asm/pptok.h asm/preproc.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h x86/insnsi.h x86/regs.h
asm/preproc.$(O): asm/preproc.c asm/directiv.h asm/eval.h asm/listing.h \
 asm/pptok.h asm/preproc.h asm/quote.h asm/stdscan.h asm/tokens.h \
 config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/error.h include/hashtbl.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h x86/insnsi.h x86/regs.h
asm/quote.$(O): asm/quote.c asm/quote.h config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h \
 include/nasmlib.h
asm/rdstrnum.$(O): asm/rdstrnum.c asm/directiv.h asm/pptok.h asm/preproc.h \
 config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h \
 include/opflags.h include/perfhash.h include/strlist.h include/tables.h \
 x86/insnsi.h x86/regs.h
asm/segalloc.$(O): asm/segalloc.c asm/directiv.h asm/pptok.h asm/preproc.h \
 asm/tokens.h config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/iflag.h include/insns.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h x86/iflaggen.h x86/insnsi.h x86/regs.h
asm/stdscan.$(O): asm/stdscan.c asm/directiv.h asm/pptok.h asm/preproc.h \
 asm/quote.h asm/stdscan.h asm/tokens.h config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/iflag.h include/insns.h include/nasm.h include/nasmint.h \
 include/nasmlib.h include/opflags.h include/perfhash.h include/strlist.h \
 include/tables.h x86/iflaggen.h x86/insnsi.h x86/regs.h
asm/strfunc.$(O): asm/strfunc.c asm/directiv.h asm/pptok.h asm/preproc.h \
 config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h \
 include/opflags.h include/perfhash.h include/strlist.h include/tables.h \
 x86/insnsi.h x86/regs.h
asm/tokhash.$(O): asm/tokhash.c asm/directiv.h asm/pptok.h asm/preproc.h \
 asm/stdscan.h asm/tokens.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/hashtbl.h include/iflag.h \
 include/insns.h include/nasm.h include/nasmint.h include/nasmlib.h \
 include/opflags.h include/perfhash.h include/strlist.h include/tables.h \
 x86/iflaggen.h x86/insnsi.h x86/regs.h
common/common.$(O): common/common.c asm/directiv.h asm/pptok.h asm/preproc.h \
 asm/tokens.h config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/iflag.h include/insns.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h x86/iflaggen.h x86/insnsi.h x86/regs.h
disasm/disasm.$(O): disasm/disasm.c asm/directiv.h asm/pptok.h asm/preproc.h \
 asm/tokens.h config/config.h config/msvc.h config/unknown.h config/watcom.h \
 disasm/disasm.h disasm/sync.h include/compiler.h include/disp8.h \
 include/iflag.h include/insns.h include/nasm.h include/nasmint.h \
 include/nasmlib.h include/opflags.h include/perfhash.h include/strlist.h \
 include/tables.h x86/iflaggen.h x86/insnsi.h x86/regdis.h x86/regs.h
disasm/ndisasm.$(O): disasm/ndisasm.c asm/directiv.h asm/pptok.h \
 asm/preproc.h asm/tokens.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h disasm/disasm.h disasm/sync.h include/compiler.h \
 include/error.h include/iflag.h include/insns.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h include/ver.h x86/iflaggen.h \
 x86/insnsi.h x86/regs.h
disasm/sync.$(O): disasm/sync.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h disasm/sync.h include/compiler.h \
 include/nasmint.h include/nasmlib.h
macros/macros.$(O): macros/macros.c asm/directiv.h asm/pptok.h asm/preproc.h \
 config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/hashtbl.h include/nasm.h include/nasmint.h \
 include/nasmlib.h include/opflags.h include/perfhash.h include/strlist.h \
 include/tables.h output/outform.h x86/insnsi.h x86/regs.h
nasmlib/badenum.$(O): nasmlib/badenum.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h \
 include/nasmlib.h
nasmlib/bsi.$(O): nasmlib/bsi.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h \
 include/nasmlib.h
nasmlib/crc64.$(O): nasmlib/crc64.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/hashtbl.h \
 include/nasmint.h include/nasmlib.h
nasmlib/file.$(O): nasmlib/file.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h nasmlib/file.h
nasmlib/filename.$(O): nasmlib/filename.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h
nasmlib/hashtbl.$(O): nasmlib/hashtbl.c asm/directiv.h asm/pptok.h \
 asm/preproc.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/hashtbl.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h x86/insnsi.h x86/regs.h
nasmlib/ilog2.$(O): nasmlib/ilog2.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h \
 include/nasmlib.h
nasmlib/malloc.$(O): nasmlib/malloc.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h
nasmlib/md5c.$(O): nasmlib/md5c.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/md5.h \
 include/nasmint.h
nasmlib/mmap.$(O): nasmlib/mmap.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h nasmlib/file.h
nasmlib/path.$(O): nasmlib/path.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h
nasmlib/perfhash.$(O): nasmlib/perfhash.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/hashtbl.h \
 include/nasmint.h include/nasmlib.h include/perfhash.h
nasmlib/raa.$(O): nasmlib/raa.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h \
 include/nasmlib.h include/raa.h
nasmlib/rbtree.$(O): nasmlib/rbtree.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h \
 include/rbtree.h
nasmlib/readnum.$(O): nasmlib/readnum.c asm/directiv.h asm/pptok.h \
 asm/preproc.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h x86/insnsi.h x86/regs.h
nasmlib/realpath.$(O): nasmlib/realpath.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h \
 include/nasmlib.h
nasmlib/saa.$(O): nasmlib/saa.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h \
 include/nasmlib.h include/saa.h
nasmlib/srcfile.$(O): nasmlib/srcfile.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/hashtbl.h \
 include/nasmint.h include/nasmlib.h
nasmlib/string.$(O): nasmlib/string.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h \
 include/nasmlib.h
nasmlib/strlist.$(O): nasmlib/strlist.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h \
 include/nasmlib.h include/strlist.h
nasmlib/ver.$(O): nasmlib/ver.c include/ver.h version.h
nasmlib/zerobuf.$(O): nasmlib/zerobuf.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h \
 include/nasmlib.h
output/codeview.$(O): output/codeview.c asm/directiv.h asm/pptok.h \
 asm/preproc.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/hashtbl.h \
 include/md5.h include/nasm.h include/nasmint.h include/nasmlib.h \
 include/opflags.h include/perfhash.h include/saa.h include/strlist.h \
 include/tables.h output/outlib.h output/pecoff.h version.h x86/insnsi.h \
 x86/regs.h
output/legacy.$(O): output/legacy.c asm/directiv.h asm/pptok.h asm/preproc.h \
 config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/error.h include/nasm.h include/nasmint.h \
 include/nasmlib.h include/opflags.h include/perfhash.h include/strlist.h \
 include/tables.h output/outlib.h x86/insnsi.h x86/regs.h
output/nulldbg.$(O): output/nulldbg.c asm/directiv.h asm/pptok.h \
 asm/preproc.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h output/outlib.h x86/insnsi.h x86/regs.h
output/nullout.$(O): output/nullout.c asm/directiv.h asm/pptok.h \
 asm/preproc.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h output/outlib.h x86/insnsi.h x86/regs.h
output/outaout.$(O): output/outaout.c asm/directiv.h asm/eval.h asm/pptok.h \
 asm/preproc.h asm/stdscan.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/raa.h include/saa.h include/strlist.h include/tables.h \
 output/outform.h output/outlib.h x86/insnsi.h x86/regs.h
output/outas86.$(O): output/outas86.c asm/directiv.h asm/pptok.h \
 asm/preproc.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/raa.h include/saa.h include/strlist.h include/tables.h \
 output/outform.h output/outlib.h x86/insnsi.h x86/regs.h
output/outbin.$(O): output/outbin.c asm/directiv.h asm/eval.h asm/pptok.h \
 asm/preproc.h asm/stdscan.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/labels.h \
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h \
 include/perfhash.h include/saa.h include/strlist.h include/tables.h \
 output/outform.h output/outlib.h x86/insnsi.h x86/regs.h
output/outcoff.$(O): output/outcoff.c asm/directiv.h asm/eval.h asm/pptok.h \
 asm/preproc.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/raa.h include/saa.h include/strlist.h include/tables.h \
 output/outform.h output/outlib.h output/pecoff.h x86/insnsi.h x86/regs.h
output/outdbg.$(O): output/outdbg.c asm/directiv.h asm/pptok.h asm/preproc.h \
 asm/tokens.h config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/error.h include/iflag.h include/insns.h \
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h \
 include/perfhash.h include/strlist.h include/tables.h output/outform.h \
 output/outlib.h x86/iflaggen.h x86/insnsi.h x86/regs.h
output/outelf.$(O): output/outelf.c asm/directiv.h asm/eval.h asm/pptok.h \
 asm/preproc.h asm/stdscan.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/raa.h include/rbtree.h include/saa.h include/strlist.h \
 include/tables.h include/ver.h output/dwarf.h output/elf.h output/outelf.h \
 output/outform.h output/outlib.h output/stabs.h x86/insnsi.h x86/regs.h
output/outform.$(O): output/outform.c asm/directiv.h asm/pptok.h \
 asm/preproc.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/nasm.h include/nasmint.h \
 include/nasmlib.h include/opflags.h include/perfhash.h include/strlist.h \
 include/tables.h output/outform.h x86/insnsi.h x86/regs.h
output/outieee.$(O): output/outieee.c asm/directiv.h asm/pptok.h \
 asm/preproc.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h include/ver.h output/outform.h \
 output/outlib.h x86/insnsi.h x86/regs.h
output/outlib.$(O): output/outlib.c asm/directiv.h asm/pptok.h asm/preproc.h \
 config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/error.h include/nasm.h include/nasmint.h \
 include/nasmlib.h include/opflags.h include/perfhash.h include/strlist.h \
 include/tables.h output/outlib.h x86/insnsi.h x86/regs.h
output/outmacho.$(O): output/outmacho.c asm/directiv.h asm/pptok.h \
 asm/preproc.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/labels.h \
 include/nasm.h include/nasmint.h include/nasmlib.h include/opflags.h \
 include/perfhash.h include/raa.h include/rbtree.h include/saa.h \
 include/strlist.h include/tables.h include/ver.h output/dwarf.h \
 output/outform.h output/outlib.h x86/insnsi.h x86/regs.h
output/outobj.$(O): output/outobj.c asm/directiv.h asm/eval.h asm/pptok.h \
 asm/preproc.h asm/stdscan.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h include/ver.h output/outform.h \
 output/outlib.h x86/insnsi.h x86/regs.h
output/outrdf2.$(O): output/outrdf2.c asm/directiv.h asm/pptok.h \
 asm/preproc.h config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/rdoff.h include/saa.h include/strlist.h include/tables.h \
 output/outform.h output/outlib.h x86/insnsi.h x86/regs.h
rdoff/collectn.$(O): rdoff/collectn.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h include/rdoff.h rdoff/collectn.h \
 rdoff/rdfutils.h
rdoff/hash.$(O): rdoff/hash.c config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/nasmint.h rdoff/hash.h
rdoff/ldrdf.$(O): rdoff/ldrdf.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h include/rdoff.h rdoff/collectn.h \
 rdoff/ldsegs.h rdoff/rdfutils.h rdoff/rdlib.h rdoff/segtab.h rdoff/symtab.h
rdoff/rdf2bin.$(O): rdoff/rdf2bin.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h include/rdoff.h rdoff/rdfload.h \
 rdoff/rdfutils.h
rdoff/rdfdump.$(O): rdoff/rdfdump.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h include/rdoff.h rdoff/rdfutils.h
rdoff/rdflib.$(O): rdoff/rdflib.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h include/rdoff.h rdoff/rdfutils.h
rdoff/rdfload.$(O): rdoff/rdfload.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h include/rdoff.h rdoff/collectn.h \
 rdoff/rdfload.h rdoff/rdfutils.h rdoff/symtab.h
rdoff/rdlar.$(O): rdoff/rdlar.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h \
 rdoff/rdlar.h
rdoff/rdlib.$(O): rdoff/rdlib.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h include/rdoff.h rdoff/rdfutils.h \
 rdoff/rdlar.h rdoff/rdlib.h
rdoff/rdoff.$(O): rdoff/rdoff.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h include/rdoff.h rdoff/rdfutils.h
rdoff/rdx.$(O): rdoff/rdx.c config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/error.h include/nasmint.h \
 include/nasmlib.h include/rdoff.h rdoff/rdfload.h rdoff/rdfutils.h \
 rdoff/symtab.h
rdoff/segtab.$(O): rdoff/segtab.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h include/rdoff.h rdoff/rdfutils.h \
 rdoff/segtab.h
rdoff/symtab.$(O): rdoff/symtab.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h include/rdoff.h rdoff/hash.h \
 rdoff/rdfutils.h rdoff/symtab.h
stdlib/snprintf.$(O): stdlib/snprintf.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h \
 include/nasmlib.h
stdlib/strlcpy.$(O): stdlib/strlcpy.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h
stdlib/strnlen.$(O): stdlib/strnlen.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h
stdlib/vsnprintf.$(O): stdlib/vsnprintf.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/error.h \
 include/nasmint.h include/nasmlib.h
x86/disp8.$(O): x86/disp8.c asm/directiv.h asm/pptok.h asm/preproc.h \
 config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/disp8.h include/nasm.h include/nasmint.h \
 include/nasmlib.h include/opflags.h include/perfhash.h include/strlist.h \
 include/tables.h x86/insnsi.h x86/regs.h
x86/iflag.$(O): x86/iflag.c config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/iflag.h include/nasmint.h \
 x86/iflaggen.h
x86/insnsa.$(O): x86/insnsa.c asm/directiv.h asm/pptok.h asm/preproc.h \
 asm/tokens.h config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/iflag.h include/insns.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h x86/iflaggen.h x86/insnsi.h x86/regs.h
x86/insnsb.$(O): x86/insnsb.c asm/directiv.h asm/pptok.h asm/preproc.h \
 asm/tokens.h config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/iflag.h include/insns.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h x86/iflaggen.h x86/insnsi.h x86/regs.h
x86/insnsd.$(O): x86/insnsd.c asm/directiv.h asm/pptok.h asm/preproc.h \
 asm/tokens.h config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/iflag.h include/insns.h include/nasm.h \
 include/nasmint.h include/nasmlib.h include/opflags.h include/perfhash.h \
 include/strlist.h include/tables.h x86/iflaggen.h x86/insnsi.h x86/regs.h
x86/insnsn.$(O): x86/insnsn.c config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/nasmint.h include/tables.h \
 x86/insnsi.h
x86/regdis.$(O): x86/regdis.c x86/regdis.h x86/regs.h
x86/regflags.$(O): x86/regflags.c asm/directiv.h asm/pptok.h asm/preproc.h \
 config/config.h config/msvc.h config/unknown.h config/watcom.h \
 include/compiler.h include/nasm.h include/nasmint.h include/nasmlib.h \
 include/opflags.h include/perfhash.h include/strlist.h include/tables.h \
 x86/insnsi.h x86/regs.h
x86/regs.$(O): x86/regs.c config/config.h config/msvc.h config/unknown.h \
 config/watcom.h include/compiler.h include/nasmint.h include/tables.h \
 x86/insnsi.h
x86/regvals.$(O): x86/regvals.c config/config.h config/msvc.h \
 config/unknown.h config/watcom.h include/compiler.h include/nasmint.h \
 include/tables.h x86/insnsi.h
