/*
   +----------------------------------------------------------------------+
   | unknown license:                                                      |
   +----------------------------------------------------------------------+
   | Authors: Unknown User <unknown@example.com>                          |
   +----------------------------------------------------------------------+
*/

/* $ Id: $ */ 

#ifndef PHP_ROOJSPACKER_H
#define PHP_ROOJSPACKER_H

#ifdef  __cplusplus
extern "C" {
#endif

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <php.h>

#ifdef HAVE_ROOJSPACKER
#define PHP_ROOJSPACKER_VERSION "0.0.1dev"


#include <php_ini.h>
#include <SAPI.h>
#include <ext/standard/info.h>
#include <Zend/zend_extensions.h>
#ifdef  __cplusplus
} // extern "C" 
#endif
#include <roojspacker/roojspacker-1.0.h>
#ifdef  __cplusplus
extern "C" {
#endif

extern zend_module_entry roojspacker_module_entry;
#define phpext_roojspacker_ptr &roojspacker_module_entry

#ifdef PHP_WIN32
#define PHP_ROOJSPACKER_API __declspec(dllexport)
#else
#define PHP_ROOJSPACKER_API
#endif

PHP_MINIT_FUNCTION(roojspacker);
PHP_MSHUTDOWN_FUNCTION(roojspacker);
PHP_RINIT_FUNCTION(roojspacker);
PHP_RSHUTDOWN_FUNCTION(roojspacker);
PHP_MINFO_FUNCTION(roojspacker);

#ifdef ZTS
#include "TSRM.h"
#endif

#define FREE_RESOURCE(resource) zend_list_delete(Z_LVAL_P(resource))

#define PROP_GET_LONG(name)    Z_LVAL_P(zend_read_property(_this_ce, _this_zval, #name, strlen(#name), 1 TSRMLS_CC))
#define PROP_SET_LONG(name, l) zend_update_property_long(_this_ce, _this_zval, #name, strlen(#name), l TSRMLS_CC)

#define PROP_GET_DOUBLE(name)    Z_DVAL_P(zend_read_property(_this_ce, _this_zval, #name, strlen(#name), 1 TSRMLS_CC))
#define PROP_SET_DOUBLE(name, d) zend_update_property_double(_this_ce, _this_zval, #name, strlen(#name), d TSRMLS_CC)

#define PROP_GET_STRING(name)    Z_STRVAL_P(zend_read_property(_this_ce, _this_zval, #name, strlen(#name), 1 TSRMLS_CC))
#define PROP_GET_STRLEN(name)    Z_STRLEN_P(zend_read_property(_this_ce, _this_zval, #name, strlen(#name), 1 TSRMLS_CC))
#define PROP_SET_STRING(name, s) zend_update_property_string(_this_ce, _this_zval, #name, strlen(#name), s TSRMLS_CC)
#define PROP_SET_STRINGL(name, s, l) zend_update_property_stringl(_this_ce, _this_zval, #name, strlen(#name), s, l TSRMLS_CC)



typedef struct _php_obj_roojspacker {
    zend_object obj;
    JSDOCPacker *data;
} php_obj_roojspacker; 
PHP_METHOD(roojspacker, loadFile);
#if (PHP_MAJOR_VERSION >= 5)
ZEND_BEGIN_ARG_INFO_EX(roojspacker__loadFile_args, ZEND_SEND_BY_VAL, ZEND_RETURN_VALUE, 1)
  ZEND_ARG_INFO(0, file)
ZEND_END_ARG_INFO()
#else /* PHP 4.x */
#define roojspacker__loadFile_args NULL
#endif

PHP_METHOD(roojspacker, pack);
#if (PHP_MAJOR_VERSION >= 5)
ZEND_BEGIN_ARG_INFO_EX(roojspacker__pack_args, ZEND_SEND_BY_VAL, ZEND_RETURN_VALUE, 2)
  ZEND_ARG_INFO(0, target)
  ZEND_ARG_INFO(0, debug_target)
ZEND_END_ARG_INFO()
#else /* PHP 4.x */
#define roojspacker__pack_args NULL
#endif

#ifdef  __cplusplus
} // extern "C" 
#endif

#endif /* PHP_HAVE_ROOJSPACKER */

#endif /* PHP_ROOJSPACKER_H */


/*
 * Local variables:
 * tab-width: 4
 * c-basic-offset: 4
 * End:
 * vim600: noet sw=4 ts=4 fdm=marker
 * vim<600: noet sw=4 ts=4
 */
