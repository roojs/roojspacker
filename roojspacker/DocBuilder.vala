 
 

namespace JSDOC 
{

	public class DocBuilder : Object 
	{
		
 
		// extractable via JSON?
		public string VERSION = "1.0.0" ;
		
		private SymbolSet symbolSet;
		
		public Symbol getSymbol(string name) // wrapper for read only...
		{
			return this.symbolSet.getSymbol(name);
		}
		
		
		
		
		private Packer packer;
	
		public DocBuilder (Packer p) 
		{
			
 
			GLib.debug("Roo JsDoc Toolkit started  at %s ",  (new GLib.DateTime.now_local()).format("Y/m/d H:i:s"));
			
			this.packer = p;
        
		    //if (PackerRun.singleton().opt_tmp_dir != null && !FileUtils.test(PackerRun.singleton().opt_tmp_dir, GLib.FileTest.IS_DIR)) {   
		    //    Posix.mkdir(PackerRun.singleton().opt_tmp_dir, 0700);
		    //}
        
	
		    this.parseSrcFiles();
		    
		    DocParser.validateAugments();		    
		    DocParser.fillChildClasses();
		    DocParser.fillDocChildren();
		    
		    
		    this.symbolSet = DocParser.symbols();
		    
		    
		    var classes =  DocParser.classes();
		     
		    
		    // this currently uses the concept of publish.js...
		   
		    if (PackerRun.singleton().opt_doc_dump_tree) {
		    
		    
		        
				
			 
				//print(JSON.stringify(symbols,null,4));
				 
		        var jsonAll = new Json.Object(); 
		        var ar = new Json.Array(); 
				for (var i = 0, l = classes.size; i < l; i++) {
				    var symbol = classes.get(i);    
				    //
				    ar.add_object_element(  symbol.toJson());

				}
				jsonAll.set_array_member("data", ar);
				var generator = new Json.Generator ();
			    var root = new Json.Node(Json.NodeType.OBJECT);
    		   
				root.init_object(jsonAll);
				generator.set_root (root);
				generator.pretty=  true;
				generator.indent = 2;
				 
				size_t l;
				stdout.printf("%s\n",generator.to_data(out l));

				return;
			}
			size_t l;
			//GLib.debug("JSON: %s", generator.to_data(out l));
		    
		    
		    
		    
		    this.publish();
        
        
		}
		
	 
		
		/**
		 * Parse the source files.
		 * 
		 */
 
		private void parseSrcFiles() 
		{
		   
		    
		    
		    //var useCache = PackerRun.opt_cache_dir == null ;
		    //var cacheFile = "";
		    
		    for (var i = 0, l = this.packer.files.size; i < l; i++) {
		        
		        var srcFile = this.packer.files.get(i);
		        GLib.debug("Parsing source File: %s", srcFile);
		     /*   
		        if (useCache) {
		        
		    		cacheFile = PackerRun.opt_cache_dir + srcFile.replace("/", '_') + ".cache";
				    
				    //print(cacheFile);
				    // disabled at present!@!!
				    
				    if (GLib.FileUtils.test(cacheFile, GLib.FileTest.EXISTS)) {
				        // check filetime?
				        var cache_mt = File.new_for_path (cacheFile).queryInfo(FileAttribute.TIME_MODIFIED,
						            GLib.FileQueryInfoFlags.NONE, null).
						            get_modification_time();
				        var original_mt = File.new_for_path (sourceInfo).queryInfo(FileAttribute.TIME_MODIFIED,
						            GLib.FileQueryInfoFlags.NONE, null).
						            get_modification_time();
				        // this check does not appear to work according to the doc's - need to check it out.
				       
				        if (cache_mt > original_mt) { // cached time  > original time!
				            // use the cached mtimes..
				            GLib.debug("Read %s" , cacheFile);
							var parser = new Json.Parser();
				            parser.load_from_file(cacheFile);
				            var ar = parser.get_root ().get_array();

				            for(var i = 0;i < ar.get_length();i++) {
				        		var o = ar.get_object_element(i);
				        		var sym = JSON.gobject_from_data(typeof(Symbol), o) as Symbol;
				        		DocParser.symbols.add(sym);
			        		}
			        		continue;
		        		}
		            }
		        }
		       */ 
		        var src = "";
		        try {
		            GLib.debug("reading : %s" , srcFile);
		            GLib.FileUtils.get_contents(srcFile, out src);
		        }
		        catch(GLib.FileError e) {
		            GLib.debug("Can't read source file '%s': %s", srcFile, e.message);
		            continue;
		        }

		          
		        
		        var tr = new  TokenReader(this.packer);
				tr.keepDocs = true;
				tr.keepWhite = true;
				tr.keepComments = true;
				tr.sepIdents = false;
				tr.collapseWhite = false;
				tr.filename = src;
		        

		        var toks = tr.tokenize( new TextStream(src) );
		        if (PackerRun.singleton().opt_dump_tokens) {
					toks.dump();
					return;
					//GLib.Process.exit(0);
				}
		        
		        
		        var ts = new TokenStream(toks.tokens);
		    
		    
		    
		                 
		        DocParser.parse(ts, srcFile);
		       
		    }
		    
		     
		    
		    DocParser.finish();
		    
		    
		    // this is probably not the best place for this..
		   
		    

		    
		    
		    
		}
		
		 
		 
		 
     	string tempdir;
        
