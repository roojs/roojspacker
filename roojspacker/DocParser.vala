
namespace JSDOC
{
	public errordomain DocParserError {
            InvalidAugments,
            InvalidDocChildren
    }
 
 
	public class DocParser : Object 
	{
		// options - should they bee in PackerRun?
		static bool ignoreAnonymous =            true; 
		static bool treatUnderscoredAsPrivate = true;
		static bool explain=             false;
 
		
		static bool has_init = false;
		static Walker walker ;
	    private static SymbolSet? _symbols = null;
	    
	    public static SymbolSet symbols() {
	    	if (DocParser._symbols == null) {
				GLib.debug("init symbols?");
				DocParser._symbols = new  SymbolSet();
				//DocParser._symbols.ref(); // not sure why, by symbols keeps getting blanked.?
			}
	    	return DocParser._symbols;
	    }
	    static Gee.HashMap<string,SymbolSet>? _filesSymbols = null;
	    
	    static Gee.HashMap<string,SymbolSet> filesSymbols() 
	    {
	    	if (DocParser._filesSymbols == null) {
				GLib.debug("init _filesSymbols?");
				DocParser._filesSymbols = new     Gee.HashMap<string,SymbolSet>();
			}
	    	return DocParser._filesSymbols;
	    	
	    }
	    	    
	    public static string currentSourceFile;
    

		public static Gee.ArrayList<Symbol> classes()
		{
			var classes = new Gee.ArrayList<Symbol>();
			foreach(var symbol in DocParser.symbols().values()) {
				if (symbol.isaClass()) { 
					classes.add(symbol);
				}
			}    
			classes.sort( (a,b) => {
				return a.alias.collate(b.alias); 
			});
			return classes;
		}

		public static void  validateAugments()
		{
			var classes =  DocParser.classes();
		    foreach (var cls in classes) {
				for(var ii = 0, il = cls.augments.size; ii < il; ii++) {
						var contributer = DocParser.symbols().getSymbol(cls.augments[ii]);
						if (contributer == null) {
							throw new DocParserError.InvalidAugments("Looking at Class %s, could not find augments %s", 
									cls.alias, cls.augments[ii]);
							continue;
						}
						 
					}
				}
		}

		public static void  fillChildClasses()
		{
			 var classes =  DocParser.classes();
			 foreach (var cls in classes) {
		    	foreach (var lookcls in classes) {
					if (lookcls.augments.contains(cls.alias)) {
						var extends = "";
						if (lookcls.augments.size > 0) {
							extends = lookcls.augments.get(0);
							if ( extends  == lookcls.alias) {
								extends = lookcls.augments.size > 1 ? lookcls.augments.get(1) : "";
							}
						}
						cls.addChildClass(lookcls.alias, extends);
					}
				}
	    	}
		}
		 
		public static void  fillTreeChildren()
		{
			 // lookup symbol : builder.getSymbol()
			 
			 var classes =  DocParser.classes();
			 foreach (var cls in classes) {
			 	 var ar = classes.tree_children.slice(0, classes.doc_children.size); // copy?
			 	 classes.tree_children.clear();
		    	 foreach(var cn in ar) {
		    	 	var sy = DocParser.symbols().getSymbol(cn);
		    	 	if (sy == null) {
						throw new DocParserError.InvalidDocChildren("Looking at Class %s, could not find child %s", 
								cls.alias, cn);
						continue;
					}
					if (sy.isAbstract) {
						continue;
					}
					if (sy.tree_parent.length > 0) {
						var skip  = true;
						for (var pp in sy.tree_parent) {
							if (pp == "none") {
								break;
							}
							if (pp == cls.alias) {
								skip = false;
								break;
							}
						}
						if (skip) {
							continue;
						}
					
					}
					classes.tree_children.add(cn);
					foreach(var cc in sy.childClassList) {
						classes.tree_children.add(cc);
					}
				}
			}	
		    	 
		    
		}
		
