 
/**
 * @namespace JSDOC
 * @class  Packer
 * Create a new packer
 * 
 * Use with pack.js 
 * 
 * 
 * Usage:
 * <code>
 *
 
var x = new  JSON.Packer(target, debugTarget);

x.files = an array of files
x.srcfiles = array of files (that list other files...) << not supported?
x.target = "output.pathname.js"
x.debugTarget = "output.pathname.debug.js"

  
    
x.pack();  // writes files  etc..
    
 *</code> 
 *
 * Notes for improving compacting:
 *  if you add a jsdoc comment 
 * <code>
 * /**
 *   eval:var:avarname
 *   eval:var:bvarname
 *   ....
 * </code>
 * directly before an eval statement, it will compress all the code around the eval, 
 * and not rename the variables 'avarname'
 * 
 * Dont try running this on a merged uncompressed large file - it's used to be horrifically slow. not sure about now..
 * Best to use lot's of small classes, and use it to merge, as it will cache the compaction
 * 
 * 
 * 
 * Notes for translation
 *  - translation relies on you using double quotes for strings if they need translating
 *  - single quoted strings are ignored.
 * 
 * Generation of indexFiles
 *   - translateIndex = the indexfile
 * 
 * 
 * 
 * 

 */
namespace JSDOC 
{
	public errordomain PackerError {
            ArgumentError
    }
    
    
	public class Packer : Object 
	{
		/**
		* @cfg {String} target to write files to - must be full path.
		*/
		string target = "";
		GLib.FileOutputStream targetStream = null;
		/**
		 * @cfg {String} debugTarget target to write files debug version to (uncompacted)- must be full path.
		 */
		string targetDebug = "";
		

		GLib.FileOutputStream targetDebugStream  = null;
		/**
		 * @cfg {String} tmpDir  (optional) where to put the temporary files. 
		 *      if you set this, then files will not be cleaned up
		 *  
		 *  at present we need tmpfiles - as we compile multiple files into one.
		 *  we could do this in memory now, as I suspect vala will not be as bad as javascript for leakage...
		 *
		 */
		//public string tmpDir = "/tmp";  // FIXME??? in ctor?
	
	 
		 
		// list of files to compile...
		public Gee.ArrayList<string> files;
		
		/**
		* @cfg activeFile ??? used???
		*/
		 
		public string activeFile = "";
		 	
		public  string outstr = ""; // if no target is specified - then this will contain the result
		
		public PackerRun config;
		
		public Packer(PackerRun config)
		{
			this.config = config;
//#if HAVE_JSON_GLIB
			this.result = new Json.Object();
//#else
//			this.result_count = new  Gee.HashMap <string,int>();
//		
//			this.result =  new Gee.HashMap<
//#				string /* errtype*/ , Gee.HashMap<string /*fn*/,     Gee.HashMap<int /*line*/, Gee.ArrayList<string>>>
//#			>();
//#endif			
//
			this.files = new Gee.ArrayList<string>();
			
			new Lang_Class(); ///initilizaze lang..
			
			//this.tmp = Glib.get_tmp_dir(); // do we have to delete this?
			
			 
		}
		
		
		// this could be another class really..
		
		public enum ResultType { 
			err , 
			warn;
			public string to_string() { 
				switch(this) {
					case err: return "ERR";
					case warn: return "WARN";
					default: assert_not_reached();
				}
			
			  }
		  }
		/**
		*  result of complication - a JSON object containing warnings / errors etc..
		*  FORMAT:
		*     warn-TOTAL : X  (number of warnings.
		*     err-TOTAL: X  (number of errors) << this indicates failure...
		*     warn : {
		*            FILENAME : {
		*                  line : [ Errors,Errors,.... ]
		*     err : {
		*           .. sane format..
		*
		*/
		
#if HAVE_JSON_GLIB
		
		public Json.Object result;   // output - what's the complication result

		public void  logError(ResultType type, string filename, int line, string message) {
			 
			 if (!this.result.has_member(type.to_string()+"-TOTAL")) {
				 this.result.set_int_member(type.to_string()+"-TOTAL", 1);
			 } else {
				this.result.set_int_member(type.to_string()+"-TOTAL", 
					this.result.get_int_member(type.to_string()+"-TOTAL") +1 
				);
			 }
			 
			 
			 if (!this.result.has_member(type.to_string())) {
				 this.result.set_object_member(type.to_string(), new Json.Object());
			 }
			 var t = this.result.get_object_member(type.to_string());
			 if (!t.has_member(filename)) {
				 t.set_object_member(filename, new Json.Object());
			 }
			 var tt = t.get_object_member(filename);
			 if (!tt.has_member(line.to_string())) {
				 tt.set_array_member(line.to_string(), new Json.Array());
			 }
			 var tl = tt.get_array_member(line.to_string());
			 tl.add_string_element(message);
			 
		}
		
