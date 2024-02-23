project('roojspacker', 'vala', 'c',
  version: '1.5',
  license: 'LGPL',
  default_options: [
    'default_library=static',
    'c_std=gnu11'       # for C subprojects
  ]
)
gnome = import('gnome')

valac = meson.get_compiler('vala')

extra_vala_sources = []



deps = [
   dependency('gobject-2.0'),
   dependency('gio-2.0'),
   dependency('gio-unix-2.0'),
   dependency('gee-0.8'),
   dependency('json-glib-1.0'),
   valac.find_library('posix'),

]
 
# let Vala add the appropriate defines for GLIB_X_X
add_project_arguments(['--target-glib=auto'], language: 'vala')

 

conf = configuration_data()
conf.set('PROJECT_NAME', meson.project_name())









roojspacker_src = files([
   'roojspacker/Collapse.vala',
   'roojspacker/CompressWhite.vala',
   'roojspacker/DocBuilder.vala',
   'roojspacker/DocComment.vala',
   'roojspacker/DocParser.vala',
   'bin/main.vala',
   'roojspacker/DocTag.vala',
   'roojspacker/Identifier.vala',
   'roojspacker/Lang.vala',
   'roojspacker/PackerRun.vala',
   'roojspacker/Packer.vala',
   'roojspacker/PrettyPrint.vala',
   'roojspacker/ScopeParser.vala',
   'roojspacker/Scope.vala',
   'roojspacker/SymbolSet.vala',
   'roojspacker/Symbol.vala',
   'roojspacker/TextStream.vala',
   'roojspacker/TokenReader.vala',
   'roojspacker/TokenStream.vala',
   'roojspacker/Token.vala',
   'roojspacker/Walker.vala',
])


roojspacker = executable('roojspacker',
    dependencies: deps,
    sources: [  roojspacker_src  ],
    install: true
)
roojspack_src = files([
   'roojspacker/Collapse.vala',
   'roojspacker/CompressWhite.vala',
   'roojspacker/DocBuilder.vala',
   'roojspacker/DocComment.vala',
   'roojspacker/DocParser.vala',
   'roojspacker/DocTag.vala',
   'roojspacker/Identifier.vala',
   'roojspacker/Lang.vala',
   'roojspacker/PackerRun.vala',
   'roojspacker/Packer.vala',
   'roojspacker/PrettyPrint.vala',
   'roojspacker/ScopeParser.vala',
   'roojspacker/Scope.vala',
   'roojspacker/SymbolSet.vala',
   'roojspacker/Symbol.vala',
   'roojspacker/TextStream.vala',
   'roojspacker/TokenReader.vala',
   'roojspacker/TokenStream.vala',
   'roojspacker/Token.vala',
   'roojspacker/Walker.vala',
])


roojspack_lib = shared_library('roojspack',  
    sources : [ roojspack_src  ],
    vala_vapi: 'roojspack-1.5.vapi',
    dependencies: deps,
    install: true,
    install_dir: [true, true, true]
)
pkg = import('pkgconfig')
pkg.generate( roojspack_lib,
    filebase: 'roojspack-1.5',
    requires : ['gobject-2.0','gio-2.0','gio-unix-2.0','gee-0.8','json-glib-1.0']
)


