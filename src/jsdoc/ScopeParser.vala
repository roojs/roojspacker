 


namespace JSDOC {

	public enum ScopeParserMode {
		BUILDING_SYMBOL_TREE,
		PASS2_SYMBOL_TREE
	}


	public class ScopeParser : Object {

		TokenStream ts;
		Gee.ArrayList<string> warnings;

		bool debug = false;
		static Gee.ArrayList<string> idents;
		static bool initialized = false;


		Scope globalScope;
		ScopeParserMode mode;
		//braceNesting : 0,
		Gee.HashMap<int,Scope> indexedScopes;
		bool munge =  true;

		int expN =  0;	
		int braceNesting = 0;
		
		
		static void init()
		{
			if (ScopeParser.initialized) {
				return;
			}
			string[] identsar = { 
	
				"break",	 
				"case",		 
				"continue",	
				"default",	
				"delete",	
				"do",		 
				"else",		
				"export",	
				"false",	
				"for",		
				"function",	
				"if",		
				"import",	
				"in",		
				"new",		
				"null",		
				"return",	
				"switch",	
				"this",		
				"true",		
				"typeof",	
				"var",		
				"void",		
				"while",	
				"with",		

				"catch",	
				"class",	
				"const",	
				"debugger",	
				"enum",		
				"extends",	
				"finally",	
				"super",	
				"throw",	 
				"try",		

				"abstract",	
				"boolean",	
				"byte",		
				"char",		
				"double",	
				"final",	
				"float",	
				"goto",		
				"implements", 
				"instanceof",
				"int",		 
				"interface",	 
				"long",		 
				"native",	
				"package",	
				"private",	
				"protected",	 
				"public",	 
				"short",	
				"static",	
				"synchronized",	 
				"throws",	 
				"transient",	 
				"include",	 
				"undefined"
			};
			ScopeParser.idents = new Gee.ArrayList<string>();
			for(var i = 0 ;   i < identsar.length;i++) {
				ScopeParser.idents.add(identsar[i]);
			}
		}
		
		
		public ScopeParser(TokenStream ts) {
			this.ts = ts; // {TokenStream}
			this.warnings = new Gee.ArrayList<string>();

			this.globalScope = new  Scope(-1, null, -1, null);
			this.indexedScopes = new Gee.HashMap<int,Scope>();
	
			//this.indexedg = {};
			//this.timer = new Date() * 1;
		}

	 
	
	
		void warn(string s) 
		{
			//print('****************' + s);
			this.warnings.add(s);
			//println("WARNING:" + htmlescape(s) + "<BR>");
		}
	
	
		// defaults should not be initialized here =- otherwise they get duped on new, rather than initalized..
	
	  




		public void buildSymbolTree()
		{
			//println("<PRE>");
			
			this.ts.rewind();
			this.braceNesting = 0;
			
		   // print(JSON.stringify(this.ts.tokens, null,4));
			
			
			this.globalScope =new  Scope(-1, null, -1, null);
			this.indexedScopes = new Gee.HashMap<int,Scope>();
			this.indexedScopes.set(0, this.globalScope );
			
			this.mode = ScopeParserMode.BUILDING_SYMBOL_TREE;
			
			this.parseScope(this.globalScope);
			
			//print("---------------END PASS 1 ---------------- ");
			
		}
	
		public void mungeSymboltree()
		{
			if (!this.munge) {
			    return;
			}

			// One problem with obfuscation resides in the use of undeclared
			// and un-namespaced global symbols that are 3 characters or less
			// in length. Here is an example:
			//
			//     var declaredGlobalVar;
			//
			//     function declaredGlobalFn() {
			//         var localvar;
			//         localvar = abc; // abc is an undeclared global symbol
			//     }
			//
			// In the example above, there is a slim chance that localvar may be
			// munged to 'abc', conflicting with the undeclared global symbol
			// abc, creating a potential bug. The following code detects such
			// global symbols. This must be done AFTER the entire file has been
			// parsed, and BEFORE munging the symbol tree. Note that declaring
			// extra symbols in the global scope won't hurt.
			//
			// Note: Since we go through all the tokens to do this, we also use
			// the opportunity to count how many times each identifier is used.

			this.ts.rewind();
			this.braceNesting = 0;
			this.mode = ScopeParserMode.PASS2_SYMBOL_TREE;
			
			//println("MUNGING?");
			
			this.parseScope(this.globalScope);
			

			 
			this.globalScope.munge();
			
			// this.globalScope.dump();
		}


