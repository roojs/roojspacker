
/** 
  the application
  -- in theory this code  can be used as a library... but this is the standard command line version...
  
  
  valac  --vapidir=/usr/share/vala/vapi 
     --vapidir=/usr/share/vala/vapi 
    --vapidir=/usr/share/vala-0.30/vapi 
        --thread  -g  
      JSDOC/Lang.vala JSDOC/TextStream.vala JSDOC/TokenReader.vala JSDOC/Token.vala JSDOC/TokenStream.vala JSDOC/Packer.vala 
      JSDOC/Collapse.vala JSDOC/ScopeParser.vala JSDOC/Scope.vala JSDOC/Identifier.vala JSDOC/CompressWhite.vala 
       JSDOC/PackerRun.vala --pkg glib-2.0 --pkg gee-1.0 --pkg gio-2.0 --pkg posix -o /tmp/jspack --target-glib=2.32  -X -lm

  
*/

namespace JSDOC
{
	// --------------- <<<<<<< <MAIN HERE....
	

	class PackerRun : Application  
	{
		public static string opt_target = null;
		public static string opt_debug_target = null;
		public static string opt_tmpdir = null;
		public static string opt_basedir = null;
				
		[CCode (array_length = false, array_null_terminated = true)]
		private static string[]? opt_files = null;
		[CCode (array_length = false, array_null_terminated = true)]
		private static string[]? opt_files_from = null;
		public static bool opt_debug = false;

		public static bool opt_keep_whitespace = false;	

		
		const OptionEntry[] options = {
		
			{ "jsfile", 'f', 0, OptionArg.FILENAME_ARRAY, ref opt_files ,"add a file to compile", null },
			{ "target", 't', 0, OptionArg.STRING, ref opt_target, "Target File to write (eg. roojs.js)", null },
			{ "debug-target", 'T', 0, OptionArg.STRING, ref opt_debug_target, "Target File to write debug code (eg. roojs-debug.js)", null },
			{ "tmpdir", 'm', 0, OptionArg.STRING, ref opt_tmpdir, "Temporary Directory to use (defaults to /tmp)", null },
			{ "basedir", 'b', 0, OptionArg.STRING, ref opt_basedir, "Base directory (where the files listed in index files are located.)", null },

			{ "index-files", 'i', 0, OptionArg.FILENAME_ARRAY, ref opt_files_from ,"files that contain listing of files to compile", null },		 
			{ "keep-whitespace", 'w', 0, OptionArg.NONE, ref opt_keep_whitespace, "Keep whitespace", null },
			{ "debug", 0, 0, OptionArg.NONE, ref opt_debug, "Show debug messages", null },
			// fixme -- keepwhite.. cleanup 
			
			{ null }
		};
		public static int main(string[] args) 
		{
			foreach(var a in args) {
				debug("ARG: %s\n", a);
			}
			
			var opt_context = new OptionContext ("JSDOC Packer");
			
				try {
					opt_context.set_help_enabled (true);
					opt_context.add_main_entries (options, null);
					if (!opt_context.parse ( ref args)) {
						print("options parse error");
						GLib.Process.exit(Posix.EXIT_FAILURE);
					}

				
					 
				
				} catch (OptionError e) {
					stdout.printf ("error: %s\n", e.message);
					stdout.printf ("Run '%s --help' to see a full list of available command line options.\n %s", 
								 args[0], opt_context.get_help(true,null));
					GLib.Process.exit(Posix.EXIT_FAILURE);
					 
				}
		
			new PackerRun(args);
			return 0;
		}


	
		public PackerRun (string[] args)
		{
		
			Object(
			    application_id: "org.roojs.jsdoc.packerrun",
				flags: ApplicationFlags.HANDLES_COMMAND_LINE 
			);
					 
			 
			
			// what's required...
			if (opt_debug) {
				GLib.Log.set_handler(null, 
					GLib.LogLevelFlags.LEVEL_DEBUG | GLib.LogLevelFlags.LEVEL_WARNING, 
					(dom, lvl, msg) => {
					print("%s: %s\n", dom, msg);
				});
			}
			
			// now run the Packer...
			var p = new Packer(
					opt_target == null ? "" : opt_target ,
					opt_debug_target == null ? "" :  opt_debug_target 
				);
			p.keepWhite = opt_keep_whitespace;
			
			// set the base directory...
			var curdir = Environment.get_current_dir() + Path.DIR_SEPARATOR_S;
			if (opt_basedir == null) {
				p.baseDir = curdir;
			} else if (opt_basedir[0] == '/') {	
				p.baseDir = opt_basedir;
			} else {
				p.baseDir = curdir + opt_basedir;
			}
			// suffix a slash..
			if (p.baseDir[p.baseDir.length-1].to_string() != Path.DIR_SEPARATOR_S) {
				p.baseDir += Path.DIR_SEPARATOR_S;
			}
			
			print("BaseDir = '%s' : opt_basedir ='%s'\n", p.baseDir, opt_basedir);
			
			
			if (opt_files == null && opt_files_from == null) {
				GLib.error("You must list some files with -f or -i to compile - see --help for more details");
				GLib.Process.exit(1);
			}
			
			
			if (opt_files != null) {
			 
				foreach (var  f in opt_files) {
					GLib.debug("Adding File %s", f);
					p.loadFile(f);
				}
			}  
			if (opt_files_from != null) {
			 
				foreach (var  f in opt_files_from) {
					GLib.debug("Adding File %s", f);
					p.loadSourceIndex(f);
				}
			}  
			
			
			
			p.pack();
		}	 
		
	}
	
}