## This is a automake file, part of Unidata's netCDF package.
# Copyright 2010, see the COPYRIGHT file for more information.

# This automake file generates the Makefile to build the include
# directory.

EXTRA_DIST = badxml_01.xml goodxml_01.xml goodxml_02.xml goodxml_03.xml \
	     test.sh

AM_LDFLAGS = ${top_builddir}/src/libs3.la 
AM_CPPFLAGS = -I$(top_srcdir)/inc

check_PROGRAMS = testsimplexml
TESTS = testsimplexml test.sh

