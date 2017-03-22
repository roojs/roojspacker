 
 

namespace JSDOC 
{

	class DocBuilder : Object 
	{
		
		// extractable via JSON?
		public string VERSION = "1.0.0" { get  set };
		
		
		private Packer packer;
	
		public DocBuilder (Packer p) 
		{
			
			
			GLib.debug("Roo JsDoc Toolkit started  at %s ",  (new GLib.DateTime()).format("Y/m/d H:i:s"));
			
			this.packer = p;
        
		    if (PackerRun.opt_tmp_dir != null && !FileUtils.test(PackerRun.opt_tmp_dir, GLib.FileTest.IS_DIR)) {   
		        Posix.mkdir(PackerRun.opt_tmp_dir, 0700);
		    }
        
	
		    this.parseSrcFiles();
		    
		    this.symbolSet = DocParser.symbols;
		    
		    // this currently uses the concept of publish.js...
		    
		    this.publish();
         
        
        
		}
    /**
     * Parse the source files.
     * 
     */

    private void parseSrcFiles() 
    {
        DocParser.init();
        
        
        var useCache = PackerRun.opt_cache_dir == null ;
        var cacheFile = "";
        
        for (var i = 0, l = this.packer.files.size; i < l; i++) {
            
            var srcFile = this.packer.files.get(i);
            
            if (useCache) {
            
        		cacheFile = PackerRun.opt_cache_dir + srcFile.replace(/\//g, '_') + ".cache";
		        
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
		            		var sym = Json.gobject_from_data(typeof(Symbol), o) as Symbol;
		            		DocParser.symbols.add(sym);
	            		}
	            		continue;
            		}
                }
            }
            
            var src = "";
            try {
                GLib.debug("reading : %s" , srcFile);
                src = GLib.FileUtils.get_contents(srcFile);
            }
            catch(GLib.FileError e) {
                GLib.debug("Can't read source file '%s': %s", srcFile, e.to_string());
                continue;
            }

            var txs =
            
            var tr = new  TokenReader(this.packer);
			tr.keepDocs = true;
			tr.keepWhite = true;
			tr.keepComments = true;
			tr.sepIdents = false;
			tr.collapseWhite = false;
			tr.filename = src;
            

            var toks = tr.tokenize( new TextStream(src);
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
    },
    
     
        
    publish  : function() {
        GLib.debug("Publishing");
         
        // link!!!
        
        
        GLib.debug("Making directories");
        if (!File.isDirectory(PackerRun.opt_doc_target)) {
            Posix.mkdir(PackerRun.opt_doc_target,0755);
        }
        if (!File.isDirectory(PackerRun.opt_doc_target+"/symbols")) {
            Posix.mkdir(PackerRun.opt_doc_target+"/symbols",0755);
        }
        if (!File.isDirectory(PackerRun.opt_doc_target+"/symbols/src")) {
            Posix.mkdir(PackerRun.opt_doc_target+"/symbols/src",075);
        }
        if (!File.isDirectory(PackerRun.opt_doc_target +"/json")) {
            File.mkdir(PackerRun.opt_doc_target +"/json",0755);
        }
        
        GLib.debug("Copying files from static: %s " , PackerRun.opt_doc_template_dir);
        // copy everything in 'static' into 
        
        var iter = GLib.File.new_from_path(PackerRun.opt_doc_template_dir + "/static")..enumerate_children (
			"standard::*",
			FileQueryInfoFlags.NOFOLLOW_SYMLINKS, 
			null);
        
        
        while ( (info = enumerator.next_file (null)) != null)) {
			if (info.get_file_type () == FileType.DIRECTORY) {
				continue;
			} 
			var src = .File.new_from_path(info.get_name());
            GLib.debug("Copy %s to %s/%s" , info.get_name() , f,  PackerRun.opt_doc_target , src.get_basename());			
			
			src.copy(
				GLib.File.new_from_path(PackerRun.opt_doc_target + '/' + src.get_basename()),
				GLib.FileCopyFlags.OVERWRITE,
			);
		}
	
        
        GLib.debug("Setting up templates");
        // used to check the details of things being linked to
        Link.symbolSet = this.symbolSet;// need to work out where 'symbolset will be stored/set!
        Link.base = "../";
        
        Link.srcFileFlatName = this.srcFileFlatName; // where set?
        Link.srcFileRelName = this.srcFileRelName; // where set?
        
        var classTemplate = new Template( PackerRun.opt_doc_template_dir  + "/class." + PackerRun.opt_doc_ext );
        var classesTemplate = new Template( PackerRun.opt_doc_template_dir+"/allclasses." + PackerRun.opt_doc_ext  );
        var classesindexTemplate = new Template( PackerRun.opt_doc_template_dir +"/index."  + PackerRun.opt_doc_ext );
        var fileindexTemplate = new Template( PackerRun.opt_doc_template_dir +"/allfiles."+ PackerRun.opt_doc_ext );

        
        classTemplate.symbolSet = this.symbolSet; // where?
        
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
        
        
        
        
        
        
        
        
        
        var symbols = this.symbolSet.toArray();
        
        var files = this.packer.files;
        
        for (var i = 0, l = files.size; i < l; i++) {
            var file = files.get(i);
            var targetDir = PackerRun.opt_doc_target + "/symbols/src/";
            this.makeSrcFile(file, targetDir);
        }
        //print(JSON.stringify(symbols,null,4));
        var classes = new Gee.ArrayList<Symbol>();
        
        for(var symbol in symbol) {
    		if (symbol.isaClass()) { 
    			classes.add(symbol).;
			}
        }   
        classes.sort( (a,b) => {
    		return a.alias.collate(b.alias); 
		});
         
         //GLib.debug("classTemplate Process : all classes");
            
