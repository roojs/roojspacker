 
 

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
        if (!File.isDirectory(PackerRun.opt_doc_target))
            File.mkdir(PackerRun.opt_doc_target);
        if (!File.isDirectory(PackerRun.opt_doc_target+"/symbols"))
            File.mkdir(PackerRun.opt_doc_target+"/symbols");
        if (!File.isDirectory(PackerRun.opt_doc_target+"/symbols/src"))
            File.mkdir(PackerRun.opt_doc_target+"/symbols/src");
        
        if (!File.isDirectory(PackerRun.opt_doc_target +"/json")) {
            File.mkdir(PackerRun.opt_doc_target +"/json");
        }
        
        GLib.debug("Copying files from static: %s " , PackerRun.opt_doc_template_dir);
        // copy everything in 'static' into 
        File.list(PackerRun.opt_doc_template_dir + '/static').forEach(function (f) {
            GLib.debug("Copy %s/static/%s to %s/%s" , PackerRun.opt_doc_template_dir , f,  PackerRun.opt_doc_target + '/' + f);
            File.copyFile(PackerRun.opt_doc_template_dir + '/static/' + f, PackerRun.opt_doc_target + '/' + f,  Gio.FileCopyFlags.OVERWRITE);
        });
        
        
        GLib.debug("Setting up templates");
        // used to check the details of things being linked to
        Link.symbolSet = this.symbolSet;
        Link.base = "../";
        
        Link.srcFileFlatName = this.srcFileFlatName;
        Link.srcFileRelName = this.srcFileRelName;
        
        var classTemplate = new Template({
             templateFile : PackerRun.opt_doc_template_dir  + "/class.html",
             Link : Link
        });
        var classesTemplate = new Template({
            templateFile : PackerRun.opt_doc_template_dir+"/allclasses.html",
            Link : Link
        });
        var classesindexTemplate = new Template({
            templateFile :PackerRun.opt_doc_template_dir +"/index.html",
            Link : Link
        });
        var fileindexTemplate = new Template({   
            templateFile : PackerRun.opt_doc_template_dir +"/allfiles.html",
            Link: Link
        });

        
        classTemplate.symbolSet = this.symbolSet;
        
        
        function hasNoParent($) {
            return ($.memberOf == "")
        }
        function isaFile($) {
            return ($.is("FILE"))
        }
        function isaClass($) {
            return ($.is("CONSTRUCTOR") || $.isNamespace || $.isClass); 
        }
        
        
        
        
        
        
        
        
        
        
        var symbols = this.symbolSet.toArray();
        
        var files = this.packer.files;
        
        for (var i = 0, l = files.size; i < l; i++) {
            var file = files.get(i);
            var targetDir = PackerRun.opt_doc_target + "/symbols/src/";
            this.makeSrcFile(file, targetDir);
        }
        //print(JSON.stringify(symbols,null,4));
        
        var classes = symbols.filter(isaClass).sort(makeSortby("alias"));
         
         //GLib.debug("classTemplate Process : all classes");
            
       // var classesIndex = classesTemplate.process(classes); // kept in memory
        
        GLib.debug("iterate classes");
        
        var jsonAll = {}; 
        
        for (var i = 0, l = classes.length; i < l; i++) {
            var symbol = classes[i];
            var output = "";
            
            GLib.debug("classTemplate Process : " + symbol.alias);
            
            
            
            
            File.write(PackerRun.opt_doc_target+"/symbols/" +symbol.alias+'.' + PackerRun.publishExt ,
                    classTemplate.process(symbol));
            
            jsonAll[symbol.alias] = this.publishJSON(symbol);
            
            
            
        }
        
        File.write(PackerRun.opt_doc_target+"/json/roodata.json",
                JSON.stringify({
                    success : true,
                    data : jsonAll
                }, null, 1)
        );
        
        
        // regenrate the index with different relative links
        Link.base = "";
        //var classesIndex = classesTemplate.process(classes);
        
        GLib.debug("build index");
        
        File.write(PackerRun.opt_doc_target +  "/index.html" //+ PackerRun.publishExt, 
            classesindexTemplate.process(classes)
        );
        
        // blank everything???? classesindexTemplate = classesIndex = classes = null;
        
 
        
        var documentedFiles = symbols.filter(function ($) {
            return ($.is("FILE"))
        });
        
        var allFiles = [];
        
        for (var i = 0; i < files.length; i++) {
            allFiles.push(new  Symbol(files[i], [], "FILE", new DocComment("/** */")));
        }
        
        for (var i = 0; i < documentedFiles.length; i++) {
            var offset = files.indexOf(documentedFiles[i].alias);
            allFiles[offset] = documentedFiles[i];
        }
            
        allFiles = allFiles.sort(makeSortby("name"));
        GLib.debug("write files index");
        
        File.write(Options.opt_doc_target + "/files."+Options.publishExt, 
            fileindexTemplate.process(allFiles)
        );
        
        
        
        
    },
    /**
     * JSON files are lookup files for the documentation
     * - can be used by IDE's or AJAX based doc tools
     * 
     * 
     */
    publishJSON : function(data)
    {
        // what we need to output to be usefull...
        // a) props..
        var cfgProperties = [];
        if (!data.comment.getTag('singleton').length) {
            cfgProperties = data.configToArray();
            cfgProperties = cfgProperties.sort(makeSortby("alias"));
            
        }
        var props = []; 
        //println(cfgProperties.toSource());
        var p ='';
        for(var i =0; i < cfgProperties.length;i++) {
            p = cfgProperties[i];
            var add = {
                name : p.name,
                type : p.type,
                desc : p.desc,
                
                memberOf : p.memberOf == data.alias ? '' : p.memberOf
            }
            if (p.optvalues) {
                add.optvals = p.optvalues;
            }
            props.push(add );
        }
        
         
        var ownEvents = data.methods.filter( function(e){
                return e.isEvent && !e.comment.getTag('hide').length;
            }).sort(makeSortby("name"));
             
        
        var events = [];
        var m;
        for(var i =0; i < ownEvents.length;i++) {
            m = ownEvents[i];
            events.push( {
                name : m.name.substring(1),
                sig : this.makeFuncSkel(m.params),
                type : 'function',
                desc : m.desc
            });
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
      return sourceFile.substring(Options.baseDir.length+1);
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
        
        GLib.debug("Write Source file : " + Options.opt_doc_target+"/symbols/src/" + name);
        var pretty = imports.PrettyPrint.toPretty(File.read(  sourceFile));
        File.write(Options.opt_doc_target+"/symbols/src/" + name, 
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
  





 




