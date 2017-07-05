public static int main(string[] args) 
{
	//foreach(var a in args) {
	//	debug("ARG: %s\n", a);
	//}
	
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

	var pr = new JSDOC.PackerRun(args);
	pr.run;
	
	return 0;
}