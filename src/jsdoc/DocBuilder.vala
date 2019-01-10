 
 

namespace JSDOC 
{

	class DocBuilder : Object 
	{
		
 
		// extractable via JSON?
		public string VERSION = "1.0.0" ;
		
		private SymbolSet symbolSet;
		
		private Packer packer;
	
		public DocBuilder (Packer p) 
		{
			
 
			GLib.debug("Roo JsDoc Toolkit started  at %s ",  (new GLib.DateTime.now_local()).format("Y/m/d H:i:s"));
			
			this.packer = p;
        
		    //if (PackerRun.singleton().opt_tmp_dir != null && !FileUtils.test(PackerRun.singleton().opt_tmp_dir, GLib.FileTest.IS_DIR)) {   
		    //    Posix.mkdir(PackerRun.singleton().opt_tmp_dir, 0700);
		    //}
        
	
		    this.parseSrcFiles();
		    
		    this.symbolSet = DocParser.symbols();
		     
		    // this currently uses the concept of publish.js...
		    
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
		        /*
		        if (useCache) {
		    		
		    		var ar = DocParser.symbolsToObject(srcFile);
		    		
		    		var builder = new Json.Builder ();
		        	builder.begin_array ();
		        	for (var i=0;i<ar.size;i++) {
		        	
						builder.add_object_value (ar.get(i));
					}
					builder.end_array ();
					Json.Generator generator = new Json.Generator ();
					Json.Node root = builder.get_root ();
					generator.set_root (root);
					generator.pretty=  true;
					generator.ident = 2;
					generator.to_file(cacheFile);
		        
		         
		            
				 }
				 */
		    }
		    
		     
		    
		    DocParser.finish();
		}
		/*

            //var txs =
            
            var tr = new  TokenReader(this.packer);
			tr.keepDocs = true;
			tr.keepWhite = true;
			tr.keepComments = true;
			tr.sepIdents = false;
			tr.collapseWhite = false;
			tr.filename = src;
            

            var toks = tr.tokenize( new TextStream(src));
            if (PackerRun.opt_dump_tokens) {
				toks.dump();
				return "";
				//GLib.Process.exit(0);
			}
            
            
            var ts = new TokenStream(toks);
        
        
        
                     
            DocParser.parse(ts, srcFile);
            
            if (useCache) {
        		
        		var ar = DocParser.symbolsToObject(srcFile);
        		
        		var builder = new Json.Builder ();
            	builder.begin_array ();
            	for (var i=0;i<ar.size;i++) {
            	
					builder.add_object_value (ar.get(i));
				}
				builder.end_array ();
				Json.Generator generator = new Json.Generator ();
				Json.Node root = builder.get_root ();
				generator.set_root (root);
				generator.pretty=  true;
				generator.ident = 2;
				generator.to_file(cacheFile);
            
             
                
    //		}
        }
        
        
        
        Parser.finish();
    }
    
     */
        
