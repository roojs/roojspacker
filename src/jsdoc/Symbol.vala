 
/**
	Create a new Symbol.
	@class Represents a symbol in the source code.
 */
 
 
namespace JSDOC {


	public  class Symbol : Object
	{
		
		private static bool regex_init = false;
		private GLib.Regex regex_global;
		private GLib.Regex regex_prototype;
		
		static void  regexInit()
		{
			if (Symbol.regex_init = true) {
				return;
			}
			Symbol.regex_init = true;
			Symbol.regex_global = new GLib.Regex("^_global_[.#-]");
			Symbol.regex_prototype = new GLib.Regex("\\.prototype\\.?");
		}

		private string private_name {
    		set {
				var n = Symbol.regex_global(value, value.length, 0, "");
		        n =  Symbol.regex_prototype(n,n.length, 0, "#");
		        while (true) {
		    		if (!n.has_suffix("#")) {
		    			break;
					}
					n = n.substring(0, n.length-1);
				}
			
		        this.private_name = n;
    		}
		
		}
		 
        public string name {
    		get { return this.private_name; }
		}
		
      
        string defaultValue = "";
        
        
        private Gee.ArrayList<DocTag> private_params{
    		set  {
                for (var i = 0; i < value.size; i++) {
                    //if (v[i].constructor != DocTag) { // may be a generic object parsed from signature, like {type:..., name:...}
                    //    var ty = v[i].hasOwnProperty('type') ? v[i].type : '';
                    //    this._params[i] = new DocTag(
                    //        "param"+((ty)?" {"+ty+"}":"")+" "+v[i].name);
                    //}
                    //else {
                    //    this._params[i] = v[i];
                    //}
                    this.private_params.add(v.get(i));
                }
                //this.params = this._params;
            }
        }
        public Gee.ArrayList<DocTag> params {
            get {
        		return this.private_params;
    		}
        		
        }
        
        
        private Gee.ArrayList<DocTag>  augments ;  
        
        private Gee.ArrayList<DocTag>  exceptions ;
       
        private Gee.ArrayList<DocTag>  inherits; 
        private Gee.ArrayList<DocTag>  methods;

		private Gee.ArrayList<DocTag> properties;
        private Gee.ArrayList<DocTag> requires;
        private Gee.ArrayList<DocTag> returns;
        private Gee.ArrayList<DocTag> see ;

         
        //childClasses : [],
        //cfgs : {},
        
        
        DocComment comment;
                
        //$args : [], // original arguments used when constructing.
        string addOn = "";
        public string alias = "";
        
        string author = "";
        string classDesc = "";

        string deprecated = "";
        string desc = "";
        //events : false,
        string example = "";
        
        //inheritsFrom : [],
        string isa = "OBJECT"; // OBJECT//FUNCTION
        
        public bool isEvent = false;
        public bool isConstant = false;
        public bool isIgnored = false;
        public bool isInner = false;
        public bool isNamespace = false;
        public bool isPrivate = false;
        public bool isStatic = false;
        
        string memberOf = "";



       
        string since = "";

        string type = "";
        string version = "";
       
        string srcFile = "";
        
        
        
        public void initArrays()
        {
            // only initialize arrays / objects..

            
            //this.params = [];
            //this.$args = [];
            
            //this.events = [];
            this.exceptions = new Gee.ArrayList<DocTag>();
            this.inherits = new Gee.ArrayList<DocTag>();
            //
            this.isa = "OBJECT"; // OBJECT//FUNCTION
            this.methods = new Gee.ArrayList<DocTag>();
            //this.private_params = new Gee.ArrayList<DocTag>();
            this.properties = new Gee.ArrayList<DocTag>();
            this.requires = new Gee.ArrayList<DocTag>();
            this.returns = new Gee.ArrayList<DocTag>();
            this.see = new Gee.ArrayList<DocTag>();
 
            
            
            this.cfgs = {};
            // derived later?
            //this.inheritsFrom = [];
            //this.childClasses = [];
            
            this.comment = new DocComment();
            this.comment.isUserComment =  false;
            
               
        }
		