		void log(string str)
		{
			print(str);
			//print ("                    ".substring(0, this.braceNesting*2) + str);
			
			//println("<B>LOG:</B>" + htmlescape(str) + "<BR/>\n");
		}
		void logR (string str)
		{
			    //println("<B>LOG:</B>" + str + "<BR/>");
		}

		 
	


		void parseScope(Scope scope) // parse a token stream..
		{
			//this.timerPrint("parseScope EnterScope"); 
			//this.log(">>> ENTER SCOPE" + this.scopes.length);
		   
			var expressionBraceNesting = this.braceNesting + 0;
			
			var parensNesting = 0;
			
			var isObjectLitAr = new Gee.ArrayList<bool>();
			isObjectLitAr.add(false);
		 
			
		   
			//var scopeIndent = ''; 
			//this.scopes.forEach(function() {
			//    scopeIndent += '   '; 
			//});
			//print(">> ENTER SCOPE");
			
			
			
			
			var token = this.ts.lookTok(1);
			while (token != null) {
			  //  this.timerPrint("parseScope AFTER lookT: " + token.toString()); 
			    //this.dumpToken(token , this.scopes, this.braceNesting);
			    //print('SCOPE:' + token.toString());
			    //this.log(token.data);
			    //if (token.type == 'NAME') {
			    //    print('*' + token.data);
			    //}
			    switch(token.type) {
			    
					case TokenType.KEYW:
					
						switch(token.name) {
							case TokenName.VAR:
							case TokenName.CONST: // not really relivant as it's only mozzy that does this.
							    //print('SCOPE-VAR:' + token.toString());
							    var vstart = this.ts.cursor +1;
							    
							    //this.log("parseScope GOT VAR/CONST : " + token.toString()); 
							    while (true) {
							        token = this.ts.nextTok();
							        //!this.debug|| print( token.toString());
							       // print('SCOPE-VAR-VAL:' + JSON.stringify(token, null, 4));
							        if (token == null) { // can return false at EOF!
							            break;
							        }
							        if (token.name == TokenName.VAR || token.data == ",") { // kludge..
							            continue;
							        }
							        //this.logR("parseScope GOT VAR  : <B>" + token.toString() + "</B>"); 
							        if (token.type != TokenType.NAME) {
							    		this.ts.printRange( int.max(this.ts.cursor-10,0), this.ts.cursor);
							            
							            print( "var without ident");
							            GLib.Process.exit (0);
							        }
							        

							        if (this.mode == ScopeParserMode.BUILDING_SYMBOL_TREE) {
							            var identifier = scope.getIdentifier(token.data,token) ;
							            
							            if (identifier == null) {
							                scope.declareIdentifier(token.data, token);
							            } else {
							                token.identifier = identifier;
							                this.warn("(SCOPE) The variable " + token.data  + 
							            		" (line:" + token.line.to_string() + ")  has already been declared in the same scope...");
							            }
							        }

							        token = this.ts.nextTok();
							        //!this.debug|| print(token.toString());
							        /*
							        assert token.getType() == Token.SEMI ||
							                token.getType() == Token.ASSIGN ||
							                token.getType() == Token.COMMA ||
							                token.getType() == Token.IN;
							        */
							        if (token.name == TokenName.IN) {
							            break;
							        } else {
							            //var bn = this.braceNesting;
							            var bn = this.braceNesting;
							            var nts = new Gee.ArrayList<Token>();
							            while (true) {
							                if (token == null  || token.type == TokenType.VOID || token.data == ",") {
							                    break;
							                }
							                nts.add(token);
							                token = this.ts.nextTok();
							            }
							            if (nts.size > 0) {
							                var TS = this.ts;
							                this.ts = new TokenStream(nts);
							                this.parseExpression(scope);
							                this.ts = TS;
							            }
							               
							            this.braceNesting = bn;
							            //this.braceNesting = bn;
							            //this.logR("parseScope DONE  : <B>ParseExpression</B> - tok is:" + this.ts.lookT(0).toString()); 
							            
							            token = this.ts.lookTok(1);
							            //!this.debug|| 
							           // print("AFTER EXP: " + token.toString());
							            if (token.data == ";") {
							                break;
							            }
							        }
							    }
							    
							    //print("VAR:")
							    //this.ts.dump(vstart , this.ts.cursor);
							    
							    break;
							    
							    
							case TokenName.FUNCTION:
							    //if (this.mode == 'BUILDING_SYMBOL_TREE') 
							    //    print('SCOPE-FUNC:' + JSON.stringify(token,null,4));
							    //println("<i>"+token.data+"</i>");
							     var bn = this.braceNesting;
							    this.parseFunctionDeclaration(scope);
							     this.braceNesting = bn;
							    break;

							case TokenName.WITH:
							    //print('SCOPE-WITH:' + token.toString());
							    //println("<i>"+token.data+"</i>");   
							    if (this.mode == ScopeParserMode.BUILDING_SYMBOL_TREE) {
							        // Inside a 'with' block, it is impossible to figure out
							        // statically whether a symbol is a local variable or an
							        // object member. As a consequence, the only thing we can
							        // do is turn the obfuscation off for the highest scope
							        // containing the 'with' block.
							        this.protectScopeFromObfuscation(scope);
							        this.warn("Using 'with' is not recommended." +
							    		 (this.munge ? " Moreover, using 'with' reduces the level of compression!" : ""));
							    }
							    break;

							case TokenName.CATCH:
							    //print('SCOPE-CATCH:' + token.toString());
							    //println("<i>"+token.data+"</i>");
							    this.parseCatch(scope);
							    break;



							default:    
								// print(" KEYW = %s\n", token.asString());
								var symbol = token.data;
					        
							     if (this.mode == ScopeParserMode.BUILDING_SYMBOL_TREE) {
									
							        if (token.name == TokenName.EVAL) {
							            //print("got token eval...prefix= %s\n", token.prefix);
							            
							            //print(JSON.stringify(token, null,4));
							            // look back one and see if we can find a comment!!!
							            //var prevTok = this.ts.look(-1,true);
							            //print("prev to eval = %s\n", prevTok.asString());
							            //if (prevTok.type == TokenType.COMM) {
							        	//	print("previus to eval == comment\n%s\n" , prevTok.data);
							            if (token.prefix.length > 0 && Regex.match_simple ("eval",token.prefix)) {
							                // look for eval:var:noreplace\n
							                //print("MATCH!?");
							                var _t = this;
							                
							                var regex = new GLib.Regex ("eval:var:([a-z_]+)",GLib.RegexCompileFlags.CASELESS );
			 
							                regex.replace_eval (token.prefix, token.prefix.length, 0, 0, (match_info, result) => {
									           	var a =  match_info.fetch(1);
									           	//print("protect?: %s\n", a);
							                    var hi = this.getIdentifier(a, scope, token);
								                   // println("PROTECT "+a+" from munge" + (hi ? "FOUND" : "MISSING"));
							                    if (hi != null) {
							                        //print("PROTECT "+a+" from munge\n");
							                        //print(JSON.stringify(hi,null,4));
							                        hi.toMunge = false;
							                    }
							                    return false;
							                    
							                });
							                
							                
							            } else {
							                
							            
							                this.protectScopeFromObfuscation(scope);
							                this.warn("Using 'eval' is not recommended. (use  eval:var:noreplace in comments to optimize) " +
							            		 (this.munge ? " Moreover, using 'eval' reduces the level of compression!" : ""));
							            }

							        }

							
							

								}
								break; //???							
						}
						break; // end KEYW
					
					case TokenType.PUNC:
							
							switch(token.name) {
					
					
								case TokenName.LEFT_CURLY: // {
								case TokenName.LEFT_PAREN: // (    
								case TokenName.LEFT_BRACE: // [
									//print('SCOPE-CURLY/PAREN:' + token.toString());
									//println("<i>"+token.data+"</i>");
									var curTS = this.ts;
									if (token.props.size > 0) {
									    
									    // { a : ... , c : .... }
									    
									    for (var i = 0;i < token.keyseq.size; i++ ){ 
									    //var iter = token.props.map_iterator();
											var k =  token.keyseq.get(i);
											
											TokenKeyMap val = token.props.get(k);
									    
									        
									      //  print('SCOPE-PROPS:' + JSON.stringify(token.props[prop],null,4));
									        if (val.vals.get(0).data == "function") {
									            // parse a function..
									            this.ts = new TokenStream(val.vals);
									            this.ts.nextTok();
									            this.parseFunctionDeclaration(scope);
									            
									            continue;
									        }
									        // key value..
									        
									        this.ts = new TokenStream(val.vals);
									        this.parseExpression(scope);
									        
									    }
									    this.ts = curTS;
									    
									    // it's an object literal..
									    // the values could be replaced..
									    break;
									}
									
									// ( ... ) or { .... } not object literals..
									
									
				 	            for (var xx =0; xx < token.items.size; xx++) {
									var expr = token.items.get(xx);
									//token.items.forEach(function(expr) {
									        //print(expr.toString());
									       this.ts = new TokenStream(expr);
									        //if (curTS.data == '(') {
									            this.parseScope(scope);
									        //} else {
									          //  _this.parseExpression(scope)
									        //}
									      
									}  
									this.ts = curTS;
									//print("NOT PROPS"); Seed.quit();
									
									//isObjectLitAr.push(false);
									//this.braceNesting++;
									
									//print(">>>>>> OBJLIT PUSH(false)" + this.braceNesting);
									break;

								case TokenName.RIGHT_CURLY: // }
									//print("<< EXIT SCOPE");
									return;
									
								default:
									break;
						}
						break;
						
			        case TokenType.STRN:
			      
			    		///case "STRN.DOUBLE_QUOTE": // used for object lit detection.. case "STRN.SINGLE_QUOTE":
			          //  print('SCOPE-STRING:' + token.toString());
			            //println("<i>"+token.data+"</i>");

			            if (this.ts.lookTok(-1).data == "{" && this.ts.lookTok(1).data == ":") {
			                // then we are in an object lit.. -> we need to flag the brace as such...
			                isObjectLitAr.remove_at(isObjectLitAr.size-1);
			                isObjectLitAr.add(true);
			                //print(">>>>>> OBJLIT REPUSH(true)");
			            }
			            var isInObjectLitAr = isObjectLitAr.get(isObjectLitAr.size-1);
			            
			            if (isInObjectLitAr &&  this.ts.lookTok(1).data == ":" &&
			                ( this.ts.lookTok(-1).data == "{"  ||  this.ts.lookTok(-1).data == ":" )) {
			                // see if we can replace..
			                // remove the quotes..
			                // should do a bit more checking!!!! (what about wierd char's in the string..
			                var str = token.data.substring(1,token.data.length-1);
			                
			                if (Regex.match_simple ("^[a-z_]+$", str,GLib.RegexCompileFlags.CASELESS) && ScopeParser.idents.index_of(str) < 0) {
			                    token.outData = str;
			                }
			                
			                 
			                
			            }
			            
			            break;
			        
			        case TokenType.NAME:
			            // print("SCOPE got NAME:%s\n" , token.asString());
			            //print("DEAL WITH NAME:");
			            // got identifier..
			            // look for  { ** : <- indicates obj literal.. ** this could occur with numbers ..
			            // skip anyting with "." before it..!!
			            // print("prev0 = " + this.ts.lookTok(0).asString() +"\n");
			            // print("prev-1 = " + this.ts.lookTok(-1).asString() +"\n");			             
			            if (this.ts.lookTok(-1).name == TokenName.DOT) {
			                // skip, it's an object prop.
			                // print("prev is a .dot.\n");
			                //println("<i>"+token.data+"</i>");
			                break;
			            }
			            //print("SYMBOL: " + token.toString());
			            
			            var symbol = token.data;
			            if (symbol == "this") {
			                // print("ignore 'this'\n");
			                break;
			            }
			            
			            if (this.mode == ScopeParserMode.PASS2_SYMBOL_TREE) {
			                
			                //println("GOT IDENT: -2 : " + this.ts.lookT(-2).toString() + " <BR> ..... -1 :  " +  this.ts.lookT(-1).toString() + " <BR> "); 
			                
			                //print ("MUNGE?" + symbol);
			                
			                //println("GOT IDENT: <B>" + symbol + "</B><BR/>");
			                     
			                    //println("GOT IDENT (2): <B>" + symbol + "</B><BR/>");
			                var identifier = this.getIdentifier(symbol, scope, token);
			                
			                
			                if (identifier == null) {
								// BUG!find out where builtin is defined...
								// print("new identifier\n");
			                    if (symbol.length <= 3 &&  Scope.builtin.index_of(symbol) < 0) {
			                        // Here, we found an undeclared and un-namespaced symbol that is
			                        // 3 characters or less in length. Declare it in the global scope.
			                        // We don't need to declare longer symbols since they won't cause
			                        // any conflict with other munged symbols.
			                        this.globalScope.declareIdentifier(symbol, token);
			                        this.warn("Found an undeclared symbol: " + symbol + " (line:" + token.line.to_string() + ")");
			                    }
			                    
			                    //println("GOT IDENT IGNORE(3): <B>" + symbol + "</B><BR/>");
			                } else {
			            		// print("existing identifier\n");
			                    token.identifier = identifier;
			                    identifier.refcount++;
			                }
			            }   
			            
			            break;
			            //println("<B>SID</B>");
			        default:
			            
			            break;
			        
			        
			    } // end switch
			    
			    
			    //print("parseScope TOK : " + token.toString()); 
			    token = this.ts.nextTok();
			    //if (this.ts.nextT()) break;
			    
			}
			//print("<<< EXIT SCOPE");
			//print("<<<<<<<EXIT SCOPE ERR?" +this.scopes.length);
		}


	
		void parseExpression(Scope scope) 
		{

			// Parse the expression until we encounter a comma or a semi-colon
			// in the same brace nesting, bracket nesting and paren nesting.
			// Parse functions if any...
			//println("<i>EXP</i><BR/>");
			//!this.debug || print("PARSE EXPR");
			this.expN++;
			 
			// for printing stuff..
		   
			
			

			var expressionBraceNesting = this.braceNesting + 0;
			var bracketNesting = 0;
			var parensNesting = 0;
			 
			var isObjectLitAr = new Gee.ArrayList<bool>();
			isObjectLitAr.add( false);
			
			
			Token token;    
			
			//print(scopeIndent + ">> ENTER EXPRESSION" + this.expN);
			while (null != (token = this.ts.nextTok())) {
		 
			
			    
			   /*
			    // moved out of loop?
			   currentScope = this.scopes[this.scopes.length-1];
			    
			    var scopeIndent = ''; 
			    this.scopes.forEach(function() {
			        scopeIndent += '   '; 
			    });
			   */ 
			   
			   //this.dumpToken(token,  this.scopes, this.braceNesting );
			    //print('EXPR' +  token.toString());
			    
			    
			    //println("<i>"+token.data+"</i>");
			    //this.log("EXP:" + token.data);
			    switch (token.type) {
			        case TokenType.PUNC:
			            //print("EXPR-PUNC:" + token.toString());
			            
			            switch(token.data) {
			                 
			                case ";":
			                    //print("<< EXIT EXPRESSION");
			                    break;

			                case ",":
			                    
			                    break;

			               
			                case "(": //Token.LP:
			                case "{": //Token.LC:
			                case "[": //Token.LB:
			                    //print('SCOPE-CURLY/PAREN/BRACE:' + token.toString());
			                   // print('SCOPE-CURLY/PAREN/BRACE:' + JSON.stringify(token, null,4));
			                    //println("<i>"+token.data+"</i>");
			                    var curTS = this.ts;
			                    if (token.keyseq.size > 0) {
			                        
			                         for (var i = 0;i < token.keyseq.size; i++ ){ 
									    //var iter = token.props.map_iterator();
										var k =  token.keyseq.get(i);
										
										TokenKeyMap val = token.props.get(k);
								    
									    if (val == null) {
											print("failed  to get %s val from token %s\n", k, token.asString());
										}
			                        
			                            //if (val.vals.size < 1) {
			                                //print(JSON.stringify(token.props, null,4));
			                            //}
			                            
			                            
			                            if (val.vals.size > 0 && val.vals.get(0).data == "function") {
			                                // parse a function..
			                                this.ts = new TokenStream(val.vals);
			                                this.ts.nextTok();
			                                this.parseFunctionDeclaration(scope);
			                                continue;
			                            }
			                            // key value..
			                            
			                            this.ts = new TokenStream(val.vals);
			                            this.parseExpression(scope);
			                            
			                        }
			                        this.ts = curTS;
			                        
			                        // it's an object literal..
			                        // the values could be replaced..
			                        break;
			                    }
			                    
			                    
	 
			                    foreach(var expr in token.items) {
	 
			                          this.ts = new TokenStream(expr);
			                          this.parseExpression(scope);
			                    }
			                    this.ts = curTS;
			                
			                
			            
			                    ///print(">>>>> EXP PUSH(false)"+this.braceNesting);
			                    break;

			               
			                
			                 
			                    
			                case ")": //Token.RP:
			                case "]": //Token.RB:
			                case "}": //Token.RB:
			                    //print("<< EXIT EXPRESSION");
			                    return;
			                   
	 
			     
			                    parensNesting++;
			                    break;

			                
			                    
			            }
			            break;
			            
			        case TokenType.STRN: // used for object lit detection..
			            //if (this.mode == 'BUILDING_SYMBOL_TREE')    
			                //print("EXPR-STR:" + JSON.stringify(token, null, 4));
			       
			             
			            break;
			        
			              
			     
			        case TokenType.NAME:
			            if (this.mode == ScopeParserMode.BUILDING_SYMBOL_TREE) {
			                
			                //print("EXPR-NAME:" + JSON.stringify(token, null, 4));
			            } else {
			                //print("EXPR-NAME:" + token.toString());
			            }
			            var symbol = token.data;
			            print("in NAME = %s \n" , symbol);
			            //print("in NAME 0: " + this.ts.look(0).toString());
			            //print("in NAME 2: " + this.ts.lookTok(2).toString());
			            
			            //print(this.ts.lookTok(-1).data);
			            // prefixed with '.'
			            if (this.ts.lookTok(-1).data == ".") {
			                //skip '.'
			                break;
			            }
			            if (symbol == "this") {
			                break;
		               }
			            
			            if (this.mode == ScopeParserMode.PASS2_SYMBOL_TREE) {

			                var identifier = this.getIdentifier(symbol, scope, token);
			                //println("<B>??</B>");
			                if (identifier == null) {

			                    if (symbol.length <= 3 &&  Scope.builtin.index_of(symbol) < 0) {
			                        // Here, we found an undeclared and un-namespaced symbol that is
			                        // 3 characters or less in length. Declare it in the global scope.
			                        // We don't need to declare longer symbols since they won't cause
			                        // any conflict with other munged symbols.
			                        this.globalScope.declareIdentifier(symbol, token);
			                        this.warn("Found an undeclared symbol: " + symbol + " (line:" + token.line.to_string() + ")");
			                        //print("Found an undeclared symbol: " + symbol + ' (line:' + token.line + ')');
			                        //throw "OOPS";
			                    } else {
			                        //print("undeclared:" + token.toString())
			                    }
			                    
			                    
			                } else {
			                    //println("<B>++</B>");
			                    token.identifier = identifier;
			                    identifier.refcount++;
			                }
			                
			            }
			            break;
			            
			            
			            
			            
			            //println("<B>EID</B>");
			        case TokenType.KEYW:   
			            //if (this.mode == 'BUILDING_SYMBOL_TREE') 
			            //    print("EXPR-KEYW:" + JSON.stringify(token, null, 4));
			            
			            //print('EXPR-KEYW:' + token.toString());
			            if (token.name == TokenName.FUNCTION) {
			                
			                this.parseFunctionDeclaration(scope);
			                break;
			            }
			       
			             
			            var symbol = token.data;
			            if (this.mode == ScopeParserMode.BUILDING_SYMBOL_TREE) {
			                
			                if (token.name == TokenName.EVAL) {
			                
			                
			                    //print(JSON.stringify(token,null,4));
			                    
			                    if (token.prefix.length > 0 && Regex.match_simple ("eval:var:", token.prefix,GLib.RegexCompileFlags.CASELESS)) {
			                        // look for eval:var:noreplace\n
			                       // print("GOT MATCH?");

			                        
		                     	   var regex = new GLib.Regex ("eval:var:([a-z_]+)",GLib.RegexCompileFlags.CASELESS );
	 
			                        regex.replace_eval (token.prefix, token.prefix.length, 0, 0, (match_info, result) => {
			                    		var a = match_info.fetch(0);
			                            //print("PROTECT: " + a);
			                            
			                            
			                            var hi = this.getIdentifier(a, scope, token);
			                           //println("PROTECT "+a+" from munge" + (hi ? "FOUND" : "MISSING"));
			                            if (hi != null) {
			                              //  println("PROTECT "+a+" from munge");
			                                hi.toMunge = false;
			                            }
			                            return false;
			                            
			                        });
			                        
			                    } else {
			                        this.protectScopeFromObfuscation(scope);
			                        this.warn("Using 'eval' is not recommended." + 
			                    		(this.munge ? " Moreover, using 'eval' reduces the level of compression!" : ""));
			                    }
			                    

			                }
			              
			            } 
	  	               break;
			        default:
			            //if (this.mode == 'BUILDING_SYMBOL_TREE') 
			            //    print("EXPR-SKIP:" + JSON.stringify(token, null, 4));
			            break;
			    }
			    
			}
			//print("<< EXIT EXPRESSION");
			this.expN--;
		}


