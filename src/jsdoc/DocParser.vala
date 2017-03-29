
namespace JSDOC
{

	class DocParser : Object 
	{
		// options?
		bool ignoreAnonymous =            true; 
		bool treatUnderscoredAsPrivate = true;
		bool explain=             false;
 
 
    
		DocWalker walker ;
	    SymbolSet symbols ;
    
	    //filesSymbols : { },
		
		public DocParser{) {
		
			this.symbols = new  SymbolSet();
			//this.walker = new JSDOC.Walker();
		    //JSDOC.Parser.filesSymbols = {};
		}



		/**
		 * Parse a token stream.
		 * @param {JSDOC.TokenStream} token stream
		 * @param {String} filename 
		     
		 */
		
		
		parse : function(ts, srcFile) 
		{
		    this.init();
		    
		    
		    // not a nice way to set stuff...
		    
		    Symbol.srcFile = (srcFile || "");
		    DocComment.shared = ""; // shared comments don't cross file boundaries
		    
		   
		    
		    
		    
		    this.filesSymbols[Symbol.srcFile] = new SymbolSet();
		    
		    //Options.LOG.inform("Parser - run walker");
		    this.walker = new  Walker2(ts);
		    this.walker.buildSymbolTree();
		    
		    
		    
		    //this.walker.walk(ts); // adds to our symbols
		   // throw "done sym tree";
		    //Options.LOG.inform("Parser - checking symbols");
		    // filter symbols by option
		    for (p in this.symbols._index) {
		        var symbol = this.symbols.getSymbol(p);
		        
		       // print(JSON.stringify(symbol, null,4));
		        
		        if (!symbol) continue;
		        
		        if (symbol.isPrivate) {
		            this.symbols.deleteSymbol(symbol.alias);
		            continue;
		        }
		        
		        if (symbol.is("FILE") || symbol.is("GLOBAL")) {
		            continue;
		        }
		        //else if (!Options.a && !symbol.comment.isUserComment) {
		            //print("Deleting Symbols (no a / user comment): " + symbol.alias);
		            //this.symbols.deleteSymbol(symbol.alias);
		            //this.filesSymbols[Symbol.srcFile].deleteSymbol(symbol.alias);
		        //}
		        
		        if (/#$/.test(symbol.alias)) { // we don't document prototypes - this should not happen..
		            // rename the symbol ??
		            /*if (!this.symbols.getSymbol(symbol.alias.substring(0,symbol.alias.length-1))) {
		                // rename it..
		                print("Renaming Symbol (got  a #): " + symbol.alias);
		                var n = '' + symbol.alias;
		                this.symbols.renameSymbol( n ,n.substring(0,n-1));
		                this.filesSymbols[Symbol.srcFile].renameSymbol( n ,n.substring(0,n-1));
		                continue;
		            }
		            */
		            print("Deleting Symbols (got  a #): " + symbol.alias);
		            
		            this.symbols.deleteSymbol(symbol.alias);
		            this.filesSymbols[Symbol.srcFile].deleteSymbol(symbol.alias);
		        
		        }
		    }
		    //print(prettyDump(toQDump(this.filesSymbols[Symbol.srcFile]._index,'{','}')));
		    //print("AfterParse: " + this.symbols.keys().toSource().split(",").join(",\n   "));
		    return this.symbols.toArray();
		},

	
	addSymbol: function(symbol) 
    {
        //print("PARSER addSYMBOL : " + symbol.alias);
        
		// if a symbol alias is documented more than once the last one with the user docs wins
		if (this.symbols.hasSymbol(symbol.alias)) {
			var oldSymbol = this.symbols.getSymbol(symbol.alias);
            
			if (oldSymbol.comment.isUserComment && !oldSymbol.comment.hasTags) {
				if (symbol.comment.isUserComment) { // old and new are both documented
					Options.LOG.warn("The symbol '"+symbol.alias+"' is documented more than once.");
				}
				else { // old is documented but new isn't
					return;
				}
			}
		}
		
		// we don't document anonymous things
		if (this.conf.ignoreAnonymous && symbol.name.match(/\$anonymous\b/)) return;

		// uderscored things may be treated as if they were marked private, this cascades
		if (this.conf.treatUnderscoredAsPrivate && symbol.name.match(/[.#-]_[^.#-]+$/)) {
			symbol.isPrivate = true;
		}
		
		// -p flag is required to document private things
		if ((symbol.isInner || symbol.isPrivate) && !Options.p) return;
		
		// ignored things are not documented, this doesn't cascade
		if (symbol.isIgnored) return;
        // add it to the file's list... (for dumping later..)
        if (Symbol.srcFile) {
            this.filesSymbols[Symbol.srcFile].addSymbol(symbol);
        }
		
		this.symbols.addSymbol(symbol);
	},
	
	addBuiltin: function(name) {
  
		var builtin = new Symbol(name, [], "CONSTRUCTOR", new DocComment(""));
		builtin.isNamespace = false;
		builtin.srcFile = "";
		builtin.isPrivate = false;
        this.addSymbol(builtin);
		return builtin;
	},
	
		
	finish: function() {
		this.symbols.relate();		
		
		// make a litle report about what was found
		if (this.conf.explain) {
			var symbols = this.symbols.toArray();
			var srcFile = "";
			for (var i = 0, l = symbols.length; i < l; i++) {
				var symbol = symbols[i];
				if (srcFile != symbol.srcFile) {
					srcFile = symbol.srcFile;
					print("\n"+srcFile+"\n-------------------");
				}
				print(i+":\n  alias => "+symbol.alias + "\n  name => "+symbol.name+ "\n  isa => "+symbol.isa + "\n  memberOf => " + symbol.memberOf + "\n  isStatic => " + symbol.isStatic + ",  isInner => " + symbol.isInner);
			}
			print("-------------------\n");
		}
	},
    /**
     * return symbols so they can be serialized.
     */
    symbolsToObject : function(srcFile)
    {
        //this.filesSymbols[srcFile] is a symbolset..
        return this.filesSymbols[srcFile];
        
            //    Parser.filesSymbols[srcFile]._index
    }

}