		void publish() 
		{
		    GLib.debug("Publishing");
		     
		    // link!!!
		    this.tempdir = GLib.DirUtils.make_tmp("roopackerXXXXXX");
		    
		    GLib.debug("Making directories");
		    if (!FileUtils.test (PackerRun.singleton().opt_doc_target,FileTest.IS_DIR )) {
		        Posix.mkdir(PackerRun.singleton().opt_doc_target,0755);
		    }
		    if (!FileUtils.test(PackerRun.singleton().opt_doc_target+"/symbols",FileTest.IS_DIR)) {
		        Posix.mkdir(PackerRun.singleton().opt_doc_target+"/symbols",0755);
		    }
		    if (!FileUtils.test(PackerRun.singleton().opt_doc_target+"/src",FileTest.IS_DIR)) {
		        Posix.mkdir(PackerRun.singleton().opt_doc_target+"/src",0755);
		    }
		    if (!FileUtils.test(PackerRun.singleton().opt_doc_target +"/json",FileTest.IS_DIR)) {
		        Posix.mkdir(PackerRun.singleton().opt_doc_target +"/json",0755);
		    }
		    
		    GLib.debug("Copying files from static: %s " , PackerRun.singleton().opt_doc_template_dir);
		    // copy everything in 'static' into 
		    
		    if (PackerRun.singleton().opt_doc_template_dir  != null) {
				
				var iter = GLib.File.new_for_path(
						PackerRun.singleton().opt_doc_template_dir + "/static"
					).enumerate_children (
					"standard::*",
					FileQueryInfoFlags.NOFOLLOW_SYMLINKS, 
					null);
				FileInfo info;
				
				while ( (info = iter.next_file (null)) != null) {
					if (info.get_file_type () == FileType.DIRECTORY) {
						continue;
					} 
					var src = File.new_for_path(info.get_name());
				    GLib.debug("Copy %s to %s/%s" ,
				    	 info.get_name() ,
				    	  PackerRun.singleton().opt_doc_target , src.get_basename());			
				
					src.copy(
						GLib.File.new_for_path(
							PackerRun.singleton().opt_doc_target + "/" + src.get_basename()
						),
						GLib.FileCopyFlags.OVERWRITE
					);
				}
		
			}		    
		    GLib.debug("Setting up templates");
		     
		    
		    
		    var symbols = this.symbolSet.values();
		    
		    var files = this.packer.files;
		    
		    for (var i = 0, l = files.size; i < l; i++) {
		        var file = files.get(i);
		       // var targetDir = PackerRun.singleton().opt_doc_target + "/symbols/src/";
		        this.makeSrcFile(file);
		    }
		    //print(JSON.stringify(symbols,null,4));
		    var classes = DocParser.classes();
		     
		     //GLib.debug("classTemplate Process : all classes");
		        
		   // var classesIndex = classesTemplate.process(classes); // kept in memory
		    
		    GLib.debug("iterate classes");
		   
		    var jsonAll = new Json.Object(); 
		    
		    for (var i = 0, l = classes.size; i < l; i++) {
		        var symbol = classes.get(i);
		        var output = "";
		        
		        GLib.debug("classTemplate Process : %s" , symbol.alias);
		        
		        
		        var   class_gen = new Json.Generator ();
			    var  class_root = new Json.Node(Json.NodeType.OBJECT);
				class_root.init_object(symbol.toClassDocJSON());
				class_gen.set_root (class_root);
				class_gen.pretty=  true;
				class_gen.indent = 2;
				GLib.warning("writing JSON:  %s", PackerRun.singleton().opt_doc_target+"/symbols/" +symbol.alias+".json");
				this.writeJson(class_gen, PackerRun.singleton().opt_doc_target+"/symbols/" +symbol.alias+".json");
		        
		        jsonAll.set_object_member(symbol.alias,  symbol.toClassJSON());

		    }
		    
		    // outptu class tree
		    
		    var   class_tree_gen = new Json.Generator ();
    	    var  class_tree_root = new Json.Node(Json.NodeType.ARRAY);
			class_tree_root.init_array(this.class_tree(classes));
			class_tree_gen.set_root (class_tree_root);
			class_tree_gen.pretty=  true;
			class_tree_gen.indent = 2;
			GLib.warning("writing JSON:  %s", PackerRun.singleton().opt_doc_target+"/tree.json");
			this.writeJson(class_tree_gen,PackerRun.singleton().opt_doc_target+"/tree.json");
			size_t class_tree_l;
			//GLib.debug("JSON: %s", class_tree_gen.to_data(out class_tree_l));
		    
		    
		    
		    /*---- this is our 'builder' json file.. -- a full list of objects+functions */
		    
		    
		    var   generator = new Json.Generator ();
    	    var  root = new Json.Node(Json.NodeType.OBJECT);
			root.init_object(jsonAll);
			generator.set_root (root);
			generator.pretty=  true;
			generator.indent = 2;
			GLib.warning("writing JSON:  %s", PackerRun.singleton().opt_doc_target+"/json/roodata.json");
			
			
			this.writeJson(generator,PackerRun.singleton().opt_doc_target+"/json/roodata.json");
			size_t l;
			//GLib.debug("JSON: %s", generator.to_data(out l));
		    
		    
		     
		    
		    GLib.debug("build index");
		   
		    
		    
		}
		
 
		/**
		* needed as Json dumps .xXXX into same directory as it writes...
		*/
		void writeJson(Json.Generator g, string fname)
		{
				var tmp = this.tempdir + GLib.Path.get_basename(fname);
				g.to_file(tmp);
				
				if (GLib.FileUtils.test(fname, GLib.FileTest.EXISTS)) {
					string new_data, old_data;
					FileUtils.get_contents(tmp, out new_data);
					FileUtils.get_contents(fname, out old_data);
					if (old_data == new_data) {
						GLib.File.new_for_path(tmp).delete();
						return;
					}
			   }
				
		        GLib.File.new_for_path(tmp).move( File.new_for_path(fname), GLib.FileCopyFlags.OVERWRITE);
		      
		}
		 