		public bool hasErrors(string fn)
		{
			 if (!this.result.has_member(ResultType.err.to_string())) {
				 return false;
			 }
			 
			 if (fn.length < 1) {
				return true;
			 }
			 var t = this.result.get_object_member(ResultType.err.to_string());
			 
			 if (t.has_member(fn)) {
				 return true;
			 }
			 return false;
		}
		public void dumpErrors(ResultType type)
		{
			 if (!this.result.has_member(type.to_string())) {
				 return;
			 }
			var t = this.result.get_object_member(type.to_string());
			t.foreach_member((obj, filename, node) => {
					var linelist = node.dup_object();
					linelist.foreach_member((linelistobj, linestr, nodear) => {
						var errors=  nodear.dup_array();
						errors.foreach_element((errorar, ignore, nodestr) => {
							print("%s: %s:%s %s\n", type.to_string(), filename, linestr, nodestr.get_string());
						});
					});
			
			});
		}
#else
		public Gee.HashMap <string,int> result_count;   // output - what's the complication result
		
		public Gee.HashMap<
				string /* errtype*/ , Gee.HashMap<string /*fn*/,     Gee.HashMap<int /*line*/, Gee.ArrayList<string>>>
		> result;

		public void  logError(ResultType type, string filename, int line, string message) {
			 
			 
			 if (!this.result_count.has_key(type.to_string()+"-TOTAL")) {
				 this.result_count.set(type.to_string()+"-TOTAL", 1);
			 } else {
				this.result_count.set(type.to_string()+"-TOTAL", 				 
					this.result_count.get(type.to_string()+"-TOTAL") +1
				);
			 }
			 
			 
			 
			 if (!this.result.has_key(type.to_string())) {
				 this.result.set(type.to_string(),
					 new Gee.HashMap<string /*fn*/,     Gee.HashMap<int /*line*/, Gee.ArrayList<string>>>()
				 );
			 }
			 var t = this.result.get(type.to_string());
			 if (!t.has_key(filename)) {
				 t.set(filename, new  Gee.HashMap<int /*line*/, Gee.ArrayList<string>>());
			 }
			 var tt = t.get(filename);
			 if (!tt.has_key(line)) {
				 tt.set(line, new Gee.ArrayList<string>());
			 }
			 var tl = tt.get(line);
			 tl.add(message);
			 
		}
		
		public bool hasErrors(string fn)
		{
			 if (!this.result.has_key(ResultType.err.to_string())) {
				 return false;
			 }
			 
			 if (fn.length < 1) {
				return true;
			 }
			 var t = this.result.get(ResultType.err.to_string());
			 
			 if (t.has_key(fn)) {
				 return true;
			 }
			 return false;
		}
		public void dumpErrors(ResultType type)
		{
			 if (!this.result.has_key(type.to_string())) {
				 return;
			 }
			var t = this.result.get(type.to_string());
			foreach(string filename in t.keys) {
				var node = t.get(filename);
				foreach(int line in node.keys) {
					var errors = node.get(line);
					foreach(string errstr in errors) {
							print("%s: %s:%d %s\n", type.to_string(), filename, line, errstr);
					}
				}
			
			}
		}


#endif
		
		
		
		public void loadSourceIndexes(Gee.ArrayList<string> indexes)
		{
			foreach(var f in indexes) {
				this.loadSourceIndex(f);
			}
		}
		
		public void loadFiles(string[] fs)
		{
			// fixme -- prefix baseDir?
			foreach(var f in fs) {
			    GLib.debug("add File: %s", f);
				this.files.add(f); //?? easier way?
			}
		}
		public void loadFile(string f)
		{
		    // fixme -- prefix baseDir?
		    GLib.debug("add File: %s", f);
			this.files.add(f); 
			GLib.debug("FILE LEN: %d", this.files.size);
		}
		 
		
		public string pack(string target, string targetDebug = "") throws PackerError 
		{
		    this.target = target;
			this.targetDebug  = targetDebug;
		    
		    if (this.files.size < 1) {
				throw new PackerError.ArgumentError("No Files loaded before pack() called");
			}
			if (this.target.length > 0 ) {
				this.targetStream = File.new_for_path(this.target).replace(null, false,FileCreateFlags.NONE);
			}
			if (this.targetDebug.length > 0 ) {
				this.targetDebugStream = File.new_for_path(this.targetDebug).replace(null, false,FileCreateFlags.NONE);
			}
			return this.packAll();
		}
		
  
		 
 
	   
