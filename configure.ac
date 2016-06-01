
dnl Process this file with autoconf to produce a configure script.
AC_PREREQ([2.68])

AC_INIT([roojspacker], [4.0.0])

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIRS([m4])

AM_INIT_AUTOMAKE([1.11 subdir-objects])
AM_MAINTAINER_MODE([enable])



AM_SILENT_RULES([yes])

AC_PROG_CC

AM_PROG_VALAC([0.16.0])

LT_PREREQ([2.2.6])
LT_INIT([disable-static])


AC_CHECK_LIB([m],[cos])

dnl GOBJECT_INTROSPECTION_CHECK([1.30.0])


dnl we need to check these exist, then it will generate a compile string for them.

PKG_CHECK_MODULES(ROOJSPACKER, [
		 glib-2.0 >= 2.28.0
		 gobject-2.0 >= 2.28.0
		 gee-1.0  
		 gio-2.0  >= 2.28.0
		 gthread-2.0
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


AC_OUTPUT([roojspacker-1.0.pc])
