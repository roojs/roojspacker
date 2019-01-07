 
namespace JSDOC {

	public class SymbolSet  : Object {

		Gee.HashMap<string,Symbol> _index;
		
		public SymbolSet ()
		{
			this._index = new Gee.HashMap<string,Symbol>();

		}

        public Gee.ArrayList<string> keys() 
        {
            this._index.keys;
        }


        public bool hasSymbol(string alias) 
        {
            return this._index.hasKey(alias);
            //return this.keys().indexOf(alias) > -1;
        }

        public void addSymbol (Symbol symbol) {
            //print("ADDING SYMBOL:"+symbol.alias.toString());
            
            
            if (this.hasSymbol(symbol.alias)) {
                GLib.warn("Overwriting symbol documentation for: %s.",symbol.alias);
            }
            this._index[symbol.alias] = symbol;
        },

        getSymbol : function(alias) {
            
            if (this.hasSymbol(alias)) return this._index[alias];
            return false;
        },

        toArray : function() {
            var found = [];
            for (var p in this._index) {
                found.push(this._index[p]);
            }
            return found;
        },
        /**
         * for serializing
         */
        toJSON : function() {
            return {
                '*object' : 'SymbolSet',
                _index : this._index
            };
            
        },


        deleteSymbol : function(alias) {
            if (!this.hasSymbol(alias)) return;
            delete this._index[alias];
        },

        renameSymbol : function(oldName, newName) {
            // todo: should check if oldname or newname already exist
            if (typeof(this._index[oldName]) == "undefined") {
                throw "Cant rename " + oldName + " to " + newName + " As it doesnt exist";
               }
            this._index[newName] = this._index[oldName];
            this.deleteSymbol(oldName);
            this._index[newName].alias = newName;
            return newName;
        },

        relate : function() {
            this.resolveBorrows();
            this.resolveMemberOf();
            this.resolveAugments();
        },

