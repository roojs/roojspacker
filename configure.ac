
dnl Process this file with autoconf to produce a configure script.
AC_PREREQ([2.68])

AC_INIT([roojspacker], [4.0.0])

AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([1.11 subdir-objects])
AM_MAINTAINER_MODE([enable])

AM_SILENT_RULES([yes])

AC_PROG_CC

AM_PROG_VALAC([0.22.0])


AC_CHECK_LIB([m],[cos])

dnl we need to check these exist, then it will generate a compile string for them.

PKG_CHECK_MODULES(ROOJSPACKER, [
		 glib-2.0 >= 2.24.1
		 gobject-2.0 >= 2.24.1
		 gee-1.0 
 		
		  
])


dnl  -- javascriptcoregtk-4.0  ** might add this later -- verify compilation.


dnl PKG_CHECK_MODULES(JAVASCRIPTCOREGTK, [javascriptcoregtk-4.0],
dnl				[javascriptcoregtk_4_0_enabled=yes],
dnl				[javascriptcoregtk_4_0_enabled=no])
dnl
dnl if test $javascriptcoregtk_4_0_enabled = yes; then
dnl		AC_DEFINE(HAVE_JAVASCRIPTCOREGTK4,1,[javascriptcoregtk 4.0 support])
dnl else
dnl		PKG_CHECK_MODULES(JAVASCRIPTCOREGTK, [javascriptcoregtk-3.0],
dnl				[javascriptcoregtk_3_0_enabled=yes] )
dnl		AC_DEFINE(HAVE_JAVASCRIPTCOREGTK3,1,[javascriptcoregtk 3.0 support])
dnl	   
dnl
dnl fi
dnl AM_CONDITIONAL(HAVE_JAVASCRIPTCOREGTK3, test "$javascriptcoregtk_3_0_enabled" = "yes")
dnl AM_CONDITIONAL(HAVE_JAVASCRIPTCOREGTK4, test "$javascriptcoregtk_4_0_enabled" = "yes")

 
AC_CONFIG_FILES([
	Makefile
	src/Makefile
])

  
AC_SUBST(ROOJSPACKER_CFLAGS)
AC_SUBST(ROOJSPACKER_LIBS)


AC_OUTPUT
