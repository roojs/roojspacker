
/** 

  THIS IS THE ENTRY POINT...

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

JSDOC.PackerRun _PackerRun;

namespace JSDOC
{
	// --------------- <<<<<<< <MAIN HERE....
	
#if HAVE_OLD_GLIB
	public class PackerRun : Object 
#else
	public class PackerRun : Application  	
#endif
	{
		public  string opt_target = null;
		public string opt_debug_target = null;
//		public  string opt_tmpdir = null;
		private  string opt_basedir = null;
		
		/**
		* @cfg baseDir -- prefix the files listed in indexfiles with this.
		*/
		 
		public  string opt_real_basedir = null; // USE this one it's calcuated based on current path..
		
		public  string opt_doc_target = null;
		public  string opt_doc_template_dir = null;
		public  bool opt_doc_include_private = false;		
				
		[CCode (array_length = false, array_null_terminated = true)]
		private string[]? opt_files = null;
		[CCode (array_length = false, array_null_terminated = true)]
		private  string[]? opt_files_from = null;
		 
		
		public  bool opt_debug = false;
		
		 /**
		 * @cfg {Boolean} opt_skip_scope (optional) skip Scope parsing and replacement.
		 *    usefull for debugging...
		 */
		public  bool opt_skip_scope = false;
		
		/**
		 * @cfg {Boolean} opt_keep_whitespace (optional) do not remove white space in output.
		 *    usefull for debugging compressed files.
		 */
		
		public  bool opt_keep_whitespace = false;	
		
			/**
		 * @cfg {Boolean} opt_dump_tokens (optional) read the first file and dump the tokens.
		 *    usefull for debugging...
		 */
		
		public  bool opt_dump_tokens = false;	
		
		   
		/**
		 * @cfg {Boolean} opt_clean_cache  (optional) clean up temp files after done - 
		 *    Defaults to false if you set tmpDir, otherwise true.
		 */
		
		public  bool opt_clean_cache = true;	
		
		// not actually an option yet..
		
		public  string opt_doc_ext = "html";
		
		public static PackerRun singleton()
		{
			if (_PackerRun == null) {
				_PackerRun = new PackerRun();
			}
			return _PackerRun;
		}
  
		public PackerRun ()
		{
#if !HAVE_OLD_GLIB		
			Object(
			    application_id: "org.roojs.jsdoc.packerrun",
				flags: ApplicationFlags.HANDLES_COMMAND_LINE 
			);
#endif		
			

		}
		
		
		public void parseArgs(string[] args)
		{
			GLib.OptionEntry[] options 	 = {
				OptionEntry() {
					long_name = "jsfile",
					short_name = 'f',
					flags = 0,
					arg =  OptionArg.FILENAME_ARRAY,
					arg_data = &opt_files,
					description = "add a file to compile",
					arg_description = null
				},
				OptionEntry() {
					long_name = "target",
					short_name = 't',
					flags = 0,
					arg =  OptionArg.STRING,
					arg_data = &opt_target,
					description = "Target File to write (eg. roojs.js)",
					arg_description = null
				},
				OptionEntry() {
					long_name = "debug-target",
					short_name = 'T',
					flags = 0,
					arg =  OptionArg.STRING,
					arg_data = &opt_debug_target,
					description = "Target File to write debug code (eg. roojs-debug.js)",
					arg_description = null
				},
				//{ "tmpdir", 'm', 0, OptionArg.STRING, ref opt_tmpdir, "Temporary Directory to use (defaults to /tmp)", null },
				/*
				OptionEntry() {
					long_name = "tmpdir",
					short_name = 'm',
					flags = 0,
					arg =  OptionArg.STRING,
					arg_data = &opt_tmpdir,
					description = "Temporary Directory - used by documentation tool?",
					arg_description = null
				}, 
				*/

				OptionEntry() {
					long_name = "basedir",
					short_name = 'b',
					flags = 0,
					arg =  OptionArg.STRING,
					arg_data = &opt_basedir,
					description = "Base directory (where the files listed in index files are located.)",
					arg_description = null
				}, 

				OptionEntry() {
					long_name = "index-files",
					short_name = 'i',
					flags = 0,
					arg =  OptionArg.FILENAME_ARRAY,
					arg_data = &opt_files_from,
					description = "files that contain listing of files to compile",
					arg_description = null
				}, 

				OptionEntry() {
					long_name = "keep-whitespace",
					short_name = 'w',
					flags = 0,
					arg =  OptionArg.NONE,
					arg_data = &opt_keep_whitespace,
					description = "Keep whitespace",
					arg_description = null
				}, 
			 
				OptionEntry() {
					long_name = "skip-scope",
					short_name = 's',
					flags = 0,
					arg =  OptionArg.NONE,
					arg_data = &opt_skip_scope,
					description = "Skip scope parsing and variable replacement",
					arg_description = null
				}, 
				OptionEntry() {
					long_name = "debug",
					short_name = 'D',
					flags = 0,
					arg =  OptionArg.NONE,
					arg_data = &opt_debug,
					description = "Show debug messages",
					arg_description = null
				}, 

				OptionEntry() {
					long_name = "dump-tokens",
					short_name = 'k',
					flags = 0,
					arg =  OptionArg.NONE,
					arg_data = &opt_dump_tokens,
					description = "Dump the tokens from a file",
					arg_description = null
				}, 

				OptionEntry() {
					long_name = "clean-cache",
					short_name = 'c',
					flags = 0,
					arg =  OptionArg.NONE,
					arg_data = &opt_clean_cache,
					description = "Clean up the cache after running (slower)",
					arg_description = null
				}, 


			// fixme -- keepwhite.. cleanup 
			
			// documentation options
			// usage: roojspacker --basedir roojs1 \
			//       --doc-target roojs1/docs \
			//       --index-files roojs1/buildSDK/dependancy_core.txt  \
			//       --index-files roojs1/buildSDK/dependancy_ui.txt  \
			//       --index-files roojs1/buildSDK/dependancy_bootstrap.txt  \
			//       --doc-template-dir \
			
				OptionEntry() {
					long_name = "doc-target",
					short_name = 'd',
					flags = 0,
					arg =  OptionArg.STRING,
					arg_data = &opt_doc_target,
					description = "Target location for documentation",
					arg_description = null
				}, 

				OptionEntry() {
					long_name = "doc-template-dir",
					short_name = 'p',
					flags = 0,
					arg =  OptionArg.STRING,
					arg_data = &opt_doc_template_dir,
					description = "Template directory for documentation",
					arg_description = null
				}, 			


				OptionEntry() {
					long_name = "doc-private",
					short_name = 'P',
					flags = 0,
					arg =  OptionArg.NONE,
					arg_data = &opt_doc_include_private,
					description = "Document Private functions",
					arg_description = null
				}
			};
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
			
		  			 
			 
		}
		public void  runPack()
		{	
			// what's required...
			if (opt_debug) {
				GLib.Log.set_handler(null, 
					GLib.LogLevelFlags.LEVEL_DEBUG | GLib.LogLevelFlags.LEVEL_WARNING, 
					(dom, lvl, msg) => {
					print("%s: %s\n", dom, msg);
				});
			}
			
			 
  
			 
			// set the base directory...
			var curdir = Environment.get_current_dir() + Path.DIR_SEPARATOR_S;
			if (opt_basedir == null) {

				opt_real_basedir = curdir;
			} else if (opt_basedir[0] == '/') {	
				opt_real_basedir  = opt_basedir;
			} else {
				opt_real_basedir  = curdir + opt_basedir;
			}
			// suffix a slash..
			if (opt_real_basedir [opt_real_basedir .length-1].to_string() != Path.DIR_SEPARATOR_S) {
				opt_real_basedir  += Path.DIR_SEPARATOR_S;
			}
			
			GLib.debug("real_base_dir  = '%s' : opt_basedir ='%s'\n", opt_real_basedir , opt_basedir);
			
			
			if (opt_files == null && opt_files_from == null) {
				GLib.error("You must list some files with -f or -i to compile - see --help for more details");
				GLib.Process.exit(1);
			}
			
			
				// initialize the Packer (does not parse anything..)
			var p = new Packer(	this );
			
			
			if (opt_files != null) {
			 
				foreach (var  f in opt_files) {
					GLib.debug("Adding File %s", f);
					p.loadFile(f);  // just adds to list of files to parse (no parsing yet..)
				}
			}  
			if (opt_files_from != null) {
			 
				foreach (var  f in opt_files_from) {
					GLib.debug("Adding File %s", f);
					p.loadSourceIndex(f);
				}
			}  
			
			var run_pack = false;
			if (opt_target != null || opt_debug_target != null || opt_dump_tokens) {
				// do the actual packing...
				p.pack(	opt_target == null ? "" : opt_target ,
						opt_debug_target == null ? "" :  opt_debug_target );
		        
		    	if (p.outstr.length > 0 ) {
					stdout.printf ("%s", p.outstr);
				}
				return;
	        }
	        if (opt_doc_target != null) {
				// remove trailing /
		        opt_doc_target = opt_doc_target.has_suffix("/") ? 
		        		opt_doc_target.substring(0, opt_doc_target.length-1) : opt_doc_target;
	    		var d = new JSDOC.DocBuilder(p);
	    		return;
	        } 
	        GLib.error("either select output target or doc output target");
	        
	        
	        
		}	 
		
	}
	
}