		public static void parse(TokenStream ts, string srcFile) 
		{
 
		    DocParser.currentSourceFile = srcFile;
		    // not a nice way to set stuff...
		   
		    DocComment.shared = ""; // shared comments don't cross file boundaries
		     
		    DocParser.filesSymbols().set(srcFile, new SymbolSet());
		    
		    //Options.LOG.inform("Parser - run walker");
		    walker = new  Walker(ts);
		    walker.buildSymbolTree();
		     
		    
		    
		    //this.walker.walk(ts); // adds to our symbols
		   // throw "done sym tree";
		    //Options.LOG.inform("Parser - checking symbols");
		    // filter symbols by option 
		    foreach (var p in DocParser.symbols().keys()) {
		        var symbol = DocParser.symbols().getSymbol(p);
		        
		       // print(JSON.stringify(symbol, null,4));
		        
		        if (symbol == null) continue;
		        
		        if (symbol.isPrivate) {
		            DocParser.symbols().deleteSymbol(symbol.alias);
		            DocParser.filesSymbols().get(srcFile).deleteSymbol(symbol.alias);
		            continue;
		        }
		         
		        if (symbol.is("FILE") || symbol.is("GLOBAL")) {
		            continue;
		        }
		       
		        
		        if (symbol.alias.substring(symbol.alias.length-1) == "#") { // we don't document prototypes - this should not happen..
		            
		            print("Deleting Symbols (alias ends in #): " + symbol.alias);
		            
		            DocParser.symbols().deleteSymbol(symbol.alias);
		            DocParser.filesSymbols().get(srcFile).deleteSymbol(symbol.alias);
		        
		        }
		    }
		    //print(prettyDump(toQDump(this.filesSymbols[Symbol.srcFile]._index,'{','}')));
		    //print("AfterParse: " + this.symbols.keys().toSource().split(",").join(",\n   "));
		    return; //this.symbols.toArray();
		}

	
		public static void addSymbol(Symbol symbol) 
		{
		    //print("PARSER addSYMBOL : " + symbol.alias);
		    
			// if a symbol alias is documented more than once the last one with the user docs wins
			if (DocParser.symbols().hasSymbol(symbol.alias)) {
				var oldSymbol = DocParser.symbols().getSymbol(symbol.alias);
		         
				if (oldSymbol.comment.isUserComment && !oldSymbol.comment.hasTags) {
					if (symbol.comment.isUserComment) { // old and new are both documented
						GLib.debug("The symbol '%s' is documented more than once.",symbol.alias);
						// we use the new one???
					} else { // old is documented but new isn't
						return;
					}
				}
			}
		
			// we don't document anonymous things
			if (DocParser.ignoreAnonymous && symbol.name.index_of("$anonymous\b") > -1) {
				 return;
			}

			// uderscored things may be treated as if they were marked private, this cascades
			//if (DocParser.treatUnderscoredAsPrivate && symbol.name.match(/[.#-]_[^.#-]+$/)) {
			//	symbol.isPrivate = true;
			//}
		 
			// -p flag is required to document private things
			if ((symbol.isInner || symbol.isPrivate) && !PackerRun.singleton().opt_doc_include_private) {
				 return;
			}
		
			// ignored things are not documented, this doesn't cascade
			if (symbol.isIgnored) {
				return;
			} 
		    // add it to the file's list... (for dumping later..)
		    if (DocParser.currentSourceFile != null) {
		        DocParser.filesSymbols().get(DocParser.currentSourceFile).addSymbol(symbol);
		    }
		  
			DocParser.symbols().addSymbol(symbol);
		}
	
		public static Symbol addBuiltin(string name) 
		{
			var builtin = new Symbol.new_builtin(name);
		    DocParser.addSymbol(builtin);
			return builtin;
		}
	
		
		public static  void finish() {
			

			DocParser.symbols().relate();		
		
			// make a litle report about what was found
			/*
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
			*/
		}
		/**
		 * return symbols so they can be serialized.
		 */
		SymbolSet symbolsToObject(string srcFile)
		{

		    return DocParser.filesSymbols().get(srcFile);

		}

	}
}