
 
 
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
		jsdoc/Packer.vala \
		jsdoc/ScopeParser.vala \
		jsdoc/Scope.vala \
		jsdoc/TextStream.vala \
		jsdoc/TokenReader.vala \
		jsdoc/TokenStream.vala \
		jsdoc/Token.vala

libroojspacker_la_VALAFLAGS = \
    --library roojspacker -H roojspacker.h \
    -X -shared --thread -X -lm --target-glib=2.32 --vapidir=$(srcdir)/vapi -g  $(roojspacker_PKGS)



roojspacker_SOURCES=  jsdoc/PackerRun.vala
roojspacker_LDADD = libroojspacker.la $(ROOJSPACKER_LIBS)
roojspacker_VALAFLAGS =  --pkg roojspacker --thread -X -lm --target-glib=2.32   --vapidir=$(srcdir)  --vapidir=$(srcdir)/vapi -g  $(roojspacker_PKGS)

    
CLEANFILES = *.h *.c *.vapi *.stamp

dist_vapi_DATA = \
    roojspacker.vapi