		Public Symbol.new_builtin(string name)
		{
            Symbol.regexInit();
            this.initArrays();
            this.srcFile = DocParser.currentSourceFile;
			this.prviate_name =  name ;
			this.alias = this.name;
			this.isa = "CONSTRUCTOR";
			this.comment = new DocComment("");
			this.comment.isUserComment =  false;
			this.isNamespace = false;
			this.srcFile = "";
			this.isPrivate = false;
			// init arrays....
			
			
			
		}
		

 

        public Symbol.new_populate_with_args(
                string  name,
                Gee.ArrayList<string> params, // fixme???
                string isa,
                string comment
        ) {
            Symbol.regexInit();
            this.initArrays();
            this.$args = arguments;
            //println("Symbol created: " + isa + ":" + name);
            this.private_name = name;
            this.alias = this.getName();
            this.setParams(params);
            this.isa = (isa == "VIRTUAL")? "OBJECT":isa;
            this.comment = comment || new DocComment("")
            
            this.srcFile = DocParser.currentSourceFile;
            
           
            
            if (this.is("FILE") && !this.alias) { // this will never hapen???
        		this.alias = this.srcFile;
    		}

            this.setTags();
            
        },

        setTags : function() {
            // @author
            var authors = this.comment.getTag("author");
            if (authors.length) {
                this.author = authors.map(function($){return $.desc;}).join(", ");
            }
            
            /*~t
                assert("testing Symbol");
                
                requires("../lib/JSDOC/DocComment.js");
                requires("../frame/String.js");
                requires("../lib/JSDOC/DocTag.js");

                var sym = new Symbol("foo", [], "OBJECT", new DocComment("/**@author Joe Smith*"+"/"));
                assertEqual(sym.author, "Joe Smith", "@author tag, author is found.");
            */
            // @desc
            var mth = this.comment.getTag("method");
            if (mth.length) {
                this.isa = "FUNCTION";
            }
            // @desc
            var descs = this.comment.getTag("desc");
            if (descs.length) {
                this.desc = descs.map(function($){return $.desc;}).join("\n"); // multiple descriptions are concatenated into one
            }
            
            /*~t
                var sym = new Symbol("foo", [], "OBJECT", new DocComment("/**@desc This is a description.*"+"/"));
                assertEqual(sym.desc, "This is a description.", "@desc tag, description is found.");
            */
            
            // @overview
            if (this.is("FILE")) {
                if (!this.alias) this.alias = this.srcFile;
                
                var overviews = this.comment.getTag("overview");
                if (overviews.length) {
                    this.desc = [this.desc].concat(overviews.map(function($){return $.desc;})).join("\n");
                }
            }
            
            /*~t
                var sym = new Symbol("foo", [], "FILE", new DocComment("/**@overview This is an overview.*"+"/"));
                assertEqual(sym.desc, "\nThis is an overview.", "@overview tag, description is found.");
            */
            
            // @since
            var sinces = this.comment.getTag("since");
            if (sinces.length) {
                this.since = sinces.map(function($){return $.desc;}).join(", ");
            }
            
            /*~t
                var sym = new Symbol("foo", [], "FILE", new DocComment("/**@since 1.01*"+"/"));
                assertEqual(sym.since, "1.01", "@since tag, description is found.");
            */
            
            // @constant
            if (this.comment.getTag("constant").length) {
                this.isConstant = true;
                this.isa = 'OBJECT';
            }
            
            /*~t
                var sym = new Symbol("foo", [], "FILE", new DocComment("/**@constant*"+"/"));
                assertEqual(sym.isConstant, true, "@constant tag, isConstant set.");
            */
            
            // @version
            var versions = this.comment.getTag("version");
            if (versions.length) {
                this.version = versions.map(function($){return $.desc;}).join(", ");
            }
            
            /*~t
                var sym = new Symbol("foo", [], "FILE", new DocComment("/**@version 2.0x*"+"/"));
                assertEqual(sym.version, "2.0x", "@version tag, version is found.");
            */
            
            // @deprecated
            var deprecateds = this.comment.getTag("deprecated");
            if (deprecateds.length) {
                this.deprecated = deprecateds.map(function($){return $.desc;}).join("\n");
            }
            
            /*~t
                var sym = new Symbol("foo", [], "FILE", new DocComment("/**@deprecated Use other method.*"+"/"));
                assertEqual(sym.deprecated, "Use other method.", "@deprecated tag, desc is found.");
            */
            
            // @example
            var examples = this.comment.getTag("example");
            if (examples.length) {
                this.example = examples[0];
            }
            
            /*~t
                var sym = new Symbol("foo", [], "FILE", new DocComment("/**@example This\n  is an example.*"+"/"));
                assertEqual(sym.example, "This\n  is an example.", "@deprecated tag, desc is found.");
            */
            
            // @see
            var sees = this.comment.getTag("see");
            if (sees.length) {
                var thisSee = this.see;
                sees.map(function($){thisSee.push($.desc);});
            }
            
            /*~t
                var sym = new Symbol("foo", [], "FILE", new DocComment("/**@see The other thing.*"+"/"));
                assertEqual(sym.see, "The other thing.", "@see tag, desc is found.");
            */
            
            // @class
            var classes = this.comment.getTag("class");
            if (classes.length) {
                //print(JSON.stringify(this,null,4));
                this.isa = "CONSTRUCTOR";
                this.classDesc = classes[0].desc; // desc can't apply to the constructor as there is none.
                if (!this.classDesc) {
                    this.classDesc = this.desc;
                   }
                
                
            }
            
            /*~t
                var sym = new Symbol("foo", [], "OBJECT", new DocComment("/**@class This describes the class.*"+"/"));
                assertEqual(sym.isa, "CONSTRUCTOR", "@class tag, makes symbol a constructor.");
                assertEqual(sym.classDesc, "This describes the class.", "@class tag, class description is found.");
            */
            
            // @namespace
            var namespaces = this.comment.getTag("namespace");
            if (namespaces.length) {
                this.classDesc = namespaces[0].desc+"\n"+this.desc; // desc can't apply to the constructor as there is none.
                this.isNamespace = true;
            }
            
            /*~t
                var sym = new Symbol("foo", [], "OBJECT", new DocComment("/**@namespace This describes the namespace.*"+"/"));
                assertEqual(sym.classDesc, "This describes the namespace.\n", "@namespace tag, class description is found.");
            */
            
            // @param
            var params = this.comment.getTag("param");
            if (params.length) {
                // user-defined params overwrite those with same name defined by the parser
                var thisParams = this.getParams();

                if (thisParams.length == 0) { // none exist yet, so just bung all these user-defined params straight in
                    this.setParams(params);
                }
                else { // need to overlay these user-defined params on to existing parser-defined params
                    for (var i = 0, l = params.length; i < l; i++) {
                        if (thisParams[i]) {
                            if (params[i].type) thisParams[i].type = params[i].type;
                            thisParams[i].name = params[i].name;
                            thisParams[i].desc = params[i].desc;
                            thisParams[i].isOptional = params[i].isOptional;
                            thisParams[i].defaultValue = params[i].defaultValue;
                        }
                        else thisParams[i] = params[i];
                    }
                }
            }
            
            /*~t
                var sym = new Symbol("foo", [{type: "array", name: "pages"}], "FUNCTION", new DocComment("/**Description.*"+"/"));
                assertEqual(sym.params.length, 1, "parser defined param is found.");
                
                sym = new Symbol("foo", [], "FUNCTION", new DocComment("/**Description.\n@param {array} pages*"+"/"));
                assertEqual(sym.params.length, 1, "user defined param is found.");
                assertEqual(sym.params[0].type, "array", "user defined param type is found.");
                assertEqual(sym.params[0].name, "pages", "user defined param name is found.");
                
                sym = new Symbol("foo", [{type: "array", name: "pages"}], "FUNCTION", new DocComment("/**Description.\n@param {string} uid*"+"/"));
                assertEqual(sym.params.length, 1, "user defined param overwrites parser defined param.");
                assertEqual(sym.params[0].type, "string", "user defined param type overwrites parser defined param type.");
                assertEqual(sym.params[0].name, "uid", "user defined param name overwrites parser defined param name.");
            
                sym = new Symbol("foo", [{type: "array", name: "pages"}, {type: "number", name: "count"}], "FUNCTION", new DocComment("/**Description.\n@param {string} uid*"+"/"));
                assertEqual(sym.params.length, 2, "user defined params  overlay parser defined params.");
                assertEqual(sym.params[1].type, "number", "user defined param type overlays parser defined param type.");
                assertEqual(sym.params[1].name, "count", "user defined param name overlays parser defined param name.");

                sym = new Symbol("foo", [], "FUNCTION", new DocComment("/**Description.\n@param {array} pages The pages description.*"+"/"));
                assertEqual(sym.params.length, 1, "user defined param with description is found.");
                assertEqual(sym.params[0].desc, "The pages description.", "user defined param description is found.");
            */
            
            // @constructor
            if (this.comment.getTag("constructor").length) {
                this.isa = "CONSTRUCTOR";
            }
            
            /*~t
                var sym = new Symbol("foo", [], "OBJECT", new DocComment("/**@constructor*"+"/"));
                assertEqual(sym.isa, "CONSTRUCTOR", "@constructor tag, makes symbol a constructor.");
            */
            
            // @static
            if (this.comment.getTag("static").length) {
                this.isStatic = true;
                if (this.isa == "CONSTRUCTOR") {
                    this.isNamespace = true;
                }
            }
            
                // @static
            if (this.comment.getTag("singleton").length) {
                this.isStatic = true;
                //print('------------- got singleton ---------------' + this.isa);
                //if (this.isa == "CONSTRUCTOR") {
                //	this.isNamespace = true;
                //}
            }
            
            
            
            /*~t
                var sym = new Symbol("foo", [], "OBJECT", new DocComment("/**@static\n@constructor*"+"/"));
                assertEqual(sym.isStatic, true, "@static tag, makes isStatic true.");
                assertEqual(sym.isNamespace, true, "@static and @constructor tag, makes isNamespace true.");
            */
            
            // @inner
            if (this.comment.getTag("inner").length) {
                this.isInner = true;
                this.isStatic = false;
            }
            
            /*~t
                var sym = new Symbol("foo", [], "OBJECT", new DocComment("/**@inner*"+"/"));
                assertEqual(sym.isStatic, false, "@inner tag, makes isStatic false.");
                assertEqual(sym.isInner, true, "@inner makes isInner true.");
            */
            
            // @field
            if (this.comment.getTag("field").length) {
                this.isa = "OBJECT";
            }
            
            /*~t
                var sym = new Symbol("foo", [], "FUNCTION", new DocComment("/**@field*"+"/"));
                assertEqual(sym.isa, "OBJECT", "@field tag, makes symbol an object.");
            */
            
            // @function
            if (this.comment.getTag("function").length) {
                this.isa = "FUNCTION";
            }
            
            // @param
            if (this.comment.getTag("param").length && this.isa == "OBJECT" ) {
                // change a property to a function..
                this.isa = "FUNCTION";
            }
            
            
            /*~t
                var sym = new Symbol("foo", [], "OBJECT", new DocComment("/**@function*"+"/"));
                assertEqual(sym.isa, "FUNCTION", "@function tag, makes symbol a function.");
            */
            
            // @event
            var events = this.comment.getTag("event");
            if (events.length) {
                this.isa = "FUNCTION";
                this.isEvent = true;
            }
            
            /*~t
                var sym = new Symbol("foo", [], "OBJECT", new DocComment("/**@event*"+"/"));
                assertEqual(sym.isa, "FUNCTION", "@event tag, makes symbol a function.");
                assertEqual(sym.isEvent, true, "@event makes isEvent true.");
            */
            
            // @name
            var names = this.comment.getTag("name");
            if (names.length) {
                this.setName(names[0].desc);
            }
            
            /*~t
                // todo
            */
            
            // @property
            var properties = this.comment.getTag("property");
            if (properties.length) {
                thisProperties = this.properties;
                for (var i = 0; i < properties.length; i++) {
                    var property = new Symbol(this.alias+"#"+properties[i].name, [], "OBJECT", new DocComment("/**"+properties[i].desc+"\n@name "+properties[i].name+"\n@memberOf "+this.alias+"#*/"));
                    // TODO: shouldn't the following happen in the addProperty method of Symbol?
                    property.name = properties[i].name;
                    property.memberOf = this.alias;
                    if (properties[i].type) property.type = properties[i].type;
                    if (properties[i].defaultValue) property.defaultValue = properties[i].defaultValue;
                    this.addProperty(property);
                    imports.Parser.Parser.addSymbol(property);
                }
            }
            
            // config..
            var conf = this.comment.getTag("cfg");
            if (conf.length) {
                for (var i = 0; i < conf.length; i++) {
                    this.addConfig(conf[i]);
                }
            }
            
            /*~t
                // todo
            */

            // @return
            var returns = this.comment.getTag("return");
            if (returns.length) { // there can be many return tags in a single doclet
                this.returns = returns;
                this.type = returns.map(function($){return $.type}).join(", ");
            }
            
            /*~t
                // todo
            */
            
            // @exception
            this.exceptions = this.comment.getTag("throws");
            
            /*~t
                // todo
            */
            
            // @requires
            var requires = this.comment.getTag("requires");
            if (requires.length) {
                this.requires = requires.map(function($){return $.desc});
            }
            
            /*~t
                // todo
            */
            
            // @type
            var types = this.comment.getTag("type");
            if (types.length) {
                this.type = types[0].desc; //multiple type tags are ignored
            }
            
            /*~t
                // todo
            */
            
            // @private
            if (this.comment.getTag("private").length || this.isInner) {
                this.isPrivate = true;
            }
            
            // @ignore
            if (this.comment.getTag("ignore").length) {
                this.isIgnored = true;
            }
            
            /*~t
                // todo
            */
            
            // @inherits ... as ...
            var inherits = this.comment.getTag("inherits");
            if (inherits.length) {
                for (var i = 0; i < inherits.length; i++) {
                    if (/^\s*([a-z$0-9_.#-]+)(?:\s+as\s+([a-z$0-9_.#]+))?/i.test(inherits[i].desc)) {
                        var inAlias = RegExp.$1;
                        var inAs = RegExp.$2 || inAlias;

                        if (inAlias) inAlias = inAlias.replace(/\.prototype\.?/g, "#");
                        
                        if (inAs) {
                            inAs = inAs.replace(/\.prototype\.?/g, "#");
                            inAs = inAs.replace(/^this\.?/, "#");
                        }

                        if (inAs.indexOf(inAlias) != 0) { //not a full namepath
                            var joiner = ".";
                            if (this.alias.charAt(this.alias.length-1) == "#" || inAs.charAt(0) == "#") {
                                joiner = "";
                            }
                            inAs = this.alias + joiner + inAs;
                        }
                    }
                    this.inherits.push({alias: inAlias, as: inAs});
                }
            }
            
            /*~t
                // todo
            */

            // @augments
            this.augments = this.comment.getTag("augments");
            
            //@extends - Ext
            if (this.comment.getTag("extends")) {   
                this.augments = this.comment.getTag("extends");
            }
            
            
            // @default
            var defaults = this.comment.getTag("default");
            if (defaults.length) {
                if (this.is("OBJECT")) {
                    this.defaultValue = defaults[0].desc;
                }
            }
            
            /*~t
                // todo
            */
            
            // @memberOf
            var memberOfs = this.comment.getTag("memberOf");
            if (memberOfs.length) {
                this.memberOf = memberOfs[0].desc;
                this.memberOf = this.memberOf.replace(/\.prototype\.?/g, "#");
                this.name = this.name.split('.').pop();
                this.name = this.name.split('#').pop();
                this.name = this.memberOf + this.name;
                this._name = this.name
                this.alias = this.name;
            }

            /*~t
                // todo
            */
            
            // @public
            if (this.comment.getTag("public").length) {
                this.isPrivate = false;
            }
            
            /*~t
                // todo
            */
        },

        is : function(what) {
            return this.isa === what;
        },

        isBuiltin : function() {
            return SymbolSet.isBuiltin(this.alias);
        },

        setType : function(/**String*/comment, /**Boolean*/overwrite) {
            if (!overwrite && this.type) return;
            var typeComment = DocComment.unwrapComment(comment);
            this.type = typeComment;
        },

        inherit : function(symbol) {
            if (!this.hasMember(symbol.name) && !symbol.isInner) {
                if (symbol.is("FUNCTION"))
                    this.methods.push(symbol);
                else if (symbol.is("OBJECT"))
                    this.properties.push(symbol);
            }
        },

        hasMember : function(name) {
            return (this.hasMethod(name) || this.hasProperty(name));
        },

        addMember : function(symbol) {
            //println("ADDMEMBER: " + this.name +  " ++ " + symbol.name);
            
            if (symbol.comment.getTag("cfg").length == 1) { 
                symbol.comment.getTag("cfg")[0].memberOf = this.alias;
                this.addConfig(symbol.comment.getTag("cfg")[0]);
                return;
            }
            
            if (symbol.is("FUNCTION")) { this.addMethod(symbol); }
            else if (symbol.is("OBJECT")) { this.addProperty(symbol); }
        },

        hasMethod : function(name) {
            var thisMethods = this.methods;
            for (var i = 0, l = thisMethods.length; i < l; i++) {
                if (thisMethods[i].name == name) return true;
                if (thisMethods[i].alias == name) return true;
            }
            return false;
        },

        addMethod : function(symbol) {
            var methodAlias = symbol.alias;
            var thisMethods = this.methods;
            for (var i = 0, l = thisMethods.length; i < l; i++) {
                if (thisMethods[i].alias == methodAlias) {
                    thisMethods[i] = symbol; // overwriting previous method
                    return;
                }
            }
            thisMethods.push(symbol); // new method with this alias
        },

        hasProperty : function(name) {
            var thisProperties = this.properties;
            for (var i = 0, l = thisProperties.length; i < l; i++) {
                if (thisProperties[i].name == name) return true;
                if (thisProperties[i].alias == name) return true;
            }
            return false;
        },

        addProperty : function(symbol) {
            var propertyAlias = symbol.alias;
            var thisProperties = this.properties;
            for (var i = 0, l = thisProperties.length; i < l; i++) {
                if (thisProperties[i].alias == propertyAlias) {
                    thisProperties[i] = symbol; // overwriting previous property
                    return;
                }
            }

            thisProperties.push(symbol); // new property with this alias
        },
        
        addDocTag : function(docTag)
        {
            this.comment.tags.push(docTag);
            if (docTag.title == 'cfg') {
                this.addConfig(docTag);
            }
            
        },
        
        addConfig : function(docTag)
        {
            if (typeof(docTag['memberOf']) == 'undefined') {
                // remove prototype data...
                //var a = this.alias.split('#')[0];
                //docTag.memberOf = a;
                docTag.memberOf = this.alias;
            }
            if (typeof(this.cfgs[docTag.name]) == 'undefined') {
                this.cfgs[docTag.name] = docTag;
            }
            
        },
        configToArray: function()
        {
            var r = [];
            for(var ci in this.cfgs) {
                // dont show hidden!!
                if (this.cfgs[ci].desc.match(/@hide/)) {
                    continue;
                }
                r.push(this.cfgs[ci]); 
               
            }
            return r;
        }
});

/**
 * Elements that are not serialized
 * 
 */
Symbol.hide = [ 
    '$args' // not needed AFAIK
]

Symbol.srcFile = ""; //running reference to the current file being parsed


Symbol.fromDump = function(t)
{
    var ns = new Symbol();
    for (var i in t) {
        if (typeof(ns[i]) == "undefined") {
            println("ERR:no default for Symbol:"+ i);
        }
        ns[i] = t[i];
    }
    return ns;
}
