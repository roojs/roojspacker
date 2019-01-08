
 
 
# - not sure if needed....  
 

AM_CPPFLAGS =  \
    $(ROOJSPACKER_CFLAGS)  \
    $(JSON_GBIB_CFLAGS)  \
    -DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
    -DPACKAGE_DATA_DIR=\""$(datadir)"\" 


bin_PROGRAMS = roojspacker
lib_LTLIBRARIES = libroojspacker-1.2.la


 
if HAVE_JSON_GLIB
roojspacker_JSON_GLIB_FLAGS = -D HAVE_JSON_GLIB
endif

if HAVE_OLD_GLIB
roojspacker_OLD_GLIB_FLAGS = -D HAVE_OLD_GLIB
endif

 
roojspacker_PKGS = \
		--pkg glib-2.0  \
		--pkg gobject-2.0  \
		--pkg gee-0.8 \
		--pkg posix \
		--pkg gio-2.0

if HAVE_JSON_GLIB
  roojspacker_PKGS += --pkg json-glib-1.0
endif


libroojspacker_1_2_la_SOURCES = \
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
		jsdoc/Token.vala \
		jsdoc/PackerRun.vala
		jsdoc/Walker.vala \
		jsdoc/SymbolSet.vala \
		jsdoc/DocBuilder.vala \
		jsdoc/DocComment.vala \
		jsdoc/DocParser.vala \
		jsdoc/DocTag.vala \
		jsdoc/PrettyPrint.vala \
		jsdoc/Symbol.vala

# not sure if -g is needed..???

libroojspacker_1_2_la_VALAFLAGS = \
    --library roojspacker-1.2 \
    -H roojspacker-1.2.h \
    --gir JSDOC-1.2.gir \
    -X -shared -X -lm \
    --thread \
    --target-glib=2.32 \
    --vapidir=$(srcdir)/vapi \
    -g  \
    $(roojspacker_PKGS) \
     $(roojspacker_OLD_GLIB_FLAGS)  $(roojspacker_JSON_GLIB_FLAGS)

libroojspacker_1_2_la_CFLAGS =    $(JSON_GLIB_CFLAGS) $(ROOJSPACKER_CFLAGS) 

roojspacker_SOURCES =  main.vala
roojspacker_LDADD = libroojspacker-1.2.la $(ROOJSPACKER_LIBS) $(JSON_GLIB_LIBS)
roojspacker_VALAFLAGS =  --pkg roojspacker-1.2 --thread -X -lm --target-glib=2.32   \
    --vapidir=$(srcdir)  --vapidir=$(srcdir)/vapi -g  $(roojspacker_PKGS) \
     $(roojspacker_OLD_GLIB_FLAGS) $(roojspacker_JSON_GLIB_FLAGS)
     
roojspacker_CFLAGS =    $(JSON_GLIB_CFLAGS) $(ROOJSPACKER_CFLAGS) 
    
CLEANFILES = *.h *.c *.vapi *.stamp *.gir

roojspackerincludedir = $(includedir)/roojspacker

roojspackerinclude_HEADERS = \
	roojspacker-1.2.h \
	$(NULL)



vapidir = $(datadir)/vala/vapi

dist_vapi_DATA = \
    roojspacker-1.2.vapi

 


# girdir = $(datadir)/gir-1.1
# gir_DATA =  JSDOC-1.1.gir
    
# typelibdir = $(libdir)/girepository-1.1
# typelib_DATA = JSDOC-1.1.typelib

# would be better to include INTROSPECTION_MAKEFILE - but I think it's problematic...
    
# JSDOC-1.1.typelib:
# 	g-ir-compiler \
#         --includedir=$(srcdir) \
# 		--shared-library=libroojspacker-1.1.so \
# 		--output=$(typelib_DATA) \
# 		$(gir_DATA)
    
    

