 
 

namespace JSDOC 
{

	class DocBuilder : Object 
	{
		
		// extractable via JSON?
		string VERSION = "1.0.0" { get  set };
		
	
		public DocBuilder (Packer p) 
		{
			GLib.debug("Roo JsDoc Toolkit started  at %s ",  (new GLib.DateTime()).format("Y/m/d H:i:s"));
			
		
        
        if (Options.cacheDirectory.length && !File.isDirectory(Options.cacheDirectory)) {   
            File.mkdir(Options.cacheDirectory)
        }
        
        Options.srcFiles = this._getSrcFiles();
        this._parseSrcFiles();
        this.symbolSet = Parser.symbols;
        
        // this currently uses the concept of publish.js...
        
        this.publish();
         
        
        
    },
    /**
     * create a list of files in this.srcFiles using list of directories / files in Options.src
     * 
     */
    
    _getSrcFiles : function() 
    {
        this.srcFiles = [];
        var _this = this;
        var ext = ["js"];
        if (Options.ext) {
            ext = Options.ext.split(",").map(function($) {return $.toLowerCase()});
        }
        
        for (var i = 0; i < Options.src.length; i++) {
            // add to sourcefiles..
            if (!File.isDirectory(Options.src[i])) {
                _this.srcFiles.push(Options.src[i]);
                continue;
            }
            File.list(Options.src[i] ).forEach(function($) {
                if (Options['exclude-src'].indexOf($) > -1) {
                    return;
                }
                var thisExt = $.split(".").pop().toLowerCase();
                if (ext.indexOf(thisExt) < 0) {
                    return;
                }
                _this.srcFiles.push(Options.src[i] + '/' + $);
            });
                
        }
        //Seed.print(JSON.stringify(this.srcFiles, null,4));Seed.quit();
        return this.srcFiles;
    },
    /**
     * Parse the source files.
     * 
     */

