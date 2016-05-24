
 
 
# - not sure if needed....  
 

AM_CPPFLAGS =  \
    $(ROOJSPACKER_CFLAGS)  \
    -DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
    -DPACKAGE_DATA_DIR=\""$(datadir)"\" 


bin_PROGRAMS = roojspacker
lib_LTLIBRARIES = libroojspacker.la

 
roojspacker_PKGS = \
		--pkg glib-2.0  \
		--pkg gobject-2.0  \
		--pkg gee-1.0 \
		--pkg posix \
		--pkg gio-2.0 


libroojspacker_la_SOURCES = \
		jsdoc/Collapse.vala \
		jsdoc/CompressWhite.vala \
		jsdoc/Identifier.vala \
		jsdoc/Lang.vala \
		jsdoc/PackerRun.vala \
		jsdoc/Packer.vala \
		jsdoc/ScopeParser.vala \
		jsdoc/Scope.vala \
		jsdoc/TextStream.vala \
		jsdoc/TokenReader.vala \
		jsdoc/TokenStream.vala \
		jsdoc/Token.vala


 
roojspacker_VALAFLAGS = \
	 --thread -X -lm --target-glib=2.32 --vapidir=$(srcdir)/vapi -g  $(roojspacker_PKGS)



roojspacker_LDADD =  $(ROOJSPACKER_LIBS)

 

CLEANFILES = *.h *.c *.vapi *.stamp
