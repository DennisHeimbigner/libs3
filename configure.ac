# -*- Autocuonf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.62)
AC_INIT(libs3, 1.0.0)

AC_CONFIG_HEADER([config.h])
AC_CONFIG_AUX_DIR(conf)

AM_INIT_AUTOMAKE
AC_CONFIG_MACRO_DIR([conf])
AC_CANONICAL_HOST
AC_SUBST(host)

AC_MSG_NOTICE([setting up libtool])
LT_PREREQ([2.2])
LT_INIT(win32-dll)

dnl library versionning: Update these when the interface changes. Generally,
dnl assume that the interface tracks the major and minor release numbers.

#LIBS3_VER_MAJOR = 2
#LIBS3_VER_MINOR = 0
#LIBS3_VER := $(LIBS3_VER_MAJOR).$(LIBS3_VER_MINOR)
AC_DEFINE([LIBS3_VER_MAJOR], ["2"], [Major Version])
AC_DEFINE([LIBS3_VER_MINOR], ["0"], [Minor Version])

# Checks for programs.
AC_PROG_CXX
AC_PROG_LIBTOOL
AC_PROG_MAKE_SET
AC_PROG_INSTALL

AC_CHECK_FUNCS([memset memmove strcasecmp strchr strrchr strdup strerror strtol access unlink mkstemp getpid strndup strncpy])

##################################################
# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([malloc.h memory.h stddef.h stdlib.h string.h strings.h unistd.h stdarg.h])

##################################################
# Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_HEADER_STDBOOL
AC_TYPE_LONG_LONG_INT
AC_TYPE_SIZE_T
AC_TYPE_OFF_T
AC_CHECK_TYPES([ssize_t, ptrdiff_t, uchar])
AC_C_CHAR_UNSIGNED
AC_C_BIGENDIAN
AC_CHECK_SIZEOF(long)
AC_CHECK_SIZEOF(size_t)
AC_CHECK_SIZEOF(off_t)
AC_CHECK_SIZEOF(void*)

##################################################
# Check for libcurl and libxml2

AC_CHECK_LIB([curl],[curl_easy_setopt])
AC_CHECK_LIB([xml2],[xmlInitializeDict])

##################################################
# ./configure options


##################################################
# Process the Makefile.am (and other) files
AC_CONFIG_FILES([Makefile inc/Makefile src/Makefile test/Makefile])
AC_OUTPUT