		Gee.HashMap<string,Json.Object> class_tree_map;
		Json.Array class_tree_top;
		
		Json.Object? class_tree_new_obj(string name, bool is_class, out bool is_new) 
		{
	    	if (this.class_tree_map.has_key(name)) {
	    		var ret = this.class_tree_map.get(name);
	    		if (!ret.get_boolean_member("is_class") && is_class) {
			    	ret.set_boolean_member("is_class", is_class);
	    		}
	    		is_new = false;
	    		return ret; // no need to do anything
	    	
	    	}
	    	
	    	GLib.debug("Class Tree: new object %s", name);
	    	var add =  new Json.Object();
	    	add.set_string_member("name", name);
	    	add.set_array_member("cn", new Json.Array());
	    	add.set_boolean_member("is_class", is_class);
	    	
	    	this.class_tree_map.set(name, add);
	    	var bits = name.split(".");
	    	if (bits.length == 1) {
	    		// top level..
	    		this.class_tree_top.add_object_element(add);
	    		 
    		} 
	    	is_new = true;
	    	
			return add;
		
		}
		
		void class_tree_make_parents(  Json.Object add)
		{
			var name = add.get_string_member("name");
			var bits = name.split(".");
	    	if (bits.length < 2) {
	    	 	return;
    	 	}
    		// got aaa.bb or aaa.bb.cc
    		// find the parent..
    		string[] nn = {};
    		for(var i=0; i < bits.length-1; i++) {
    			nn += bits[i];
    		}
    		var pname = string.joinv(".", nn);
    		GLib.debug("Class Tree: adding to parent %s => %s", name, pname); 
			 
			// no parent found.. make one..
			bool is_new;
			var parent = this.class_tree_new_obj(pname, false, out is_new); 
			parent.get_array_member("cn").add_object_element(add);
			if (is_new) {
				this.class_tree_make_parents(  parent);
			}
    		
		
		}
		Json.Array class_tree (Gee.ArrayList<Symbol> classes )
		{
		
		
		    // produce a tree array that can be used to render the navigation.
		    /*
		    should produce:
		    
		    [
		    	{
		    		name : Roo,
		    		desc : ....
		    		is_class : true,
		    		cn : [
		    			{
		    				name : 'Roo.util',
		    				basename : 'util',
		    				is_class : false,
	    					cn : [
	    						{
	    							....
		    
		    to do this, we will need to create the objects in a hashmap
		    Roo.util => Json.Object
		    
		    */
		    this.class_tree_top = new Json.Array();
		    this.class_tree_map = new Gee.HashMap<string,Json.Object>();
		    foreach (var cls in classes) {
		    	if(cls.alias.length < 1 || cls.alias == "this" || cls.alias == "_global_") {
		    		continue;
	    		}
	    		bool is_new;
		    	var add =  this.class_tree_new_obj(cls.alias, cls.methods.size > 0 ? true : false,out is_new);
				if (add != null) {
					this.class_tree_make_parents( add);
				}
		    	
		    }
		    
		     return this.class_tree_top;
		    
		}
		
		
		// in Link (js) ???
		string srcFileRelName(string sourceFile)
		{
	  		var rp = Posix.realpath(sourceFile);
	  		return rp.substring(PackerRun.singleton().opt_real_basedir.length);
		}
		string srcFileFlatName(string sourceFile)
		{
		    var name = this.srcFileRelName(sourceFile);
		    name = /\.\.?[\/]/.replace(name, name.length, 0, "");
		    name = name.replace("/", "_").replace(":", "_") + ".html";
		    return name;
		}
		
		
		void makeSrcFile(string sourceFile) 
		{
		    // this stuff works...
		    
		   
		    
		        // this check does not appear to work according to the doc's - need to check it out.
	       
		  
		    var name = this.srcFileFlatName(sourceFile);
		    
		    GLib.debug("Write Source file : %s/src/%s", 
	    	PackerRun.singleton().opt_doc_target, name);
	    	var str = "";
	    	FileUtils.get_contents(sourceFile, out str);
		    var pretty = PrettyPrint.toPretty(str); 
		     var fname = PackerRun.singleton().opt_doc_target+"/src/" + name;
		    
		    var tmp = this.tempdir + GLib.Path.get_basename(fname);
		    FileUtils.set_contents(
    			tmp, 
		        "<html><head>" +
		        "<title>" + this.srcFileRelName(sourceFile) + "</title>" +
		        "<link rel=\"stylesheet\" type=\"text/css\" href=\"../../css/highlight-js.css\"/>" + 
		        "</head><body class=\"highlightpage\">" +
		        pretty +
		        "</body></html>");
		        
		    // same content?
		     if (GLib.FileUtils.test(fname, GLib.FileTest.EXISTS)) {
				string new_data, old_data;
				FileUtils.get_contents(tmp, out new_data);
				FileUtils.get_contents(fname, out old_data);
				if (old_data == new_data) {
					GLib.File.new_for_path(tmp).delete();
					return;
				}
		     }
		        
	        GLib.File.new_for_path(tmp).move( File.new_for_path(fname), GLib.FileCopyFlags.OVERWRITE);
		      
		    
		    

		}
	}
		 
}
  





 




