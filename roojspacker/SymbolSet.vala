 
namespace JSDOC {

	public class SymbolSet  : Object {

		private Gee.HashMap<string,Symbol> __index = null;
		
		
		public Json.Object toJson()
		{
			var ret = new Json.Object();
			 foreach(var k in this._index.keys) {
            	ret.set_object_member(k, this._index.get(k).toJson());
        	}
        	return ret;
		}
		
		
		public Gee.HashMap<string,Symbol> _index {
			get {
				if (this.__index == null) {
					GLib.debug("Creating new Symbolset array");
					this.__index = new Gee.HashMap<string,Symbol>();
				}
				return this.__index;
			}
		}
		// CTOR - do nothing..?
		public SymbolSet ()
		{

		}
		 

        public Gee.ArrayList<string> keys() 
        {
            var  r= new Gee.ArrayList<string>();
            foreach(var k in this._index.keys) {
            	r.add(k);
        	}
        	return r;

        }
    	 public Gee.ArrayList<Symbol> values() 
        {
            var  r= new Gee.ArrayList<Symbol>();
            foreach(var k in this._index.values) {
            	r.add(k);
        	}
        	return r;

        }

        public bool hasSymbol(string alias) 
        {
            return this._index.has_key(alias);
            //return this.keys().indexOf(alias) > -1;
        }

        public void addSymbol (Symbol symbol) {
             GLib.debug("ADDING SYMBOL: %s",symbol.alias);
            
             
            if (this.hasSymbol(symbol.alias)) {
                GLib.warning("Overwriting symbol documentation for: %s.",symbol.alias);
            }
            this._index.set(symbol.alias,  symbol);
        }

        public Symbol? getSymbol (string alias) {
            
            if (this.hasSymbol(alias)) return this._index.get(alias);
            return null;
        }
/*/
        toArray : function() {
            var found = [];
            for (var p in this._index) {
                found.push(this._index[p]);
            }
            return found;
        },
        */
        /**
         * for serializing
         *
        toJSON : function() {
            return {
                '*object' : 'SymbolSet',
                _index : this._index
            };
            
        },
*/

        public void deleteSymbol  (string alias) {
            if (!this.hasSymbol(alias)) return;
            this._index.unset(alias);
        } 

        public string renameSymbol (string oldName, string newName) {
            // todo: should check if oldname or newname already exist
            if (!this.hasSymbol(oldName)) {
                GLib.error("Cant rename " + oldName + " to " + newName + " As it doesnt exist");
            } 
            this._index.set(newName, this._index.get(oldName));
            this.deleteSymbol(oldName);
            this._index.get(newName).alias = newName;
            return newName;
        }

        public void relate() 
        {
            GLib.debug("RELATE called");
            foreach(var s in this._index.keys) {
            	GLib.debug("%s", this._index.get(s).asString());
        	}
            this.resolveBorrows();
            this.resolveMemberOf();
            this.resolveAugments();
			 GLib.debug("AFTER RELATE called");
          	foreach(var s in this._index.keys) {
            	GLib.debug("%s", this._index.get(s).asString());
        	}
        }

        void resolveBorrows() 
        {

            return; // this code is not needed- we do not use @inherits
            /*
            foreach (var p in this._index.keys) {
                var symbol = this._index.get(p);
                
                
                
                if (symbol.is("FILE") || symbol.is("GLOBAL")) continue;
                
                var borrows = symbol.inherits;
                for (var i = 0; i < borrows.size; i++) {
                    var borrowed = this.getSymbol(borrows.get(i).alias);
                    if (!borrowed) {
                        imports.BuildDocs.Options.LOG.warn("Can't borrow undocumented "+borrows[i].alias+".");
                        continue;
                    }
                    
                    var borrowAsName = borrows[i].as;
                    var borrowAsAlias = borrowAsName;
                    if (!borrowAsName) {
                        imports.BuildDocs.Options.LOG.warn("Malformed @borrow, 'as' is required.");
                        continue;
                    }
                    
                    if (borrowAsName.length > symbol.alias.length && borrowAsName.indexOf(symbol.alias) == 0) {
                        borrowAsName = borrowAsName.replace(borrowed.alias, "");
                    }
                    else {
                        var joiner = "";
                        if (borrowAsName.charAt(0) != "#") joiner = ".";
                        borrowAsAlias = borrowed.alias + joiner + borrowAsName;
                    }
                    
                    borrowAsName = borrowAsName.replace(/^[#.]/, "");
                            
                    if (this.hasSymbol(borrowAsAlias)) continue;

                    var clone = borrowed.clone();
                    clone.name = borrowAsName;
                    clone.alias = borrowAsAlias;
                    this.addSymbol(clone);
                }
            }
			*/
        }