    _parseSrcFiles : function() 
    {
        Parser.init();
        
        for (var i = 0, l = this.srcFiles.length; i < l; i++) {
            
            var srcFile = this.srcFiles[i];
            
            
            var cacheFile = !Options.cacheDirectory.length ? false : 
                Options.cacheDirectory + srcFile.replace(/\//g, '_') + ".cache";
            
            //print(cacheFile);
            // disabled at present!@!!
            
            if (cacheFile  && File.exists(cacheFile)) {
                // check filetime?
                
                var c_mt = File.mtime(cacheFile);
                var o_mt = File.mtime(srcFile);
                //println(c_mt.toSource());
               // println(o_mt.toSource());
               
                // this check does not appear to work according to the doc's - need to check it out.
               
                if (c_mt > o_mt) { // cached time  > original time!
                    // use the cached mtimes..
                    print("Read " + cacheFile);
                    var syms =  JSON.parse(File.read(cacheFile), function(k, v) {
                        //print(k);
                        if (typeof(v) != 'object') {
                            return v;
                        }
                        if (typeof(v['*object']) == 'undefined') {
                            return v;
                        }
                        var cls = imports[v['*object']][v['*object']];
                        //print(v['*object']);
                        delete v['*object'];
                        var ret = new cls();
                        XObject.extend(ret, v);
                        return ret;
                        
                        
                    });
                    //print("Add sybmols " + cacheFile); 
                    for (var sy in syms._index) {
                      //  print("ADD:" + sy );
                       Parser.symbols.addSymbol(syms._index[sy]);
                    }
                    continue;
                }
            }
            
            var src = ''
            try {
                Options.LOG.inform("reading : " + srcFile);
                src = File.read(srcFile);
            }
            catch(e) {
                Options.LOG.warn("Can't read source file '"+srcFile+"': "+e.message);
                continue;
            }

            var txs = new TextStream(src);
            
            var tr = new TokenReader({ keepComments : true, keepWhite : true , sepIdents: false });
            
            var ts = new TokenStream(tr.tokenize(txs));
        
            Parser.parse(ts, srcFile);
            
            if (cacheFile) {
                File.write(cacheFile,
                  JSON.stringify(
                    Parser.symbolsToObject(srcFile),
                    null,2
                  )
                );
            
            }
            //var outstr = JSON.stringify(
            //    Parser.filesSymbols[srcFile]._index
            //);
            //File.write(cacheFile, outstr);
             
                
    //		}
        }
        
        
        
        Parser.finish();
    },
    
     
        
    publish  : function() {
        Options.LOG.inform("Publishing");
         
        // link!!!
        
        
        Options.LOG.inform("Making directories");
        if (!File.isDirectory(Options.target))
            File.mkdir(Options.target);
        if (!File.isDirectory(Options.target+"/symbols"))
            File.mkdir(Options.target+"/symbols");
        if (!File.isDirectory(Options.target+"/symbols/src"))
            File.mkdir(Options.target+"/symbols/src");
        
        if (!File.isDirectory(Options.target +"/json")) {
            File.mkdir(Options.target +"/json");
        }
        
        Options.LOG.inform("Copying files from static: " +Options.templateDir);
        // copy everything in 'static' into 
        File.list(Options.templateDir + '/static').forEach(function (f) {
            Options.LOG.inform("Copy " + Options.templateDir + '/static/' + f + ' to  ' + Options.target + '/' + f);
            File.copyFile(Options.templateDir + '/static/' + f, Options.target + '/' + f,  Gio.FileCopyFlags.OVERWRITE);
        });
        
        
        Options.LOG.inform("Setting up templates");
        // used to check the details of things being linked to
        Link.symbolSet = this.symbolSet;
        Link.base = "../";
        
        Link.srcFileFlatName = this.srcFileFlatName;
        Link.srcFileRelName = this.srcFileRelName;
        
        var classTemplate = new Template({
             templateFile : Options.templateDir  + "/class.html",
             Link : Link
        });
        var classesTemplate = new Template({
            templateFile : Options.templateDir +"/allclasses.html",
            Link : Link
        });
        var classesindexTemplate = new Template({
            templateFile : Options.templateDir +"/index.html",
            Link : Link
        });
        var fileindexTemplate = new Template({   
            templateFile : Options.templateDir +"/allfiles.html",
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
        
        var files = Options.srcFiles;
        
        for (var i = 0, l = files.length; i < l; i++) {
            var file = files[i];
            var targetDir = Options.target + "/symbols/src/";
            this.makeSrcFile(file, targetDir);
        }
        //print(JSON.stringify(symbols,null,4));
        
        var classes = symbols.filter(isaClass).sort(makeSortby("alias"));
         
         //Options.LOG.inform("classTemplate Process : all classes");
            
       // var classesIndex = classesTemplate.process(classes); // kept in memory
        
        Options.LOG.inform("iterate classes");
        
        var jsonAll = {}; 
        
        for (var i = 0, l = classes.length; i < l; i++) {
            var symbol = classes[i];
            var output = "";
            
            Options.LOG.inform("classTemplate Process : " + symbol.alias);
            
            
            
            
            File.write(Options.target+"/symbols/" +symbol.alias+'.' + Options.publishExt ,
                    classTemplate.process(symbol));
            
            jsonAll[symbol.alias] = this.publishJSON(symbol);
            
            
            
        }
        
        File.write(Options.target+"/json/roodata.json",
                JSON.stringify({
                    success : true,
                    data : jsonAll
                }, null, 1)
        );
        
        
        // regenrate the index with different relative links
        Link.base = "";
        //var classesIndex = classesTemplate.process(classes);
        
        Options.LOG.inform("build index");
        
        File.write(Options.target +  "/index."+ Options.publishExt, 
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
        Options.LOG.inform("write files index");
        
        File.write(Options.target + "/files."+Options.publishExt, 
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
        
        Options.LOG.inform("Write Source file : " + Options.target+"/symbols/src/" + name);
        var pretty = imports.PrettyPrint.toPretty(File.read(  sourceFile));
        File.write(Options.target+"/symbols/src/" + name, 
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
  





 