       // var classesIndex = classesTemplate.process(classes); // kept in memory
        
        GLib.debug("iterate classes");
        
        var jsonAll = new JSON.Object(); 
        
        for (var i = 0, l = classes.size; i < l; i++) {
            var symbol = classes.get(i);
            var output = "";
            
            GLib.debug("classTemplate Process : %s" , symbol.alias);
            
            
            
            
            FileUtils.set_contents(
    				PackerRun.opt_doc_target+"/symbols/" +symbol.alias+'.' + PackerRun.opt_doc_ext ,
                    classTemplate.process(symbol)
            );
            
            jsonAll.set_object_member(symbol.alias,  this.publishJSON(symbol));

        }
        Json.Generator generator = new Json.Generator ();
		generator.set_root (jsonAll.get_node());
		generator.pretty=  true;
		generator.ident = 2;
		generator.to_file(PackerRun.opt_doc_target+"/json/roodata.json",);

        
        
        // regenrate the index with different relative links
        Link.base = "";
        //var classesIndex = classesTemplate.process(classes);
        
        GLib.debug("build index");
        
        FileUtils.set_contents(
    		PackerRun.opt_doc_target +  "/index." _ PackerRun.opt_doc_ext  
            classesindexTemplate.process(classes)
        );
        
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
    JSON.Object publishJSON (Symbol data)
    {
        // what we need to output to be usefull...
        // a) props..
        var cfgProperties = new GLib.ArrayList<Symbol>();
        if (!data.comment.getTag(DocTagTitle.SINGLETON).length) {
            cfgProperties = data.configToArray();
            cfgProperties = cfgProperties.sort((a,b) =>{
        		return a.alias.collate(b.alias);
            });
            
        }
        
        var props = new JSON.Array();; 
        //println(cfgProperties.toSource());
        
        for(var i =0; i < cfgProperties.size;i++) {
            var p = cfgPropertiesget.get(i);
            var add = new JSON.Object();
            add.set_string_member("name",p.name);
            add.set_string_member("type",p.type);
            add.set_string_member("desc",p.desc);
            add.set_string_member("memberOf", p.memberOf == data.alias ? '' : p.memberOf);
                
            if (p.optvalues.size) {
        		add.set_array_member("desc",p.optvalues_as_json_array());
            }
            props.add_object(add );
        }
        
        var ownEvents = new Gee.ArrayList<Symbol>();
        for(var i =0; i < data.methods.size;i++) {
    		var e = data.methods.get(i);
    		if (e.isEvent && e.comment.getTag(DocTagTitle.HIDE) != "") {
    			ownEvents.add(e);
			}
		};
		ownEvents.sort((a,b) => {
			return a.name.collate(b.name);
		});
        
        var events = new JSON.Array();
         
        for(var i =0; i < ownEvents.size;i++) {
            var m = ownEvents.get(i);
            var add = new JSON.Object();
            add.set_string_member("name",m.name.substring(1,m.name.length-1);
            add.set_string_member("type","function");
            add.set_string_member("desc",m.desc);
            add.set_string_member("sign", this.makeFuncSkel(m.params));
            events.add(add);
        }
        
        var ownMethods = data.methods.filter( function(e){
                return !e.isEvent && !e.comment.getTag('hide').length;
            }).sort(makeSortby("name"));
             
        
        var methods = [];
        
        for(var i =0; i < ownMethods.length;i++) {
            m = ownMethods[i];
            methods.push( {
                name : m.name,
                sig : this.makeMethodSkel(m.params),
                type : 'function',
                desc : m.desc
            });
        }
        
        //println(props.toSource());
        // we need to output:
        //classname => {
        //    propname => 
        //        type=>
        //        desc=>
        //    }

        var ret = {
            props : props,
            events: events,
            methods : methods,
        };
        return ret;
        
        
        
        // b) methods
        // c) events
        
        
    },
    srcFileRelName : function(sourceFile)
    {
      return sourceFile.substring(PackerRun.opt_real_basedir.length+1);
    },
    srcFileFlatName: function(sourceFile)
    {
        var name = this.srcFileRelName(sourceFile);
        name = name.replace(/\.\.?[\\\/]/g, "").replace(/[\\\/]/g, "_");
        return name.replace(/\:/g, "_") + '.html'; //??;
        
    },
    
    makeSrcFile: function(sourceFile) 
    {
        // this stuff works...
     
        
        var name = this.srcFileFlatName(sourceFile);
        
        GLib.debug("Write Source file : " + PackerRun.opt_doc_target+"/symbols/src/" + name);
        var pretty = imports.PrettyPrint.toPretty(File.read(  sourceFile));
        File.write(PackerRun.opt_doc_target+"/symbols/src/" + name, 
            '<html><head>' +
            '<title>' + sourceFile + '</title>' +
            '<link rel="stylesheet" type="text/css" href="../../../css/highlight-js.css"/>' + 
            '</head><body class="highlightpage">' +
            pretty +
            '</body></html>');
    },
    /**
     * used by JSON output to generate a function skeleton
     */
    makeFuncSkel :function(params) {
        if (!params) return "function ()\n{\n\n}";
        return "function ("	+
            params.filter(
                function($) {
                    return $.name.indexOf(".") == -1; // don't show config params in signature
                }
            ).map( function($) { return $.name == 'this' ? '_self' : $.name; } ).join(", ") +
        ")\n{\n\n}";
    },
	makeMethodSkel :function(params) {
        if (!params) return "()";
        return "("	+
            params.filter(
                function($) {
                    return $.name.indexOf(".") == -1; // don't show config params in signature
                }
            ).map( function($) { return  $.type + " "  +(  $.name == 'this' ? '_self' : $.name ); } ).join(", ") +
        ")";
    }
 
    
};
  





 




