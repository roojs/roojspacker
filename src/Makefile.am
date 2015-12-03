
 
 
# - not sure if needed....  
# did have  $(JAVASCRIPTCOREGTK_CFLAGS)
AM_CPPFLAGS =  $(ROOJSPACKER_CFLAGS) 


bin_PROGRAMS = roojspacker

 
roojspacker_PKGS = \
		--pkg glib-2.0  \
		--pkg gobject-2.0  \
		--pkg gee-1.0 \
		--pkg posix 


roojspacker_SOURCES = \
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
