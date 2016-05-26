/*
   +----------------------------------------------------------------------+
   | unknown license:                                                      |
   +----------------------------------------------------------------------+
   | Authors: Unknown User <unknown@example.com>                          |
   +----------------------------------------------------------------------+
*/

/* $ Id: $ */ 

#include "php_roojspacker.h"

#if HAVE_ROOJSPACKER

/* {{{ Class definitions */

/* {{{ Class roojspacker */

static zend_class_entry * roojspacker_ce_ptr = NULL;

/* {{{ Methods */


/* {{{ proto void loadFile(string file)
   */
PHP_METHOD(roojspacker, loadFile)
{
	zend_class_entry * _this_ce;
	php_obj_roojspacker *payload;

	zval * _this_zval = NULL;
	const char * file = NULL;
	int file_len = 0;



	if (zend_parse_method_parameters(ZEND_NUM_ARGS() TSRMLS_CC, getThis(), "Os", &_this_zval, roojspacker_ce_ptr, &file, &file_len) == FAILURE) {
		return;
	}

	_this_ce = Z_OBJCE_P(_this_zval);

	payload = (php_obj_roojspacker *) zend_object_store_get_object(_this_zval TSRMLS_CC);

	do {
		jsdoc_packer_loadFile(payload->data , file);
	} while (0);
}
/* }}} loadFile */



/* {{{ proto string pack(string target, string debug_target)
   */
PHP_METHOD(roojspacker, pack)
{
	zend_class_entry * _this_ce;
	php_obj_roojspacker *payload;

	zval * _this_zval = NULL;
	const char * target = NULL;
	int target_len = 0;
	const char * debug_target = NULL;
	int debug_target_len = 0;



	if (zend_parse_method_parameters(ZEND_NUM_ARGS() TSRMLS_CC, getThis(), "Oss", &_this_zval, roojspacker_ce_ptr, &target, &target_len, &debug_target, &debug_target_len) == FAILURE) {
		return;
	}

	_this_ce = Z_OBJCE_P(_this_zval);

	payload = (php_obj_roojspacker *) zend_object_store_get_object(_this_zval TSRMLS_CC);

	do {
		GError *err = NULL;    
		gchar *buf = jsdoc_packer_pack(payload->data, target, debug_target, &err);
		if (err !=NULL) {
		 zend_throw_exception(zend_exception_get_default(TSRMLS_C), err->message, 0 TSRMLS_CC);
		 RETURN_FALSE;
		}
		
		RETURN_STRING(buf, 1);
	} while (0);
}
/* }}} pack */


static zend_function_entry roojspacker_methods[] = {
	PHP_ME(roojspacker, loadFile, roojspacker__loadFile_args, /**/ZEND_ACC_PUBLIC)
	PHP_ME(roojspacker, pack, roojspacker__pack_args, /**/ZEND_ACC_PUBLIC)
	{ NULL, NULL, NULL }
};

/* }}} Methods */


static zend_object_handlers roojspacker_obj_handlers;

static void roojspacker_obj_free(void *object TSRMLS_DC)
{
	php_obj_roojspacker *payload = (php_obj_roojspacker *)object;
	
	JSDOCPacker *data = payload->data;
	do {
		if (payload->data) g_object_unref(payload->data);
	} while (0);

	efree(object);
}

static zend_object_value roojspacker_obj_create(zend_class_entry *class_type TSRMLS_DC)
{
	php_obj_roojspacker *payload;
	zval         *tmp;
	zend_object_value retval;

	payload = (php_obj_roojspacker *)emalloc(sizeof(php_obj_roojspacker));
	memset(payload, 0, sizeof(php_obj_roojspacker));
	payload->obj.ce = class_type;
	do {
		payload->data = jsdoc_packer_new();
	} while (0);

	retval.handle = zend_objects_store_put(payload, NULL, (zend_objects_free_object_storage_t) roojspacker_obj_free, NULL TSRMLS_CC);
	retval.handlers = &roojspacker_obj_handlers;
	
	return retval;
}

static void class_init_roojspacker(void)
{
	zend_class_entry ce;

	INIT_CLASS_ENTRY(ce, "roojspacker", roojspacker_methods);
	ce.create_object = roojspacker_obj_create;
	roojspacker_ce_ptr = zend_register_internal_class(&ce);
	memcpy(&roojspacker_obj_handlers, zend_get_std_object_handlers(), sizeof(zend_object_handlers));
	roojspacker_obj_handlers.clone_obj = NULL;
}

/* }}} Class roojspacker */

/* }}} Class definitions*/

/* {{{ roojspacker_functions[] */
zend_function_entry roojspacker_functions[] = {
	{ NULL, NULL, NULL }
};
/* }}} */


/* {{{ roojspacker_module_entry
 */
zend_module_entry roojspacker_module_entry = {
	STANDARD_MODULE_HEADER,
	"roojspacker",
	roojspacker_functions,
	PHP_MINIT(roojspacker),     /* Replace with NULL if there is nothing to do at php startup   */ 
	PHP_MSHUTDOWN(roojspacker), /* Replace with NULL if there is nothing to do at php shutdown  */
	PHP_RINIT(roojspacker),     /* Replace with NULL if there is nothing to do at request start */
	PHP_RSHUTDOWN(roojspacker), /* Replace with NULL if there is nothing to do at request end   */
	PHP_MINFO(roojspacker),
	PHP_ROOJSPACKER_VERSION, 
	STANDARD_MODULE_PROPERTIES
};
/* }}} */

#ifdef COMPILE_DL_ROOJSPACKER
ZEND_GET_MODULE(roojspacker)
#endif


/* {{{ PHP_MINIT_FUNCTION */
PHP_MINIT_FUNCTION(roojspacker)
{
	class_init_roojspacker();

	/* add your stuff here */

	return SUCCESS;
}
/* }}} */


/* {{{ PHP_MSHUTDOWN_FUNCTION */
PHP_MSHUTDOWN_FUNCTION(roojspacker)
{

	/* add your stuff here */

	return SUCCESS;
}
/* }}} */


/* {{{ PHP_RINIT_FUNCTION */
PHP_RINIT_FUNCTION(roojspacker)
{
	/* add your stuff here */

	return SUCCESS;
}
/* }}} */


/* {{{ PHP_RSHUTDOWN_FUNCTION */
PHP_RSHUTDOWN_FUNCTION(roojspacker)
{
	/* add your stuff here */

	return SUCCESS;
}
/* }}} */


/* {{{ PHP_MINFO_FUNCTION */
PHP_MINFO_FUNCTION(roojspacker)
{
	php_printf("The unknown extension\n");
	php_info_print_table_start();
	php_info_print_table_row(2, "Version",PHP_ROOJSPACKER_VERSION " (devel)");
	php_info_print_table_row(2, "Released", "2016-05-26");
	php_info_print_table_row(2, "CVS Revision", "$Id: $");
	php_info_print_table_row(2, "Authors", "Unknown User 'unknown@example.com' (lead)\n");
	php_info_print_table_end();
	/* add your stuff here */

}
/* }}} */

#endif /* HAVE_ROOJSPACKER */


/*
 * Local variables:
 * tab-width: 4
 * c-basic-offset: 4
 * End:
 * vim600: noet sw=4 ts=4 fdm=marker
 * vim<600: noet sw=4 ts=4
 */