		void parseCatch(Scope scope) {

			
			//token = getToken(-1);
			//assert token.getType() == Token.CATCH;
			var token = this.ts.nextTok();
			token = this.ts.nextTok();
			
			
			//print(JSON.stringify(this.ts,null,4));
			//assert token.getType() == Token.LP; (
			//token = this.ts.nextTok();
			//assert token.getType() == Token.NAME;
			
			var symbol = token.items[0][0].data;
			

			if (this.mode == ScopeParserMode.BUILDING_SYMBOL_TREE) {
			    // We must declare the exception identifier in the containing function
			    // scope to avoid errors related to the obfuscation process. No need to
			    // display a warning if the symbol was already declared here...
			    scope.declareIdentifier(symbol, token.items[0][0]);
			} else {
			    //?? why inc the refcount?? - that should be set when building the tree???
			    var identifier = this.getIdentifier(symbol, scope, token.items[0][0]);
			    identifier.refcount++;
			}
			
			//token = this.ts.nextTok();
			//assert token.getType() == Token.RP; // )
		}
	
		void parseFunctionDeclaration (Scope scope) 
		{
			//print("PARSE FUNCTION");
			
			 
			var b4braceNesting = this.braceNesting + 0;
			
			//this.logR("<B>PARSING FUNCTION</B>");
			

			var token = this.ts.nextTok();
			if (token.type == TokenType.NAME) {
			    if (this.mode == ScopeParserMode.BUILDING_SYMBOL_TREE) {
			        // Get the name of the function and declare it in the current scope.
			        var symbol = token.data;
			        if (scope.getIdentifier(symbol,token) != null) {
			            this.warn("The function " + symbol + " has already been declared in the same scope...");
			        }
			        scope.declareIdentifier(symbol,token);
			    }
			    token =  this.ts.nextTok();
			}
			
			
			// return function() {.... 
			while (token.data != "(") {
			    //print(token.toString());
			    token =  this.ts.nextTok();
			     
			}
			
			Scope fnScope;
			//assert token.getType() == Token.LP;
			if (this.mode == ScopeParserMode.BUILDING_SYMBOL_TREE) {
			    fnScope = new Scope(1, scope, token.id, token);
			    
 			    //println("STORING SCOPE" + this.ts.cursor);
			    
			    this.indexedScopes.set(token.id,fnScope);
			    
			} else {
			    //qln("FETCHING SCOPE" + this.ts.cursor);
			    fnScope = this.indexedScopes[token.id];
			}
			//if (this.mode == 'BUILDING_SYMBOL_TREE') 
			//  print('FUNC-PARSE:' + JSON.stringify(token,null,4));
			// Parse function arguments.
			var args = token.items;
			for (var argpos =0; argpos < args.size; argpos++) {
			     
			    token = args.get(argpos).get(0);
			    //print ("FUNC ARGS: " + token.toString())
			    //assert token.getType() == Token.NAME ||
			    //        token.getType() == Token.COMMA;
			    if (token.type == TokenType.NAME && this.mode == ScopeParserMode.BUILDING_SYMBOL_TREE) {
			        var symbol = token.data;
			        var identifier = fnScope.declareIdentifier(symbol,token);
			        if (symbol == "$super" && argpos == 0) {
			            // Exception for Prototype 1.6...
			            identifier.toMunge = false;
			        }
			        //argpos++;
			    }
			}
			
			token = this.ts.nextTok();
			if (token == null) {
				return;
			}
			//print('FUNC-BODY:' + JSON.stringify(token.items,null,4));
			//Seed.quit();
			//print(token.toString());
			// assert token.getType() == Token.LC;
			//this.braceNesting++;
			
			//token = this.ts.nextTok();
			//print(token.toString());
			var outTS = this.ts;
			foreach(var tar in token.items) {
				this.ts = new TokenStream(tar);
				this.parseScope(fnScope);
			    
			}
			
			//print(JSON.stringify(this.ts,null,4));
			//this.parseScope(fnScope);
			this.ts = outTS;
			// now pop it off the stack!!!
		   
			//this.braceNesting = b4braceNesting;
			//print("ENDFN -1: " + this.ts.lookTok(-1).toString());
			//print("ENDFN 0: " + this.ts.lookTok(0).toString());
			//print("ENDFN 1: " + this.ts.lookTok(1).toString());
		}
	
		void protectScopeFromObfuscation (Scope scope) {
			    //assert scope != null;
			
			if (scope == this.globalScope) {
			    // The global scope does not get obfuscated,
			    // so we don't need to worry about it...
			    return;
			}

			// Find the highest local scope containing the specified scope.
			while (scope != null && scope.parent != this.globalScope) {
			    scope = scope.parent;
			}
 
			//assert scope.getParentScope() == globalScope;
			scope.preventMunging();
		}
	 
		Identifier? getIdentifier(string symbol, Scope in_scope, Token token) 
		{
			Identifier identifier;
			var scope = in_scope;
			while (scope != null) {
			    identifier = scope.getIdentifier(symbol, token);
			    //println("ScopeParser.getIdentgetUsedSymbols("+symbol+")=" + scope.getUsedSymbols().join(','));
			    if (identifier != null) {
			        return identifier;
			    }
			    scope = scope.parent;
			}
			return null;
		}
		public void printWarnings()
		{
			foreach(var w in this.warnings) {
				print("%s\n",w);
			}
		}
		
	}
}