		/**
		 * load a dependancy list -f option
		 * @param {String} srcfile sourcefile to parse
		 * 
		 */
		
		public void loadSourceIndex(string in_srcfile)
		{
		    
		    var srcfile = in_srcfile;
		    if (srcfile[0] != '/') {
				srcfile = config.opt_real_basedir + in_srcfile;
			}
		    string str;
		    FileUtils.get_contents(srcfile,out str);
		    
		    var lines = str.split("\n");
		    for(var i =0; i < lines.length;i++) {
 
			    var f = lines[i].strip();
		        if (f.length < 1 ||
		    		Regex.match_simple ("^/", f) ||
		    		!Regex.match_simple ("[a-zA-Z]+", f) 
	    		){
	    			continue; // blank comment or not starting with a-z
		        }
		        
		        if (Regex.match_simple ("\\.js$", f)) {
		            this.files.add( f);
		            // js file..
		            continue;
		        }
		        
				// this maps Roo.bootstrap.XXX to Roo/bootstrap/xxx.js
				// should we prefix? =- or should this be done elsewhere?
				
		        var add = f.replace(".", "/") + ".js";
		        
		        if (add[0] != '/') {
					add = config.opt_real_basedir + add;
				}
		        
		        if (this.files.contains(add)) {
		            continue;
		        }
		        
		        
		        
		        this.files.add( add );
		        
		    }
		}
		
    
		private string packAll()   // do the packing (run from constructor)
		{
		    
		    //this.transOrigFile= bpath + '/../lang.en.js'; // needs better naming...
		    //File.write(this.transfile, "");
		    if (this.target.length > 0) {
		        this.targetStream.write("".data);
		    }
		    
		    if (this.targetDebugStream != null) {
			    this.targetDebugStream.write("".data);
		    }
		    
		    
		    var tmpDir = GLib.DirUtils.make_tmp("roojspacker_XXXXXX");
		    
		    foreach(var file in this.files) {
		        
		        print("reading %s\n",file );
		        
		        if (!FileUtils.test (file, FileTest.EXISTS) || FileUtils.test (file, FileTest.IS_DIR)) {
		            print("SKIP (is not a file) %s\n ", file);
		            continue;
		        }
		       
		   		var loaded_string = false;
		   		string file_contents = "";
		        // debug Target
		        
		        if (this.targetDebugStream !=null) {
		    		
		    		FileUtils.get_contents(file,out file_contents);
		            this.targetDebugStream.write(file_contents.data);
		            loaded_string = false;
		        }
		        // it's a good idea to check with 0 compression to see if the code can parse!!
		        
		        // debug file..
		        //File.append(dout, str +"\n"); 
		        
		   
		        
		        var minfile = tmpDir + "/" + file.replace("/", ".");
		        
		        
		        // let's see if we have a min file already?
		        // this might happen if tmpDir is set .. 

		        
		        if ( FileUtils.test (minfile, FileTest.EXISTS)) {
		    		 
		    		var otv = File.new_for_path(file).query_info (FileAttribute.TIME_MODIFIED, 0).get_modification_time();
		    		var mtv = File.new_for_path(minfile).query_info (FileAttribute.TIME_MODIFIED, 0).get_modification_time();
					
					 
		           // print("%s : compare : Cache file  %s to Orignal Time %s\n", file, mtv.to_iso8601(), otv.to_iso8601());
		            if (mtv.tv_usec > otv.tv_usec) {
		                continue; // file is newer or the same time..
		                
		            }
		            
		        }
		         
		        print("COMPRESSING to %s\n", minfile);
		        //var codeComp = pack(str, 10, 0, 0);
		        if (config.opt_clean_cache && FileUtils.test (minfile, FileTest.EXISTS)) {
		            FileUtils.remove(minfile);
		        }
		        if (!loaded_string) {
		    		FileUtils.get_contents(file,out file_contents);
	    		}

		         this.packFile(file_contents, file, minfile);
		         
		      
		    }
		    
		    // at this point if we have errors, we should stop..

					    
			this.dumpErrors(ResultType.warn);
			this.dumpErrors(ResultType.err); // since they are fatal - display them last...
			
			
			
			
  			if (config.opt_dump_tokens || this.hasErrors("")) {
				 
				GLib.Process.exit(0);
			}
		    print("MERGING SOURCE\n");
		    
		    for(var i=0; i < this.files.size; i++)  {
		        var file = this.files[i];
		        var minfile = tmpDir + "/" + file.replace("/", ".");
		        
		        
		        if ( !FileUtils.test(minfile, FileTest.EXISTS)) {
		    		print("skipping source %s - does not exist\n", minfile);
		            continue;
		        }
		        string str;
		        FileUtils.get_contents(minfile, out str);
		        print("using MIN FILE  %s\n", minfile);
		        if (str.length > 0) {
		            if (this.targetStream != null) {
		        		this.targetStream.write(("// " + 
		        			( (file.length > config.opt_real_basedir.length) ? file.substring(config.opt_real_basedir.length)  : file ) + 
						"\n").data); 

					this.targetStream.write((str + "\n").data); 

		            } else {
		                this.outstr += "//" + 
		        		( (file.length > config.opt_real_basedir.length) ? file.substring(config.opt_real_basedir.length)  : file ) +  "\n";
		                this.outstr += "//" +  file  +"\n";

				     this.outstr += str + "\n";
		            }
		            
		        }
		        if (config.opt_clean_cache) {
		            FileUtils.remove(minfile);
		        }
		        
		    }
		    if (config.opt_clean_cache) {
				FileUtils.remove(tmpDir);
			}
		    
		    if (this.target.length > 0 ) {
			    print("Output file: " + this.target);
		    }
		    if (this.targetDebug.length > 0) {
				 print("Output debug file: %s\n" , this.targetDebug);
			}
            

            
			// OUTPUT should be handled by PackerRun (so that this can be used as a library...)
			if (this.outstr.length > 0 ) {
                return this.outstr;
			//	stdout.printf ("%s", this.outstr);
			}
		    return "";
		
		
		}
		/**
		 * Core packing routine  for a file
		 * 
		 * @param str - str source text..
		 * @param fn - filename (for reference?)
		 * @param minfile - min file location...
		 * 
		 */

