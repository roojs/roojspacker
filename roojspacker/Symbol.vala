 
/**
	Create a new Symbol.
	@class Represents a symbol in the source code.
 */

 
namespace JSDOC {


	public  class Symbol : Object
	{
		// debugging?
		
		
		public static bool regex_init = false;
	 	

		private string private_string_name = "";
		private string _assigned_name = "";
		// called by symbolset...
		public string private_name {
    		set {
				this._assigned_name = name;
				var n = /^_global_[.#-]/.replace(value, value.length, 0, "");
		        n =  /\.prototype\.?/.replace(n,n.length, 0, "#");
		        while (true) {
		    		if (!n.has_suffix("#")) {
		    			break;
					}
					n = n.substring(0, n.length-1);
				}
			
		        this.private_string_name = n;
    		}
		
		}
		 
        public string name {
    		get { return this.private_string_name; }
		}
		
      
        string defaultValue = "";
        
		private Gee.ArrayList<DocTag> private_doctag_params = null;

		private Gee.ArrayList<DocTag> private_params{
			set  {
				if (this.private_doctag_params == null) {
					this.private_doctag_params = new Gee.ArrayList<DocTag>();
				}
				for (var i = 0; i < value.size; i++) {
				   
				    this.private_doctag_params.add(value.get(i));
				}
				//this.params = this._params;
			}
		}
     
		Gee.ArrayList<string> private_string_params{
			set  {
				if (this.private_doctag_params == null) {
					this.private_doctag_params = new Gee.ArrayList<DocTag>();
				}
				for (var i = 0; i < value.size; i++) {

				    //var ty = v[i].hasOwnProperty('type') ? v[i].type : '';
				    this.private_doctag_params.add( new DocTag(value.get(i)));
				           
				   //"param"+((ty)?" {"+ty+"}":"")+" "+v.get(i).name);
				    
				}
				
			}
		}
		public Gee.ArrayList<DocTag> params {
			get {
				if (this.private_doctag_params == null) {
					this.private_doctag_params = new Gee.ArrayList<DocTag>();
				}
				return this.private_doctag_params;
			}
		
		}

		public Gee.ArrayList<string>  augments ;  
		

		private Gee.ArrayList<DocTag>  exceptions ;

		//public Gee.ArrayList<DocTag>  inherits; 
		public Gee.ArrayList<Symbol>  methods;

		public Gee.ArrayList<Symbol> properties;
		private Gee.ArrayList<string> requires;
		public Gee.ArrayList<DocTag> returns;
		private Gee.ArrayList<string> see ;

 		public Gee.ArrayList<string> childClasses;
 		public Gee.ArrayList<string> inheritsFrom;
        public Gee.HashMap<string,DocTag>cfgs;
        
        
        public DocComment comment;
                
        //$args : [], // original arguments used when constructing.
        string addOn = "";
        public string alias = "";
        
        string author = "";
        string classDesc = "";

        string deprecated = "";
        public string desc = "";
        //events : false,
        string example = "";
        

        public string isa = "OBJECT"; // OBJECT//FUNCTION
        
        public bool isEvent = false;
        public bool isConstant = false;
        public bool isIgnored = false;
        public bool isInner = false;
        public bool isNamespace = false;
        public bool isPrivate = false;
        public bool isStatic = false;
        
        public string memberOf = "";

		public string asString()
		{
			return "NAME: %s:%s   ASNAME: %s : %s%s%s%s".printf(
				this.memberOf,
				this.name,
				this._assigned_name,
				isStatic ? "static": "",
				isEvent ? "EV": "",
				isConstant ? "CO": "",
				isNamespace ? "NS": ""
			);
				
		
		}

       
        string since = "";

        string type = "";
        string version = "";
       
        public static string srcFile = "";
        
        
        
        public void initArrays()
        {
            // only initialize arrays / objects..

            
            //this.params = [];
            //this.$args = [];
            
            //this.events = [];
            this.exceptions = new Gee.ArrayList<DocTag>();
            //this.inherits = new Gee.ArrayList<DocTag>();
            //
            this.isa = "OBJECT"; // OBJECT//FUNCTION
            this.methods = new Gee.ArrayList<Symbol>();
            //this.private_params = new Gee.ArrayList<DocTag>();
            this.properties = new Gee.ArrayList<Symbol>();
            this.requires = new Gee.ArrayList<string>();
            this.returns = new Gee.ArrayList<DocTag>();
            this.see = new Gee.ArrayList<string>();
            this.augments = new Gee.ArrayList<string>();
 
            
            this.cfgs = new Gee.HashMap<string,DocTag>();
            // derived later?
            this.inheritsFrom = new Gee.ArrayList<string>();

            this.childClasses = new Gee.ArrayList<string>();
             
            this.comment = new DocComment();
            this.comment.isUserComment =  false;
            
               
        }
		
		public Symbol.new_builtin(string name)
		{
            
            this.initArrays();
            this.srcFile = JSDOC.DocParser.currentSourceFile;
			this.private_name =  name ;
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
                DocComment comment
        ) {
           
            this.initArrays();
           // this.$args = arguments;
            //println("Symbol created: " + isa + ":" + name);
            this.private_name = name;
            this.alias = this.name;
            this.private_string_params = params; 
            this.isa = (isa == "VIRTUAL")? "OBJECT":isa;
            this.comment =  comment;
            
            this.srcFile = DocParser.currentSourceFile;
            
           
            
            if (this.is("FILE") && this.alias.length < 1) { // this will never hapen???
        		this.alias = this.srcFile;
    		}

            this.tagsFromComment();
            
        }

        void tagsFromComment() {
            // @author
            var authors = this.comment.getTag(DocTagTitle.AUTHOR);
            if (authors.size > 0) {
        		// turns author into a string....
        		this.author = "";
                foreach(var a in authors) {
                    this.author += (this.author == "") ? "": ", ";
                    this.author += a.desc;
                }
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
            var mth = this.comment.getTag(DocTagTitle.METHOD);
            if (mth.size  > 0) {
                this.isa = "FUNCTION";
            }
            // @desc
            var descs = this.comment.getTag(DocTagTitle.DESC);
            if (descs.size>  0) {
                this.desc = "";
                foreach(var d in descs) {
                    this.desc = this.desc == "" ? "": "\n";
                    this.desc += d.desc;
                }

            }
            
            /*~t
                var sym = new Symbol("foo", [], "OBJECT", new DocComment("/**@desc This is a description.*"+"/"));
                assertEqual(sym.desc, "This is a description.", "@desc tag, description is found.");
            */
            
            // @overview
            if (this.is("FILE")) {
                if (this.alias.length < 1) this.alias = this.srcFile;
                
                var overviews = this.comment.getTag(DocTagTitle.OVERVIEW);
                if (overviews.size > 0) {
                    foreach(var d in overviews) {
                        this.desc = this.desc == "" ? "": "\n";
                        this.desc += d.desc;
                    }
                }
            }
            
            /*~t
                var sym = new Symbol("foo", [], "FILE", new DocComment("/**@overview This is an overview.*"+"/"));
                assertEqual(sym.desc, "\nThis is an overview.", "@overview tag, description is found.");
            */
            
            // @since
            var sinces = this.comment.getTag(DocTagTitle.SINCE);
            if (sinces.size > 0) {
                this.since = "";
                foreach(var d in sinces) {
                    this.since = this.since == "" ? "": "\n";
                    this.since += d.desc;
                }
            }
            
            /*~t
                var sym = new Symbol("foo", [], "FILE", new DocComment("/**@since 1.01*"+"/"));
                assertEqual(sym.since, "1.01", "@since tag, description is found.");
            */
            
            // @constant
            if (this.comment.getTag(DocTagTitle.CONSTANT).size > 0) {
                this.isConstant = true;
                this.isa = "OBJECT";
            }
            
            /*~t
                var sym = new Symbol("foo", [], "FILE", new DocComment("/**@constant*"+"/"));
                assertEqual(sym.isConstant, true, "@constant tag, isConstant set.");
            */
            
            // @version
            var versions = this.comment.getTag(DocTagTitle.VERSION);
            if (versions.size > 0 ) {
                this.version = "";
                 foreach(var d in versions) {
                    this.version = this.version == "" ? "": "\n";
                    this.version += d.desc;
                }
            }
            
            /*~t
                var sym = new Symbol("foo", [], "FILE", new DocComment("/**@version 2.0x*"+"/"));
                assertEqual(sym.version, "2.0x", "@version tag, version is found.");
            */
            
            // @deprecated
            var deprecateds = this.comment.getTag(DocTagTitle.DEPRECATED);
            if (deprecateds.size > 0) {
                this.deprecated = "";
                 foreach(var d in deprecateds) {
                    this.deprecated = this.deprecated == "" ? "": "\n";
                    this.deprecated += d.desc;
                }
            }
            
            /*~t
                var sym = new Symbol("foo", [], "FILE", new DocComment("/**@deprecated Use other method.*"+"/"));
                assertEqual(sym.deprecated, "Use other method.", "@deprecated tag, desc is found.");
            */
            
            // @example
            var examples = this.comment.getTag(DocTagTitle.EXAMPLE);
            if (examples.size > 0) {
                this.example = examples.get(0).desc;
            }
            
            /*~t
                var sym = new Symbol("foo", [], "FILE", new DocComment("/**@example This\n  is an example.*"+"/"));
                assertEqual(sym.example, "This\n  is an example.", "@deprecated tag, desc is found.");
            */
            
            // @see
            var sees = this.comment.getTag(DocTagTitle.SEE);
            if (sees.size > 0) {
                 
                foreach(var s in sees) {
                    this.see.add(s.desc);
                }
          }
            
            /*~t
                var sym = new Symbol("foo", [], "FILE", new DocComment("/**@see The other thing.*"+"/"));
                assertEqual(sym.see, "The other thing.", "@see tag, desc is found.");
            */
            
            // @class
            var classes = this.comment.getTag(DocTagTitle.CLASS);
            if (classes.size > 0) {
                //print(JSON.stringify(this,null,4));
                this.isa = "CONSTRUCTOR";
                this.classDesc = classes[0].desc; // desc can't apply to the constructor as there is none.
                //if (!this.classDesc.leg) {
                //    this.classDesc = this.desc;
                //   }
                
                
            }
            
            /*~t
                var sym = new Symbol("foo", [], "OBJECT", new DocComment("/**@class This describes the class.*"+"/"));
                assertEqual(sym.isa, "CONSTRUCTOR", "@class tag, makes symbol a constructor.");
                assertEqual(sym.classDesc, "This describes the class.", "@class tag, class description is found.");
            */
            
            // @namespace
            var namespaces = this.comment.getTag(DocTagTitle.NAMESPACE);
            if (namespaces.size > 0) {
                this.classDesc = namespaces[0].desc+"\n"+this.desc; // desc can't apply to the constructor as there is none.
                this.isNamespace = true;
            }
            
            /*~t
                var sym = new Symbol("foo", [], "OBJECT", new DocComment("/**@namespace This describes the namespace.*"+"/"));
                assertEqual(sym.classDesc, "This describes the namespace.\n", "@namespace tag, class description is found.");
            */
            
            // @param
            var params = this.comment.getTag(DocTagTitle.PARAM);
            if (params.size > 0) {
                // user-defined params overwrite those with same name defined by the parser
                var thisParams = params;

                if (thisParams.size == 0) { // none exist yet, so just bung all these user-defined params straight in
                    this.private_params = params;
                }
                else { // need to overlay these user-defined params on to existing parser-defined params
                    for (var i = 0, l = params.size; i < l; i++) {
                        if (thisParams.size <= i) {
                        	var np = thisParams.get(i);
                        	
                            if (np.type.length > 0) np.type = params[i].type;
                            np.name = params[i].name;
                            np.desc = params[i].desc;
                            np.isOptional = params[i].isOptional;
                            np.defaultValue = params[i].defaultValue;
                            //thisParams.set(i, np); ///?? needed OO ?
                        }
                        else thisParams.set(i, params[i]);
                    }
                    this.private_params = thisParams;
                }
            }
            
            
            
            // @constructor
            if (this.comment.getTag(DocTagTitle.CONSTRUCTOR).size > 0) {
                this.isa = "CONSTRUCTOR";
            }
            
         
            
            // @static
            if (this.comment.getTag(DocTagTitle.STATIC).size > 0) {
                this.isStatic = true;
                if (this.isa == "CONSTRUCTOR") {
                    this.isNamespace = true;
                }
            }
            
                // @static
            if (this.comment.getTag(DocTagTitle.SINGLETON).size > 0) {
                this.isStatic = true;
                //print('------------- got singleton ---------------' + this.isa);
                //if (this.isa == "CONSTRUCTOR") {
                //	this.isNamespace = true;
                //}
            }
            
            
            
            // @inner
            if (this.comment.getTag(DocTagTitle.INNER).size > 0) {
                this.isInner = true;
                this.isStatic = false;
            }
            
            
            // @field
            if (this.comment.getTag(DocTagTitle.FIELD).size > 0) {
                this.isa = "OBJECT";
            }
            
           
            
            // @function
            if (this.comment.getTag(DocTagTitle.FUNCTION).size > 0) {
                this.isa = "FUNCTION";
            }
            
            // @param
            if (this.comment.getTag(DocTagTitle.PARAM).size > 0 && this.isa == "OBJECT" ) {
                // change a property to a function..
                this.isa = "FUNCTION";
            }
            
            
             
            
            // @event
            var events = this.comment.getTag(DocTagTitle.EVENT);
            if (events.size > 0) {
                this.isa = "FUNCTION";
                this.isEvent = true;
            }
            
            
            
            // @name
            var names = this.comment.getTag(DocTagTitle.NAME);
            if (names.size > 0) {
                this.private_name = names.get(0).desc.strip();
            }
            
            /*~t
                // todo
            */
            
            // @property
            var properties = this.comment.getTag(DocTagTitle.PROPERTY);
            if (properties.size > 0) {
                //var thisProperties = this.properties;
                for (var i = 0; i < properties.size; i++) {

 					
					// if the doc tag just says @property ... but no name etc..
					// then name will not be filled in..
					if (properties[i].name.length < 1 ) {
						continue;
					}

                    var property = new Symbol.new_populate_with_args(
                        this.alias+"#"+properties[i].name,
                         new Gee.ArrayList<string>(), 
                        "OBJECT",
                         new DocComment(
                            "/**\n"+
                            	properties[i].desc+
                        	"\n@name "+ properties[i].name
                        	+"\n@memberOf "+this.alias+"#*/"
                    ));
                    // TODO: shouldn't the following happen in the addProperty method of Symbol?
                    property.private_name = properties[i].name;
                    property.memberOf = this.alias;
                    if (properties[i].type.length > 0) property.type = properties[i].type;
                    if (properties[i].defaultValue.length > 0) property.defaultValue = properties[i].defaultValue;
                    this.addProperty(property);
                    JSDOC.DocParser.addSymbol(property);
                }
            }
            
            // config..
            var conf = this.comment.getTag(DocTagTitle.CFG);
            if (conf.size > 0) {
                for (var i = 0; i < conf.size; i++) {
                    this.addConfig(conf.get(i));
                }
            }
            
          

            // @return
            var returns = this.comment.getTag(DocTagTitle.RETURN);
            if (returns.size > 0) { // there can be many return tags in a single doclet
                this.returns = returns;

                this.type = "";
                foreach(var r in returns) {
                    this.type += this.type == "" ? "": ", ";
                    this.type += r.type;
                } 
             }
            
            
            
            // @exception
            this.exceptions = this.comment.getTag(DocTagTitle.THROWS);
            
           
            // @requires
            var requires = this.comment.getTag(DocTagTitle.REQUIRES);
            if (requires.size > 0) {
                this.requires = new Gee.ArrayList<string>();
                foreach(var r in requires) {
                    this.requires.add(r.desc);
                }
            }
           
            
            // @type
            var types = this.comment.getTag(DocTagTitle.TYPE);
            if (types.size > 0) {
                this.type = types.get(0).desc; //multiple type tags are ignored
            }
            
            
            
            // @private
            if (this.comment.getTag(DocTagTitle.PRIVATE).size > 0 || this.isInner) {
                this.isPrivate = true;
            }
            
            // @ignore
            if (this.comment.getTag(DocTagTitle.IGNORE).size > 0) {
                this.isIgnored = true;
            }
            
            /*~t
                // todo
            */
            
            // @inherits ... as ... -- not used!!!
            /*
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
            */
            /*~t
                // todo
            */

            // @augments
            foreach(var dt in this.comment.getTag(DocTagTitle.ARGUMENTS)) {
            	this.augments.add(dt.desc);
        	}
            //@extends - Ext        	
            foreach(var dt in this.comment.getTag(DocTagTitle.EXTENDS)) {
            	this.augments.add(dt.desc);
        	}
            
            
            
            // @default
            var defaults = this.comment.getTag(DocTagTitle.DEFAULT);
            if (defaults.size > 0) {
                if (this.is("OBJECT")) {
                    this.defaultValue = defaults.get(0).desc;
                }
            }
            
            /*~t
                // todo
            */
            
            // @memberOf
            var memberOfs = this.comment.getTag(DocTagTitle.MEMBEROF);
            if (memberOfs.size > 0) {
                this.memberOf = memberOfs[0].desc;
                var pr_reg = /\.prototype\.?/;
                
                this.memberOf = pr_reg.replace(this.memberOf, this.memberOf.length, 0, "#");
                var dname = this.name.split(".");
                var name = dname[dname.length-1];
                
                var hname = name.split("#");
                name = hname[hname.length-1];
                this.private_name = this.memberOf + "." + name; //?? "." ???
                this.alias = this.name;
            }

            /*~t
                // todo
            */
             
            // @public
            if (this.comment.getTag(DocTagTitle.PUBLIC).size > 0) {
                this.isPrivate = false;
            }
            
            /*~t
                // todo
            */
        }

        public bool is (string what) {
            return this.isa == what;
        }
        public bool isaClass()
        {
        
	        return (this.is("CONSTRUCTOR") || this.isNamespace ); //|| this.isClass); 
        }
        
 
        public bool isBuiltin() {
            return SymbolSet.isBuiltin(this.alias);
        }

        void setType(string comment,bool overwrite) {
            if (!overwrite && this.type.length > 0) {
            	 return;
        	 }
            var typeComment = DocComment.unwrapComment(comment);
            this.type = typeComment;
        }

        public void inherit (Symbol symbol) {
            if (!this.hasMember(symbol.name) && !symbol.isInner) {
                if (symbol.is("FUNCTION"))
                    this.methods.add(symbol);
                else if (symbol.is("OBJECT"))
                    this.properties.add(symbol);
            }
        }

        bool hasMember (string name) {
            return (this.hasMethod(name) || this.hasProperty(name));
        }

        public void addMember (Symbol symbol) {
            //println("ADDMEMBER: " + this.name +  " ++ " + symbol.name);
            
            if (symbol.comment.getTag(DocTagTitle.CFG).size == 1) { 
                symbol.comment.getTag(DocTagTitle.CFG).get(0).memberOf = this.alias;
                this.addConfig(symbol.comment.getTag(DocTagTitle.CFG).get(0));
                return;
            }
            
            if (symbol.is("FUNCTION")) { this.addMethod(symbol); }
            else if (symbol.is("OBJECT")) { this.addProperty(symbol); }
        }

        bool hasMethod (string name) {
            var thisMethods = this.methods;
            for (var i = 0, l = thisMethods.size; i < l; i++) {
                if (thisMethods.get(i).name == name) return true;
                if (thisMethods.get(i).alias == name) return true;
            }
            return false;
        }

        void addMethod (Symbol symbol) {
            var methodAlias = symbol.alias;
            var thisMethods = this.methods;
            for (var i = 0, l = thisMethods.size; i < l; i++) {
                if (thisMethods.get(i).alias == methodAlias) {
                    thisMethods.set(i, symbol); // overwriting previous method
                    return;
                }
            }
            thisMethods.add(symbol); // new method with this alias
        }

        bool hasProperty(string name) {
            var thisProperties = this.properties;
            for (var i = 0, l = thisProperties.size; i < l; i++) {
                if (thisProperties.get(i).name == name) return true;
                if (thisProperties.get(i).alias == name) return true;
            }
            return false;
        }

        void addProperty(Symbol symbol) {
            var propertyAlias = symbol.alias;
            var thisProperties = this.properties;
            for (var i = 0, l = thisProperties.size; i < l; i++) {
                if (thisProperties.get(i).alias == propertyAlias) {
                    thisProperties.set(i, symbol); // overwriting previous property
                    return;
                }
            }

            thisProperties.add(symbol); // new property with this alias
        }
        
        public void addDocTag(DocTag docTag)
        {
            this.comment.tags.add(docTag);
            if (docTag.title == DocTagTitle.CFG) {
                this.addConfig(docTag);
            }
             
        }
        
        public void addConfig(DocTag docTag)
        {
            if (docTag.memberOf == "") {
                // remove prototype data...
                //var a = this.alias.split('#')[0];
                //docTag.memberOf = a;
                docTag.memberOf = this.alias;
            }
            if (!this.cfgs.has_key(docTag.name)) {
                this.cfgs.set(docTag.name,  docTag);
            }
            
        }
         
        public Gee.ArrayList<DocTag> configToArray()
        {
            var r = new  Gee.ArrayList<DocTag>();
            foreach(var ci in this.cfgs.keys) {
                // dont show hidden!!
                if (this.cfgs.get(ci).desc.contains("@hide")) {
                    continue;
                }
                r.add(this.cfgs.get(ci)); 
               
            }
            return r;
        }
        
	
		
		public string makeFuncSkel() {
		    if (this.params.size < 1) return "function ()\n{\n\n}";
			var ret = "function (";
			var f = false;
			foreach(var p in this.params) {
				if (p.name.contains(".")) continue;
				ret += f ? ", " : "";
				f = true;
				ret +=  p.name == "this" ? "_self" : p.name;
			}
			return ret + ")\n{\n\n}";
		}
		public string makeMethodSkel() {
		    if (this.params.size < 1) return "()\n{\n\n}";
			var ret = "(";
			var f = false;
			foreach(var p in this.params) {
				GLib.debug("got param: %s", p.asString());
				if (p.name.contains(".")) continue;
				ret += f ? ", " : "";
				f = true;
				switch(p.name) {
					case "this" : ret += "this"; break;
					case "function" : ret += "function() {\n\n}"; break;					
					default : ret += p.name; break;
				}
			}
			return ret + ")";
		}
		
		public Json.Array paramsToJson()
		{
			var ret = new Json.Array();
			foreach(var p in this.params) {
				//GLib.debug("got param: %s", p.asString());
				if (p.name.contains(".")) continue;// ?? why?				
				var add = new Json.Object();
				add.set_string_member("name",p.name);				
				add.set_string_member("type",p.type);
				add.set_string_member("desc",p.desc);
				add.set_boolean_member("isOptional",p.isOptional);
				ret.add_object_element(add) ;
			}
			 
			return ret;
		
		}
    	public Json.Array returnsToJson()
		{
			var ret = new Json.Array();
			foreach(var p in this.returns) {
				//GLib.debug("got param: %s", p.asString());
				if (p.name.contains(".")) continue;// ?? why?				
				var add = new Json.Object();
				add.set_string_member("name",p.name);				
				add.set_string_member("type",p.type);
				add.set_string_member("desc",p.desc);
		 
				ret.add_object_element(add) ;
			}
			 
			return ret;
		
		}
 	}
 
	
	
	//static string[] hide = { "$args" };
	//static string srcFile = "";
	 
}


/*
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
*/
