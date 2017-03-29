
namespace JSDOC
{

	public class DocParser : Object 
	{
		// options?
		bool ignoreAnonymous =            true; 
		bool treatUnderscoredAsPrivate = true;
		bool explain=             false;
 
		
		bool has_init = false;
		static DocWalker walker ;
	    static SymbolSet symbols ;
	    
	    public static string currentSourceFile;
    
	    static Gee.HashMap<string,SymbolSet> filesSymbols;
		
		public DocParser{) {
			//this.walker = new JSDOC.Walker();
		    //JSDOC.Parser.filesSymbols = {};
		}


		private initStatic()
		{
			if (DocParser.has_init) {
				return ;
			}
			DocParser.symbols = new  SymbolSet();
			DocParser.filesSymbols = new  Gee.HashMap<string,SymbolSet>();
			
			DocParser.has_init = true;
		
		/**
		 * Parse a token stream.
		 * @param {JSDOC.TokenStream} token stream
		 * @param {String} filename 
		     
		 */
		
		
		static void parse(TokenStream ts, string srcFile) 
		{
		    
		    DocParser.currentSourceFile = srcFile;
		    // not a nice way to set stuff...
		   
		    DocComment.shared = ""; // shared comments don't cross file boundaries
		    
		   
		    this.filesSymbols.set(srcFile, new SymbolSet());
		    
		    //Options.LOG.inform("Parser - run walker");
		    this.walker = new  Walker2(ts);
		    this.walker.buildSymbolTree();
		    
		    
		    
		    //this.walker.walk(ts); // adds to our symbols
		   // throw "done sym tree";
		    //Options.LOG.inform("Parser - checking symbols");
		    // filter symbols by option
		    for (p in DocParser.symbols._index) {
		        var symbol = this.symbols.getSymbol(p);
		        
		       // print(JSON.stringify(symbol, null,4));
		        
		        if (!symbol) continue;
		        
		        if (symbol.isPrivate) {
		            this.symbols.deleteSymbol(symbol.alias);
		            this.filesSymbols.get(Symbol.srcFile).deleteSymbol(symbol.alias);
		            continue;
		        }
		        
		        if (symbol.is("FILE") || symbol.is("GLOBAL")) {
		            continue;
		        }
		       
		        
		        if (symbol.alias.substring(symbol.alias-1) = "#")) { // we don't document prototypes - this should not happen..
		            
		            print("Deleting Symbols (alias ends in #): " + symbol.alias);
		            
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