        resolveBorrows : function() {
            for (p in this._index) {
                var symbol = this._index[p];
                
                
                
                if (symbol.is("FILE") || symbol.is("GLOBAL")) continue;
                
                var borrows = symbol.inherits;
                for (var i = 0; i < borrows.length; i++) {
                    var borrowed = this.getSymbol(borrows[i].alias);
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
                        borrowAsName = borrowAsName.replace(borrowed.alias, "")
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
        },

        resolveMemberOf : function() {
            for (var p in this._index) {
                var symbol = this.getSymbol(p);
                
                if (symbol.is("FILE") || symbol.is("GLOBAL")) continue;
                
                // the memberOf value was provided in the @memberOf tag
                else if (symbol.memberOf) {
                    var parts = symbol.alias.match(new RegExp("^("+symbol.memberOf+"[.#-])(.+)$"));
                    
                    // like foo.bar is a memberOf foo
                    if (parts) {
                        symbol.memberOf = parts[1];
                        symbol.name = parts[2];
                    }
                    // like bar is a memberOf foo
                    else {
                        var joiner = symbol.memberOf.charAt(symbol.memberOf.length-1);
                        if (!/[.#-]/.test(joiner)) symbol.memberOf += ".";
                        
                        this.renameSymbol(p, symbol.memberOf + symbol.name);
                    }
                }
                // the memberOf must be calculated
                else {
                    var parts = symbol.alias.match(/^(.*[.#-])([^.#-]+)$/);
                    if (parts) {
                        symbol.memberOf = parts[1];
                        symbol.name = parts[2];				
                    }
                }

                // set isStatic, isInner
                if (symbol.memberOf) {
                    switch (symbol.memberOf.charAt(symbol.memberOf.length-1)) {
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
                if (symbol.memberOf.match(/[.#-]$/)) {
                    symbol.memberOf = symbol.memberOf.substr(0, symbol.memberOf.length-1);
                }
                //print("looking for memberOf: " + symbol.memberOf + " FOR " + symbol.alias);
                // add to parent's methods or properties list
                if (symbol.memberOf) {
                    var container = this.getSymbol(symbol.memberOf);
                    if (!container) {
                        if (SymbolSet.isBuiltin(symbol.memberOf)) {
                            container = imports.Parser.Parser.addBuiltin(symbol.memberOf);
                        }
                        else {
                           // print("symbol NOT a BUILT IN - createing a container");
                            // Eg. Ext.y.z (missing y)
                            // we need to add in the missing symbol...
                            container = new imports.Symbol.Symbol(symbol.memberOf, [], "OBJECT", new DocComment(""));
                            container.isNamespace = true;
                            this.addSymbol( container );
                           // print(container.toSource());
                            //container = this.getSymbol(symbol.memberOf);
                            // fake container ... so dont ad symbols to it..
                            continue;
                            container = false;
                            //LOG.warn("Can't document "+symbol.name +" as a member of undocumented symbol "+symbol.memberOf+".");
                            //LOG.warn("We only have the following symbols: \n" + 
                            //    this.keys.toSource());
                        }
                    }
                    
                    if (container && !container.isNamespace) container.addMember(symbol);
                }
            }
        },

        resolveAugments : function() {
            // does this sort out multiple extends???
            for (var p in this._index) {
                var symbol = this.getSymbol(p);
                this.buildAugmentsList(symbol); /// build heirachy of inheritance...
                if (symbol.alias == "_global_" || symbol.is("FILE")) continue;
                
                var augments = symbol.augments;
                for(var ii = 0, il = augments.length; ii < il; ii++) {
                    var contributer = this.getSymbol(augments[ii]);
                    
                    
                    
                    if (contributer) {
                        contributer.childClasses.push(symbol.alias);
                        symbol.inheritsFrom.push(contributer.alias);
                        //if (!isUnique(symbol.inheritsFrom)) {
                        //    imports.BuildDocs.Options.LOG.warn("Can't resolve augments: Circular reference: "+symbol.alias+" inherits from "+contributer.alias+" more than once.");
                        //}
                        //else {
                            var cmethods = contributer.methods;
                            var cproperties = contributer.properties;
                            var cfgs = contributer.cfgs;
                            for (var ci = 0, cl = cmethods.length; ci < cl; ci++) {   
                                symbol.inherit(cmethods[ci]);
                            }
                            for (var ci = 0, cl = cproperties.length; ci < cl; ci++) {
                                symbol.inherit(cproperties[ci]);
                            }
                            for (var ci in cfgs) {
                                symbol.addConfig(cfgs[ci]);
                            }
                            
                                
                        //}
                    }
                    else {
                        
                        imports.BuildDocs.Options.LOG.warn("Can't augment contributer: '"+augments[ii]+"', not found. FOR: " + symbol.alias);
                        
                        //LOG.warn("We only have the following symbols: \n" + 
                          //      this.keys().toSource().split(",").join(",    \n"));
                       }

                }
            }
        },

        buildAugmentsList : function(symbol)
        {
            // basic idea is to add all the child extends to the parent.. without looping forever..
            
            if (!symbol.augments.length) {
                return;
            }
            
            var _t = this;
            print("buildAugmentsList:" + symbol.alias);
            var addAugments = function (alist, forceit) { // returns number added..
                if (!alist.length) {
                    return 0;
                }
                print("buildAugmentsList:addAugments" + alist.length);
                var rval = 0;
                for(var ii = 0; ii < alist.length; ii++) {
                    print("getAlias:" + alist[ii]);
                    if (alist[ii] == symbol.alias) {
                        continue;
                    }
                    var contributer = _t.getSymbol(alist[ii]);
                    if (!contributer) {
                        continue;
                    }
                    
                    if (!forceit && symbol.augments.indexOf(alist[ii]) > -1) {
                        continue;
                    }
                    if (symbol.augments.indexOf(alist[ii]) < 0) {
                        symbol.augments.push(alist[ii]);
                    }
                        
                    
                    addAugments(contributer.augments,false);
                    
                    rval++;
                }
                print("buildAugmentsList: ADDED:" + rval);
                return rval;
            }
            addAugments(symbol.augments, true);
            //while(addAugments(symbol.augments) >  0) { }
            
        }
         
})

SymbolSet.isBuiltin = function(name) {
    return (SymbolSet.isBuiltin.coreObjects.indexOf(name) > -1);
}
SymbolSet.isBuiltin .coreObjects = [
    '_global_', 'Array', 'Boolean', 'Date', 'Function', 
    'Math', 'Number', 'Object', 'RegExp', 'String'
];