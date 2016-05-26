dnl
dnl $ Id: $
dnl

PHP_ARG_WITH(roojspacker-1.0, whether roojspacker is available,[  --with-roojspacker[=DIR] With roojspacker support])


if test "$PHP_ROOJSPACKER" != "no"; then

  if test -z "$PKG_CONFIG"
  then
	AC_PATH_PROG(PKG_CONFIG, pkg-config, no)
  fi
  if test "$PKG_CONFIG" = "no"
  then
	AC_MSG_ERROR([required utility 'pkg-config' not found])
  fi

  if ! $PKG_CONFIG --exists roojspacker-1.0
  then
	AC_MSG_ERROR(['roojspacker-1.0' not known to pkg-config])
  fi

  PHP_EVAL_INCLINE(`$PKG_CONFIG --cflags-only-I roojspacker-1.0`)
  PHP_EVAL_LIBLINE(`$PKG_CONFIG --libs roojspacker-1.0`, ROOJSPACKER_SHARED_LIBADD)

  export OLD_CPPFLAGS="$CPPFLAGS"
  export CPPFLAGS="$CPPFLAGS $INCLUDES -DHAVE_ROOJSPACKER"
  AC_CHECK_HEADER([roojspacker/roojspacker-1.0.h], [], AC_MSG_ERROR('roojspacker/roojspacker-1.0.h' header not found))
  export CPPFLAGS="$OLD_CPPFLAGS"

  export OLD_CPPFLAGS="$CPPFLAGS"
  export CPPFLAGS="$CPPFLAGS $INCLUDES -DHAVE_ROOJSPACKER"

  AC_MSG_CHECKING(PHP version)
  AC_TRY_COMPILE([#include <php_version.h>], [
#if PHP_VERSION_ID < 50000
#error  this extension requires at least PHP version 5.0.0
#endif
],
[AC_MSG_RESULT(ok)],
[AC_MSG_ERROR([need at least PHP 5.0.0])])

  export CPPFLAGS="$OLD_CPPFLAGS"


  PHP_SUBST(ROOJSPACKER_SHARED_LIBADD)
  AC_DEFINE(HAVE_ROOJSPACKER, 1, [ ])

  PHP_NEW_EXTENSION(roojspacker, roojspacker.c , $ext_shared)

fi