		void publish() 
		{
		    GLib.debug("Publishing");
		     
		    // link!!!
		    
		    
		    GLib.debug("Making directories");
		    if (!FileUtils.test (PackerRun.singleton().opt_doc_target,FileTest.IS_DIR )) {
		        Posix.mkdir(PackerRun.singleton().opt_doc_target,0755);
		    }
		    if (!FileUtils.test(PackerRun.singleton().opt_doc_target+"/symbols",FileTest.IS_DIR)) {
		        Posix.mkdir(PackerRun.singleton().opt_doc_target+"/symbols",0755);
		    }
		    if (!FileUtils.test(PackerRun.singleton().opt_doc_target+"/symbols/src",FileTest.IS_DIR)) {
		        Posix.mkdir(PackerRun.singleton().opt_doc_target+"/symbols/src",0755);
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
		    // used to check the details of things being linked to
		    /*
		    Link.symbolSet = this.symbolSet;// need to work out where 'symbolset will be stored/set!
		    Link.base = "../";
		    
		    Link.srcFileFlatName = this.srcFileFlatName; // where set?
		    Link.srcFileRelName = this.srcFileRelName; // where set?
		    */
		    //var classTemplate = new Template( PackerRun.opt_doc_template_dir  + "/class." + PackerRun.opt_doc_ext );
		    //var classesTemplate = new Template( PackerRun.opt_doc_template_dir+"/allclasses." + PackerRun.opt_doc_ext  );
		    //var classesindexTemplate = new Template( PackerRun.opt_doc_template_dir +"/index."  + PackerRun.opt_doc_ext );
		    //var fileindexTemplate = new Template( PackerRun.opt_doc_template_dir +"/allfiles."+ PackerRun.opt_doc_ext );

		    
		    //classTemplate.symbolSet = this.symbolSet; // where?
		    
		    /*
		    function hasNoParent($) {
		        return ($.memberOf == "")
		    }
		    function isaFile($) {
		        return ($.is("FILE"))
		    }
		    function isaClass($) {
		        return ($.is("CONSTRUCTOR") || $.isNamespace || $.isClass); 
		    }
		    */
		    
		    
		    
		    
		    
		    
		    
		    
		    
		    var symbols = this.symbolSet.values();
		    
		    var files = this.packer.files;
		    
		    for (var i = 0, l = files.size; i < l; i++) {
		        var file = files.get(i);
		       // var targetDir = PackerRun.singleton().opt_doc_target + "/symbols/src/";
		        this.makeSrcFile(file);
		    }
		    //print(JSON.stringify(symbols,null,4));
		    var classes = new Gee.ArrayList<Symbol>();
		    
		    foreach(var symbol in symbols) {
				if (symbol.isaClass()) { 
					classes.add(symbol);
				}
		    }    
		    classes.sort( (a,b) => {
				return a.alias.collate(b.alias); 
			});
		     
		     //GLib.debug("classTemplate Process : all classes");
		        
		   // var classesIndex = classesTemplate.process(classes); // kept in memory
		    
		    GLib.debug("iterate classes");
		   
		    var jsonAll = new Json.Object(); 
		    
		    for (var i = 0, l = classes.size; i < l; i++) {
		        var symbol = classes.get(i);
		        var output = "";
		        
		        GLib.debug("classTemplate Process : %s" , symbol.alias);
		        
		        
		        
		        /*
		        FileUtils.set_contents(
						PackerRun.singleton().opt_doc_target+"/symbols/" +symbol.alias+"." +
							 PackerRun.singleton().opt_doc_ext ,
		                classTemplate.process(symbol)
		        );
		        */
		        jsonAll.set_object_member(symbol.alias,  this.publishJSON(symbol));

		    }
		    
		    // outptu class truee
		    
		    var   class_tree_gen = new Json.Generator ();
    	    var  class_tree_root = new Json.Node(Json.NodeType.ARRAY);
			class_tree_root.init_array(this.class_tree(classes));
			class_tree_gen.set_root (class_tree_root);
			class_tree_gen.pretty=  true;
			class_tree_gen.indent = 2;
			GLib.debug("writing JSON:  %s", PackerRun.singleton().opt_doc_target+"/json/tree.json");
			class_tree_gen.to_file(PackerRun.singleton().opt_doc_target+"/json/tree.json");
			size_t class_tree_l;
			GLib.debug("JSON: %s", class_tree_gen.to_data(out class_tree_l));
		    
		    
		    
		    /*---- this is our 'builder' json file.. -- a full list of objects+functions */
		    
		    
		    var   generator = new Json.Generator ();
    	    var  root = new Json.Node(Json.NodeType.OBJECT);
			root.init_object(jsonAll);
			generator.set_root (root);
			generator.pretty=  true;
			generator.indent = 2;
			GLib.debug("writing JSON:  %s", PackerRun.singleton().opt_doc_target+"/json/roodata.json");
			generator.to_file(PackerRun.singleton().opt_doc_target+"/json/roodata.json");
			size_t l;
			GLib.debug("JSON: %s", generator.to_data(out l));
		    
		    
		    // regenrate the index with different relative links
		    //Link.base = "";
		    //var classesIndex = classesTemplate.process(classes);
		    
		    GLib.debug("build index");
		    /*
		    FileUtils.set_contents(
				PackerRun.opt_doc_target +  "/index." + PackerRun.opt_doc_ext , 
		        classesindexTemplate.process(classes)
		    );
		    */
		    
		    // blank everything???? classesindexTemplate = classesIndex = classes = null;
		    
	 
		    /*
		    var documentedFiles = symbols.filter(function ($) {
		        return ($.is("FILE"))
		    });
		    
		    var allFiles = [];
		    
		    for (var i = 0; i < files.length; i++) {
		        allFiles.push(new  Symbol(files[i], [], "FILE", new DocComment("/** *" + "/")));
		    }
		    
		    for (var i = 0; i < documentedFiles.length; i++) {
		        var offset = files.indexOf(documentedFiles[i].alias);
		        allFiles[offset] = documentedFiles[i];
		    }
		        
		    allFiles = allFiles.sort(makeSortby("name"));
		    GLib.debug("write files index");
		    
		    FileUtils.set_contents(
				PackerRun.opt_doc_target + "/files." + PackerRun.opt_doc_ext , 
		        fileindexTemplate.process(allFiles)
		    );
		    */
		    
		    
		    
		}
		/**
		 * JSON files are lookup files for the documentation
		 * - can be used by IDE's or AJAX based doc tools
		 * 
		 * 
		 */
		Json.Object publishJSON (Symbol data)
		{
		    // what we need to output to be usefull...
		    // a) props..
		    var cfgProperties = new Gee.ArrayList<DocTag>();
		    if (data.comment.getTag(DocTagTitle.SINGLETON).size < 1) {
		         cfgProperties = data.configToArray();
		         cfgProperties.sort((a,b) =>{
		    		return a.name.collate(b.name);
		        }); 
		        
		    } 
		    
		    var props = new Json.Array(); 
		    //println(cfgProperties.toSource());
		    
		    for(var i =0; i < cfgProperties.size;i++) {
		        var p = cfgProperties.get(i);
		        var add = new Json.Object();
		        add.set_string_member("name",p.name);
		        add.set_string_member("type",p.type);
		        add.set_string_member("desc",p.desc);
		        add.set_string_member("memberOf", p.memberOf == data.alias ? "" : p.memberOf);
		            
		        if (p.optvalues.size > 0) {
		    		add.set_array_member("desc",p.optvalue_as_json_array());
		        }
		        
		        props.add_object_element(add );
		    }
		    
		    ///// --- events
		    var ownEvents = new Gee.ArrayList<Symbol>();
		    for(var i =0; i < data.methods.size;i++) {
				var e = data.methods.get(i);
				if (e.isEvent && !e.isIgnored) {
					ownEvents.add(e);
				}
			}; 
			ownEvents.sort((a,b) => {
				return a.name.collate(b.name);
			});
		    
		    var events = new Json.Array();
		     
		    for(var i =0; i < ownEvents.size;i++) {
		        var m = ownEvents.get(i);
		        var add = new Json.Object();
		        add.set_string_member("name",m.name.substring(1,-1)); // remove'*' on events..
		        add.set_string_member("type","function");
		        add.set_string_member("desc",m.desc);
		        add.set_string_member("sig", m.makeFuncSkel());
		        add.set_string_member("memberOf", m.memberOf == data.alias ? "" : m.memberOf);		        
		        events.add_object_element(add);
		    } 
		     
		    // methods
		    var ownMethods = new Gee.ArrayList<Symbol>();
		    for(var i =0; i < data.methods.size;i++) {
				var e = data.methods.get(i);
				if (!e.isEvent && !e.isIgnored) {
					ownMethods.add(e);
				}
			};
			ownMethods.sort((a,b) => {
				return a.name.collate(b.name);
			});
		    
	  		var methods = new Json.Array();
		     
		    for(var i =0; i < ownMethods.size;i++) {
		        var m = ownMethods.get(i);
		        var add = new Json.Object();
		        add.set_string_member("name",m.name);
		        add.set_string_member("type","function");
		        add.set_string_member("desc",m.desc);
		        add.set_string_member("sig", m.makeMethodSkel());
		        add.set_boolean_member("static", m.isStatic);
		        add.set_string_member("memberOf", m.memberOf == data.alias ? "" : m.memberOf);	
		        methods.add_object_element(add);
		    }
		     
		    //println(props.toSource());
		    // we need to output:
		    //classname => {
		    //    propname => 
		    //        type=>
		    //        desc=>
		    //    }
			var ret =  new Json.Object();
			ret.set_array_member("props", props);
			ret.set_array_member("events", events);
			ret.set_array_member("methods", methods);
		
 		    return ret;
		    
		    
		    // b) methods
		    // c) events
		    
		    
		}
		
		Json.Object class_tree_new_obj(string name, bool is_class) 
		{
	    	GLib.debug("Class Tree: new object %s", name);
	    	var add =  new Json.Object();
	    	add.set_string_member("name", name);
	    	add.set_array_member("cn", new Json.Array());
	    	add.set_boolean_member("is_class", is_class);
			return add;
		
		}
		
		void class_tree_make_parents(Json.Array top, 
				Gee.HashMap<string,Json.Object> map, Json.Object add)
		{
			var name = add.get_string_member("name");
			var bits = name.split(".");
	    	if (bits.length == 1) {
	    		// top level..
	    		top.add_object_element(add);
	    		map.set(name, add);
	    		return;
    		} 
    		// got aaa.bb or aaa.bb.cc
    		// find the parent..
    		string[] nn = {};
    		for(var i=0; i < bits.length-1; i++) {
    			nn += bits[i];
    		}
    		GLib.debug("Class Tree: adding to parent %s => ", name, pname);
    		var pname = string.joinv(".", nn);
			if (map.has_key(pname)) {
				map.get(pname).get_array_member("cn").add_object_element(add);
				return;
			}
			// no parent found.. make one..
			var parent = this.class_tree_new_obj(pname, false);
			this.class_tree_make_parents(top, map, parent);
    		
		
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
		    var ret = new Json.Array();
		    var map = new Gee.HashMap<string,Json.Object>();
		    foreach (var cls in classes) {
		    	var add =  this.class_tree_new_obj(cls.alias, cls.methods.size > 0 ? true : false);
				this.class_tree_make_parents(ret, map, add);
		    	
		    }
		    
		     return ret;
		    
		}
		
		
		// in Link (js) ???
		string srcFileRelName(string sourceFile)
		{
	  		var rp = Posix.realpath(sourceFile);
	  		return rp.substring(PackerRun.singleton().opt_real_basedir.length+1);
		}
		string srcFileFlatName(string sourceFile)
		{
		    var name = this.srcFileRelName(sourceFile);
		    name = /\\.\\.?[\/]/.replace(name, name.length, 0, "");
		    name = name.replace("/", "_").replace(":", "_") + ".html";
		    return name;
		}
		
		
		void makeSrcFile(string sourceFile) 
		{
		    // this stuff works...
		  
		    var name = this.srcFileFlatName(sourceFile);
		    
		    GLib.debug("Write Source file : %s/symbols/src/%s", 
	    	PackerRun.singleton().opt_doc_target, name);
	    	var str = "";
	    	FileUtils.get_contents(sourceFile, out str);
		    var pretty = PrettyPrint.toPretty(str); 
		    FileUtils.set_contents(
    			PackerRun.singleton().opt_doc_target+"/symbols/src/" + name, 
		        "<html><head>" +
		        "<title>" + sourceFile + "</title>" +
		        "<link rel=\"stylesheet\" type=\"text/css\" href=\"../../../css/highlight-js.css\"/>" + 
		        "</head><body class=\"highlightpage\">" +
		        pretty +
		        "</body></html>");
		}
	}
		 
}
  





 




