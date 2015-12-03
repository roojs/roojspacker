 
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
		string target;
		GLib.FileOutputStream targetStream = null;
		/**
		 * @cfg {String} debugTarget target to write files debug version to (uncompacted)- must be full path.
		 */
		string targetDebug;
		

		GLib.FileOutputStream targetDebugStream  = null;
		/**
		 * @cfg {String} tmpDir  (optional) where to put the temporary files. 
		 *      if you set this, then files will not be cleaned up
		 *  
		 *  at present we need tmpfiles - as we compile multiple files into one.
		 *  we could do this in memory now, as I suspect vala will not be as bad as javascript for leakage...
		 *
		 */
		public string tmpDir = "/tmp";  // FIXME??? in ctor?
	
	
		  
		/**
		 * @cfg {Boolean} cleanup  (optional) clean up temp files after done - 
		 *    Defaults to false if you set tmpDir, otherwise true.
		 */
		public bool cleanup =  true;
		
		
		/**
		 * @cfg {Boolean} keepWhite (optional) do not remove white space in output.
		 *    usefull for debugging compressed files.
		 */
		
		public bool keepWhite =  false;
		
		
		// list of files to compile...
		Gee.ArrayList<string> files;
		
		/**
		* @cfg debug -- pretty obvious.
		*/
		 
		public string activeFile = "";
		
		
		public  string outstr = ""; // if no target is specified - then this will contain the result
    
		public Packer(string target, string targetDebug = "")
		{
			this.target = target;
			this.targetDebug  = targetDebug;
			this.files = new Gee.ArrayList<string>();
			
			new Lang_Class(); ///initilizaze lang..
			 
		}
		
		public void loadSourceIndexes(Gee.ArrayList<string> indexes)
		{
			foreach(var f in indexes) {
				this.loadSourceIndex(f);
			}
		}
		
		public void loadFiles(string[] fs)
		{
			foreach(var f in fs) {
			    GLib.debug("add File: %s", f);
				this.files.add(f); //?? easier way?
			}
		}
		public void loadFile(string f)
		{
		    GLib.debug("add File: %s", f);
			this.files.add(f); 
			GLib.debug("FILE LEN: %d", this.files.size);
		}
		
		public void pack()
		{
		    if (this.files.size < 1) {
				throw new PackerError.ArgumentError("No Files loaded before pack() called");
			}
			if (this.target.length > 0 ) {
				this.targetStream = File.new_for_path(this.target).replace(null, false,FileCreateFlags.NONE);
			}
			if (this.targetDebug.length > 0 ) {
				this.targetDebugStream = File.new_for_path(this.targetDebug).replace(null, false,FileCreateFlags.NONE);
			}
			this.packAll();
		}
		
  
		
		
   
		
 
	   
		/**
		 * load a dependancy list -f option
		 * @param {String} srcfile sourcefile to parse
		 * 
		 */
		
		public void loadSourceIndex(string srcfile)
		{
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
		        if (this.files.contains(add)) {
		            continue;
		        }
		        this.files.add( add );
		        
		    }
		}
		
    
		private void packAll()  // do the packing (run from constructor)
		{
		    
		    //this.transOrigFile= bpath + '/../lang.en.js'; // needs better naming...
		    //File.write(this.transfile, "");
		    if (this.target.length > 0) {
		        this.targetStream.write("".data);
		    }
		    
		    if (this.targetDebugStream != null) {
			    this.targetDebugStream.write("".data);
		    }
		    
		    
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
		        
		   
		        
		        var minfile = this.tmpDir + "/" + file.replace("/", ".");
		        
		        
		        // let's see if we have a min file already?
		        // this might happen if tmpDir is set .. 

		        
		        if (false && FileUtils.test (minfile, FileTest.EXISTS)) {
		    		
		    		var otv = File.new_for_path(file).query_info (FileAttribute.TIME_MODIFIED, 0).get_modification_time();
		    		var mtv = File.new_for_path(minfile).query_info (FileAttribute.TIME_MODIFIED, 0).get_modification_time();
					
					var ot = new Date();
					ot.set_time_val(otv);
					var mt = new Date();
					mt.set_time_val(mtv);
		            //print("compare : " + mt + "=>" + ot);
		            if (mt.compare(ot) >= 0) {
		                continue; // file is newer or the same time..
		                
		            }
		            
		        }
		         
		        print("COMPRESSING to %s\n", minfile);
		        //var codeComp = pack(str, 10, 0, 0);
		        if (FileUtils.test (minfile, FileTest.EXISTS)) {
		            FileUtils.remove(minfile);
		        }
		        if (!loaded_string) {
		    		FileUtils.get_contents(file,out file_contents);
	    		}

		         this.packFile(file_contents, file, minfile);
		         
		      
		    }
		    
		  
		    print("MERGING SOURCE\n");
		    
		    for(var i=0; i < this.files.size; i++)  {
		        var file = this.files[i];
		        var minfile = this.tmpDir + "/" + file.replace("/", ".");
		        
		        
		        if ( !FileUtils.test(minfile, FileTest.EXISTS)) {
		    		print("skipping source %s - does not exist\n", minfile);
		            continue;
		        }
		        string str;
		        FileUtils.get_contents(minfile, out str);
		        print("using MIN FILE  %s\n", minfile);
		        if (str.length > 0) {
		            if (this.targetStream != null) {
		        		this.targetStream.write(("// " + file + "\n").data); 
		        		this.targetStream.write((str + "\n").data); 

		            } else {
		                this.outstr += "//" + file + "\n";
		                this.outstr += str + "\n";
		            }
		            
		        }
		        if (this.cleanup) {
		            FileUtils.remove(minfile);
		        }
		        
		    }
		    if (this.target.length > 0 ) {
			    print("Output file: " + this.target);
		    }
		    if (this.targetDebug.length > 0) {
				 print("Output debug file: %s\n" , this.targetDebug);
			}  
			
			if (this.outstr.length > 0 ) {
				print(this.outstr);
			}
		     
		
		
		}
		/**
		 * Core packing routine  for a file
		 * 
		 * @param str - str source text..
		 * @param fn - filename (for reference?)
		 * @param minfile - min file location...
		 * 
		 */

		private string packFile  (string str,string fn, string minfile)
		{

			var tr = new  TokenReader();
			tr.keepDocs =true;
			tr.keepWhite = true;
			tr.keepComments = true;
			tr.sepIdents = true;
			tr.collapseWhite = false;
			tr.filename = fn;
 
			// we can load translation map here...
		
			TokenArray toks = tr.tokenize(new TextStream(str)); // dont merge xxx + . + yyyy etc.
		
		
		
			this.activeFile = fn;
		
			// and replace if we are generating a different language..
		

			//var ts = new TokenStream(toks);
			//print(JSON.stringify(toks, null,4 )); Seed.quit();
			var ts = new Collapse(toks.tokens);
			
			//ts.dumpAll(""); 			print("Done collaps"); Process.exit(1);
			
		   // print(JSON.stringify(ts.tokens, null,4 )); Seed.quit();
			//return;//
			var sp = new ScopeParser(ts);
 
			//sp.packer = this;
			sp.buildSymbolTree();

			sp.mungeSymboltree();
			sp.printWarnings();
			//print(sp.warnings.join("\n"));
			//(new TokenStream(toks.tokens)).dumpAll(""); GLib.Process.exit(1);
			// compress works on the original array - in theory the replacements have already been done by now 
			var outf = CompressWhite(new TokenStream(toks.tokens), this, this.keepWhite); // do not kill whitespace..
		
			
			print("RESULT: \n %s\n", outf);
		
			 if (outf.length > 0) {
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
