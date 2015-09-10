# Copyright 2009, UCAR/Unidata and OPeNDAP, Inc.
# See the COPYRIGHT file for more information.

AUTOMAKE_OPTIONS = foreign
ACLOCAL_AMFLAGS = -I conf

AM_CPPFLAGS = -I$(top_srcdir)/inc

lib_LTLIBRARIES = libs3.la
libs3_la_CPPFLAGS = ${AM_CPPFLAGS}
libs3_la_LDFLAGS = -no-undefined

libs3_la_SOURCES =\
acl.c \
bucket.c \
error_parser.c \
general.c \
multipart.c \
object.c \
request.c \
request_context.c \
response_headers_handler.c \
s3.c \
service.c \
service_access_logging.c \
simplexml.c \
util.c

#mingw_functions.c mingw_s3_functions.c 

CLEANFILES = 
MAINTAINERCLEANFILES = Makefile.in

EXTRA_DIST = 