		public  string packFile  (string str,string fn, string minfile)  
		{

			var tr = new  TokenReader(this);
			tr.keepDocs =true;
			tr.keepWhite = true;
			tr.keepComments = true;
			tr.sepIdents = true;
			tr.collapseWhite = false;
			tr.filename = fn;
 
			// we can load translation map here...
		
			TokenArray toks = tr.tokenize(new TextStream(str)); // dont merge xxx + . + yyyy etc.
		
			if (config.opt_dump_tokens) {
				toks.dump();
				return "";
				//GLib.Process.exit(0);
			}
		
			this.activeFile = fn;
		
			// and replace if we are generating a different language..
		

			//var ts = new TokenStream(toks);
			//print(JSON.stringify(toks, null,4 )); Seed.quit();
			var ts = new Collapse(toks.tokens, this, fn);
			
			//ts.dumpAll(""); 			print("Done collaps"); Process.exit(1);
			
		   // print(JSON.stringify(ts.tokens, null,4 )); Seed.quit();
			//return;//
			if (!config.opt_skip_scope) {
				var sp = new ScopeParser(ts, this, fn);
 
				//sp.packer = this;
				sp.buildSymbolTree();
				sp.mungeSymboltree();
			
			
				sp.printWarnings();
			}
			
			
			//print(sp.warnings.join("\n"));
			//(new TokenStream(toks.tokens)).dumpAll(""); GLib.Process.exit(1);
			// compress works on the original array - in theory the replacements have already been done by now 
			var outf = CompressWhite(new TokenStream(toks.tokens), this, config.opt_keep_whitespace); // do not kill whitespace..
		
			
	//		debug("RESULT: \n %s\n", outf);
			
			
			
			if (outf.length > 0 && minfile.length > 0 && !this.hasErrors(fn)) {
				FileUtils.set_contents(minfile, outf);
				 
			}  

		
			return outf;
		
		
			 
		}
		 

		public string md5(string str)
		{
		
			return GLib.Checksum.compute_for_string(GLib.ChecksumType.MD5, str);
		
		}
    
	 //stringHandler : function(tok) -- not used...
    }
    
}