        void resolveMemberOf () 
        {
            if (this._index.keys.size < 1) {
	            return;
            }
            foreach (var p in this.keys()) {
                var symbol = this.getSymbol(p);
                
                if (symbol.is("FILE") || symbol.is("GLOBAL")) continue;
                
                // the memberOf value was provided in the @memberOf tag
                else if (symbol.memberOf.length > 0) {
                	var regex = new GLib.Regex("^("+symbol.memberOf+"[.#-])(.+)$");
                	GLib.MatchInfo minfo;
                    var parts = regex.match_full(symbol.alias, -1, 0, 0 , out minfo);
                    
                    // like foo.bar is a memberOf foo
                    if (parts) {                    	 
                    		
                        symbol.memberOf = minfo.fetch(1);
                        symbol.private_name = minfo.fetch(2);
                    }
                    // like bar is a memberOf foo
                    else {
                        var joiner = symbol.memberOf.substring(symbol.memberOf.length-1);
                        if (!/[.#-]/.match(joiner)) symbol.memberOf += ".";
                        
                        this.renameSymbol(p, symbol.memberOf + symbol.name);
                    }
                }
                // the memberOf must be calculated
                else {
                	GLib.MatchInfo minfo;                
                    var parts = /^(.*[.#-])([^.#-]+)$/.match_full(symbol.alias, -1, 0, 0 , out minfo);

                    if (parts) {
                        symbol.memberOf = minfo.fetch(1);
                        symbol.private_name = minfo.fetch(2);
                    }
                }

                // set isStatic, isInner
                if (symbol.memberOf.length > 0) {
                    switch (symbol.memberOf[symbol.memberOf.length-1]) {
                        case '#' :
                            symbol.isStatic = false;
                            symbol.isInner = false;
                            break;
                            
                        case '.' :
                            symbol.isStatic = true;
                            symbol.isInner = false;
                            break;
                            
                        case '-' :
                            symbol.isStatic = false;
                            symbol.isInner = true;
                            break;
                            
                    }
                }
                 
                // unowned methods and fields belong to the global object
                if (!symbol.is("CONSTRUCTOR") && !symbol.isNamespace && symbol.memberOf == "") {
                    symbol.memberOf = "_global_";
                }
                
                // clean up
                if (/[.#-]$/.match(symbol.memberOf)) {
                    symbol.memberOf = symbol.memberOf.substring(0, symbol.memberOf.length-1);
                }
                //print("looking for memberOf: " + symbol.memberOf + " FOR " + symbol.alias);
                // add to parent's methods or properties list
                if (symbol.memberOf.length > 0) {
                    var container = this.getSymbol(symbol.memberOf);
                    if (container == null) {
                        if (SymbolSet.isBuiltin(symbol.memberOf)) {
                            container = DocParser.addBuiltin(symbol.memberOf);
                        }
                        else {
                           // print("symbol NOT a BUILT IN - createing a container");
                            // Eg. Ext.y.z (missing y)
                            // we need to add in the missing symbol...
                            container = new Symbol.new_populate_with_args(
                            	symbol.memberOf, new Gee.ArrayList<string>(), 
                        			"OBJECT", new DocComment(""));
                            container.isNamespace = true;
                            this.addSymbol( container );
                           // print(container.toSource());
                            //container = this.getSymbol(symbol.memberOf);
                            // fake container ... so dont ad symbols to it..
                            continue;
                            container = null;
                            //LOG.warn("Can't document "+symbol.name +" as a member of undocumented symbol "+symbol.memberOf+".");
                            //LOG.warn("We only have the following symbols: \n" + 
                            //    this.keys.toSource());
                        }
                    }
                    
                    if (container != null && !container.isNamespace) {
                    	 container.addMember(symbol);
                	 }
                }
            }

        }

        void resolveAugments () 
    	{
            // does this sort out multiple extends???
            
            foreach (var p in this._index.keys) {
                var symbol = this.getSymbol(p);
                this.buildAugmentsList(symbol); /// build heirachy of inheritance...
                if (symbol.alias == "_global_" || symbol.is("FILE")) continue;
                
                var augments = symbol.augments;
                for(var ii = 0, il = augments.size; ii < il; ii++) {
                    var contributer = this.getSymbol(augments[ii]);
                    
                     
                    if (contributer != null) {
                        contributer.childClasses.add(symbol.alias);
                        symbol.inheritsFrom.add(contributer.alias);
                        //if (!isUnique(symbol.inheritsFrom)) {
                        //    imports.BuildDocs.Options.LOG.warn("Can't resolve augments: Circular reference: "+symbol.alias+" inherits from "+contributer.alias+" more than once.");
                        //}
                        //else {
                            var cmethods = contributer.methods;
                            var cproperties = contributer.properties;
                            var cfgs = contributer.cfgs;
                            for (var ci = 0, cl = cmethods.size; ci < cl; ci++) {   
                                symbol.inherit(cmethods[ci]);
                            } 
                            for (var ci = 0, cl = cproperties.size; ci < cl; ci++) {
                                symbol.inherit(cproperties[ci]);
                            }
                            foreach (var ci in cfgs.keys) {
                                symbol.addConfig(cfgs[ci]);
                            }
                            
                                
                        //}
                    }
                    else {
                        GLib.warning("Can't augment contributer: '%s', not found. FOR: %s",
	                        augments[ii], symbol.alias
                        );
                        //LOG.warn("We only have the following symbols: \n" + 
                          //      this.keys().toSource().split(",").join(",    \n"));
                       }
	
                }
            }
            
        }


		 void addAugments (Symbol symbol, Gee.ArrayList<string> alist, bool forceit) 
		 { // returns number added..
                if (alist.size < 1) {
                    return;
                }
                //print("buildAugmentsList:addAugments" + alist.length);
                //var rval = 0;
                for(var ii = 0; ii < alist.size; ii++) {
                    //print("getAlias:" + alist[ii]);
                    if (alist[ii] == symbol.alias) {
                        continue;
                    }
                    var contributer = this.getSymbol(alist[ii]);
                    if (contributer == null) {
                        continue;
                    }
                    
                    if (!forceit && symbol.augments.contains(alist[ii])) {
                        continue;
                    }
                    if (symbol.augments.index_of(alist[ii]) < 0) {
                        symbol.augments.add(alist[ii]);
                    }
                        
                    
                    this.addAugments(symbol, contributer.augments,false);
                    
                    //rval++;
                }
               // print("buildAugmentsList: ADDED:" + rval);
               // return rval;
            }

        void buildAugmentsList (Symbol symbol)
        {
	        
	        this.addAugments(symbol, symbol.augments, true);
	        
            
            
        }
        public static bool isBuiltin(string name)
		{
			for (var i =0 ; i < SymbolSet.coreObjects.length; i++ ){ 
				if (name ==  SymbolSet.coreObjects[i]) {
					return true;
				}
			}
			return false;
		}
		static string[] coreObjects  = {
			"_global_", "Array" , "Boolean", "Date", "Function", 
			    "Math", "Number", "Object", "RegExp", "String"
		};
         
	}
	
}

 