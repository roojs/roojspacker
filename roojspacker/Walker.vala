// this walks through the code, and tries to find patterns that match documentable elements..


namespace JSDOC {

	enum WalkerMode {
		BUILDING_SYMBOL_TREE,
		XXX
	}
	
	public class Walker  : Object
	{
		TokenStream ts;
		Gee.ArrayList<string> warnings;
		Gee.ArrayList<Scope> scopes;
		Gee.HashMap<int,Scope> indexedScopes;
		Gee.HashMap<string,Symbol> symbols;
		Gee.HashMap<string,string> aliases;
		Scope globalScope;
		
        bool global = false;
        WalkerMode mode =  WalkerMode.XXX; //"BUILDING_SYMBOL_TREE",
        int braceNesting = 0;
        
        DocComment? currentDoc =  null;

        bool munge =  true;
		
		public Walker(TokenStream ts)
		{
			this.ts  = ts;
			this.warnings= new Gee.ArrayList<string>();
			this.scopes = new Gee.ArrayList<Scope>();
			this.indexedScopes = new Gee.HashMap<int,Scope>();
			this.symbols = new Gee.HashMap<string,Symbol>();
			this.aliases = new Gee.HashMap<string,string>();
			this.braceNesting = 0;
		}

        //warn: function(s) {
            //this.warnings.push(s);
        //    print("WARNING:" + htmlescape(s) + "<BR>");
        //},
        // defaults should not be initialized here =- otherwise they get duped on new, rather than initalized..






        public void buildSymbolTree()
        {
            //print("<PRE>");
            
            this.ts.rewind();
            this.braceNesting = 0;
            this.scopes = new Gee.ArrayList<Scope>();;
			this.aliases = new Gee.HashMap<string,string>();
             
            this.globalScope = new Scope(-1, null, -1,  "$global$", null);
            this.indexedScopes = new Gee.HashMap<int,Scope>();
            this.indexedScopes.set(  0,  this.globalScope );
            
            this.mode = WalkerMode.BUILDING_SYMBOL_TREE;
            this.parseScope(this.globalScope,this.emptyAlias());
            
        }
        Gee.HashMap<string,string>  emptyAlias()
        {
        	return new Gee.HashMap<string,string> ();
    	}
        
        

        string fixAlias (Gee.HashMap<string,string>aliases, string str, bool nomore = false)
        {
            var ar = str.split(".");
            var m = ar[0];
            
            //print(str +"?=" +aliases.toSource());
            if (!aliases.has_key(m)) {
                return str;
            }
            ar[0] = aliases.get(m);
            
            var ret = string.joinv(".", ar);
            if (nomore != true) {
                ret = this.fixAlias(aliases, ret, true);
            }
            
            
            return ret;
        }

        

        void parseScope (Scope in_scope, Gee.HashMap<string,string> ealiases) // parse a token stream..
        {
            //this.timerPrint("parseScope EnterScope"); 
            
            var scope = in_scope;
            
            var aliases = new Gee.HashMap<string,string>();

            foreach(var i in ealiases.keys) {
                aliases.set(i, ealiases.get(i));
            }
                
            //print("STARTING SCOPE WITH: " + ealiases.toSource());
             
            var expressionBraceNesting = this.braceNesting;
            var bracketNesting = 0;
            var parensNesting = 0;
           
            
            var l1 = "", l2 = "";
            var scopeName = "";
            
            
            var locBraceNest = 0;
            // determines if we are in object literals...
            
            var isObjectLitAr = new Gee.ArrayList<bool>();
            isObjectLitAr.add(false);
            //print("SCOPE: ------------------START ----------------");

            this.scopesIn(scope);
            var scopeLen = this.scopes.size;
            
            if (this.ts.cursor < 1) {
              // this.ts.cursor--; // hopeflly this kludge will work
            }
            
            
            //print(JSON.stringify(this.ts, null, 4)); Seed.quit();
            Token token;
            while (null != ( token = this.ts.next())) {
                 //GLib.debug("TOK %s", token.asString());
                //  this.timerPrint("parseScope AFTER lookT: " + token.toString()); 
                  
                if (token.isType(TokenType.COMM)) {
                      
                 
                    if (!token.isName(TokenName.JSDOC)) {
                        //print("Walker2 : spce is not JSDOC");
                        continue; //skip.
                    }
                    if (this.currentDoc != null) {
                        // add it to the current scope????
                        
                        this.addSymbol("", true);
                        GLib.debug("Call addSymbol EMPTY");
                        //print ( "Unconsumed Doc: " + token.toString())
                        //throw "Unconsumed Doc (TOKwhitespace): " + this.currentDoc.toSource();
                    }
                    
                   // print ( "NEW COMMENT: " + token.toString())
                    var newDoc = new DocComment(token.data);
                    
                    // it"s a scope changer..
                    
                    if (newDoc.getTag(DocTagTitle.SCOPE).size > 0) {
                        //print("Walker2 : doctag changes scope");
                        //throw "done";
                        scope.ident = "$private$|" + newDoc.getTag(DocTagTitle.SCOPE).get(0).desc;
                        continue;
                    } 
                    
                    // it"s a scope changer..
                    if (newDoc.getTag(DocTagTitle.SCOPEALIAS).size > 0) {
                        //print(newDoc.getTag("scopeAlias").toSource());
                        // @scopeAlias a=b
                        //print("Walker2 : doctag changes scope (alias)");
                        var sal = newDoc.getTag(DocTagTitle.SCOPEALIAS).get(0).desc.split("=");
                        aliases[sal[0].strip()] = sal[1].strip();
                        
                        continue;
                    }
                    
                    
                    /// got a  doc comment..
                    //token.data might be this.??? (not sure though)
                    //print("Walker2 : setting currentDoc");
                    this.currentDoc = newDoc;
                    continue;
                }
                
                // catch the various issues .. - scoe changes or doc actions..
                
              
                
                // things that stop comments carrying on...??
                
                if (this.currentDoc != null && (
                        token.data == ";" || 
                        token.data == "}")) {

                    GLib.debug("Call addSymbol EMPTY");                        
                    this.addSymbol("", true);
                    
                    //throw "Unconsumed Doc ("+ token.toString() +"): " + this.currentDoc.toSource();
                }
                    
                
                // the rest are scoping issues...
                
                // var a = b;
                
                 if (token.isName(TokenName.VAR) &&
                 
                        this.ts.lookTok(1).isType(TokenType.NAME) &&
                        this.ts.lookTok(2).data == "=" &&
                        this.ts.lookTok(3).isType(TokenType.NAME) &&
                        this.ts.lookTok(4).data == ";"  
                        
                 
                 ) {
                    //print("SET ALIAS:" + this.ts.lookTok(1).data +"=" + this.ts.lookTok(3).data);
                     
                    aliases.set(this.ts.lookTok(1).data, this.ts.lookTok(3).data);
                
                }
                
                if ((token.data == "eval") || /\.eval$/.match(token.data)) {
                    this.currentDoc = null;
                    continue;
                }
              
                // extends scoping  *** not sure if the can be x = Roo.apply(....)
                // xxx.extends(a,b, {
                    // $this$=b|b.prototype
                // xxx.apply(a, {
                    // a  << scope
                // xxx.applyIf(a, {
                    // a  << scope
                if (token.isType(TokenType.NAME) ) {
                    
                    //print("TOK(ident)"+ token.toString());
                     
                    if (/\.extend$/.match(token.data) &&
                        this.ts.lookTok(1).data == "(" &&
                        this.ts.lookTok(2).isType(TokenType.NAME)  &&
                        this.ts.lookTok(3).data == "," &&
                        this.ts.lookTok(4).isType(TokenType.NAME)  &&
                        this.ts.lookTok(5).data == "," &&
                        this.ts.lookTok(6).data == "{" 
                           
                        ) {
                        // ignore test for ( a and ,
                        this.ts.nextTok(); /// (
                        token = this.ts.nextTok(); // a
                        scopeName = token.data;
                        
                        if (this.currentDoc != null) {
                        	GLib.debug("Call addSymbol %s", scopeName);
                            this.addSymbol(scopeName,false,"OBJECT");

                        }
                        this.ts.nextTok(); // ,
                        this.ts.nextTok(); // b
                        
                        
                        this.ts.nextTok(); // ,
                        token = this.ts.nextTok(); // {
                            
                        scopeName = this.fixAlias(aliases, scopeName);
                        
                        var fnScope = new Scope(this.braceNesting, scope, token.id, // was token.n?
            				"$this$=" + scopeName  + "|"+scopeName+".prototype", null
			        	);
                        
    
                        this.indexedScopes.set(this.ts.cursor, fnScope);
                        scope = fnScope;
                        this.scopesIn(fnScope);
                       
                        locBraceNest++;
                        //print(">>" +locBraceNest);
                        continue; // no more processing..
                        
                    }
                    
                    // a = Roo.extend(parentname, {
                        
                     if (/\.extend$/.match(token.data) &&
                        this.ts.lookTok(-2).isType(TokenType.NAME)  &&
                        this.ts.lookTok(-1).data == "=" &&
                        this.ts.lookTok(1).data == "(" &&
                        this.ts.lookTok(2).isType(TokenType.NAME) &&
                        this.ts.lookTok(3).data == "," &&
                        this.ts.lookTok(4).data == "{" 
                        ) {
                        // ignore test for ( a and ,
                        token = this.ts.lookTok(-2);
                        scopeName = token.data;
                        if (this.currentDoc != null) {
	                        GLib.debug("Call addSymbol %s", scopeName);
                            this.addSymbol(scopeName,false,"OBJECT");

                        }
                        this.ts.nextTok(); /// (
                        this.ts.nextTok(); // parent
                        
                        this.ts.nextTok(); // ,
                        token =  this.ts.nextTok(); // {
                             
                        
                        scopeName = this.fixAlias(aliases,scopeName);
                        var fnScope =  new Scope(this.braceNesting, scope, token.id, // was token.n?
            				 "$this$=" + scopeName  + "|"+scopeName+".prototype",
            					 null
			        	);
                        
                         
                        this.indexedScopes.set(this.ts.cursor, fnScope);
                        scope = fnScope;
                        this.scopesIn(fnScope);
                       
                        locBraceNest++;
                        //print(">>" +locBraceNest);
                        continue; // no more processing..
                        
                    }
                    
                    
                     // apply ( XXXX,  {
                    /*
                    print(JSON.stringify([
                        token.data,
                        this.ts.lookTok(1).data ,
                        this.ts.lookTok(2).type ,
                        this.ts.lookTok(3).data ,
                        this.ts.lookTok(4).data 
                    ], null, 4));
                    */
                    
                    if (/\.(applyIf|apply)$/.match(token.data) && 
                        this.ts.lookTok(1).data == "("  &&
                        this.ts.lookTok(2).isType(TokenType.NAME) &&
                        this.ts.lookTok(3).data == ","  &&
                        this.ts.lookTok(4).data == "{" 
                        
                        ) {
                        this.ts.nextTok(); /// (
                         
                        //print("GOT : applyIF!"); 
                         
                        token = this.ts.nextTok(); // b
                        scopeName = token.data;
                        
                                      
                        if (this.currentDoc != null) {
	                        GLib.debug("Call addSymbol %s", scopeName);
                            this.addSymbol(scopeName,false,"OBJECT");
                        }
                     

                        
                        this.ts.nextTok(); /// ,
                        this.ts.nextTok(); // {
                        scopeName = this.fixAlias(aliases,scopeName);
                        var fnScope =   new Scope(this.braceNesting, scope, token.id, // was token.n?
            				scopeName, null
			        	);

                        this.indexedScopes.set(this.ts.cursor, fnScope);
                        scope = fnScope;
                        this.scopesIn(fnScope);
                         
                        locBraceNest++;
                        //print(">>" +locBraceNest);
                        continue; // no more processing..
                    }
                    
                    
                    // xxx = new yyy ( {
                        
                    // change scope to xxxx
                    /*
                    print(JSON.stringify([
                        this.ts.lookTok(1).data ,
                        this.ts.lookTok(2).name ,
                        this.ts.lookTok(3).type ,
                        this.ts.lookTok(4).data ,
                        this.ts.lookTok(5).data 
                    ], null, 4));
                    */
                    if ( this.ts.lookTok(1).data == "=" &&
                        this.ts.lookTok(2).isName(TokenName.NEW) &&
                        this.ts.lookTok(3).isType(TokenType.NAME)&&
                        this.ts.lookTok(4).data == "(" &&
                        this.ts.lookTok(5).data == "{" 
                        ) {
                        scopeName = token.data;
                        if (this.currentDoc != null) {
	                        GLib.debug("Call addSymbol %s", scopeName);
                            this.addSymbol(scopeName,false,"OBJECT");
                            
                        }
                        
                        this.ts.nextTok(); /// =
                        this.ts.nextTok(); /// new
                        this.ts.nextTok(); /// yyy
                        this.ts.nextTok(); /// (
                        this.ts.nextTok(); /// {
                            
                        scopeName = this.fixAlias(aliases,scopeName);
                        var fnScope =  new Scope(this.braceNesting, scope, token.id, // was token.n?
            				scopeName,null
			        	); 
                        this.indexedScopes.set(this.ts.cursor,  fnScope);
                        scope = fnScope;
                        this.scopesIn(fnScope);
                         
                        locBraceNest++;
                        //print(">>" +locBraceNest);
                        
                        continue; // no more processing..
                    }
                    

                     
                    
                    
                    
                    
                    // eval can be prefixed with a hint hider for the compresser..
                    
                    
                    if (this.currentDoc != null) {
                        //print(token.toString());
                        
                        // ident : function ()
                        // ident = function ()
                        // this.ident = function()
                        var atype = "OBJECT";
                        
                        if (((this.ts.lookTok(1).data == ":" )|| (this.ts.lookTok(1).data == "=")) &&
                            (this.ts.lookTok(2).isName(TokenName.FUNCTION))
                            ) {
                               // this.ts.nextTok();
                               // this.ts.nextTok();
                                atype = "FUNCTION";
                        }
                        
                        //print("ADD SYM:" + atype + ":" + token.toString() + this.ts.lookTok(1).toString() + this.ts.lookTok(2).toString());
                        var tname = this.ts.lookTok(-1).data == "." ? token.data :    this.fixAlias(aliases,token.data);

                        if (/^this\./.match(tname)) {
                        	tname = tname.substring(5);
                        }
                        GLib.debug("Call addSymbol %s", tname);                        
                        this.addSymbol( tname, false, atype);
                        

                        this.currentDoc = null;
                        
                        
                        
                        
                        
                        
                    }
                 
                    
                    continue; // dont care about other idents..
                    
                }
                
                //print ("NOT NAME");
                
                
                if (token.isType(TokenType.STRN))   { // THIS WILL NOT HAPPEN HERE?!!?
                    if (this.currentDoc != null) {
                        GLib.debug("Call addSymbol %s", token.data.substring(1,token.data.length-1));
                        this.addSymbol(token.data.substring(1,token.data.length-1),false,"OBJECT");
                    }
                }
            
                // really we only have to deal with object constructs and function calls that change the scope...
                
                
                if (token.isName(TokenName.FUNCTION)) {
                	GLib.debug("Got Function");
                    //print("GOT FUNCTION");
                    // see if we have an unconsumed doc...
                    
	                if (this.currentDoc != null) {
                        GLib.error("Unhandled doc (TOKfunction) %s", token.asString());
                    }
                    
                     
                     
                     
                     
                    /// foo = function() {} << really it set"s the "this" scope to foo.prototype
                    //$this$=foo.prototype|$private$|foo.prototype
        
                    if (
                            (this.ts.lookTok(-1).data == "=") && 
                            (this.ts.lookTok(-2).isType(TokenType.NAME))
                        ) {

                        scopeName = this.ts.lookTok(-2).data;
                    	GLib.debug("Got %s = Function", scopeName);
                        this.ts.balance(TokenName.LEFT_PAREN);
                        token = this.ts.nextTok(); // should be {
                        //print("FOO=FUNCITON() {}" + this.ts.context() + "\n" + token.toString());
                        
                        
                        scopeName = this.fixAlias(aliases, scopeName);
                         
                        var fnScope =  new Scope(this.braceNesting, scope, token.id, // was token.n?
            				"$this$="+scopeName+".prototype|$private$|"+scopeName+".prototype",
            				null
			        	); 
                        
                        this.indexedScopes.set(this.ts.cursor, fnScope);
                        //scope = fnScope;
                        // this.scopesIn(fnScope);
                        this.parseScope(fnScope, aliases);
                        
                        
                       
                        locBraceNest++;
                        //print(">>" +locBraceNest);
                        continue; // no more processing..    
                          
                        
                    }
                        
                
                // foo = new function() {}
                        // is this actually used much!?!?! -- 
                        //$private$
                        
                    if (
                            (this.ts.lookTok(-1).isName(TokenName.NEW)) && 
                            (this.ts.lookTok(-2).data == "=") &&
                            (this.ts.lookTok(-3).isName(TokenName.FUNCTION))
                        ) {
                        //scopeName = this.ts.look(-3).data;
                        this.ts.balance(TokenName.LEFT_PAREN);
                        token = this.ts.nextTok(); // should be {
                        scopeName = this.fixAlias(aliases, scopeName);
                        var fnScope =  new Scope(this.braceNesting, scope, token.id, // was token.n?
            				"$private$",null
			        	); 
                        
                        
                        this.indexedScopes.set(this.ts.cursor,  fnScope);
                        //scope = fnScope;
                        // this.scopesIn(fnScope);
                        this.parseScope(fnScope, aliases);
                        
                        locBraceNest++;
                        //print(">>" +locBraceNest);
                        continue; // no more processing..    
                          
                        
                    }    
                   
                    
    ///==== check/set isObjectLitAr ??                
                    
                    
                 // foo: function() {}
                        // no change to scoping..
                        
                    //print("checking for : function() {"); 
                    //print( [this.ts.lookTok(-3).type , this.ts.lookTok(-2).type , this.ts.lookTok(-1).type ].join(":"));
                    if (
                            (this.ts.lookTok(-1).data == ":") && 
                            (this.ts.lookTok(-2).isType(TokenType.NAME)) &&
                            (this.ts.lookTok(-3).data == "(" || this.ts.lookTok(-3).data== ",") 
                        ) {
                        //print("got for : function() {"); 
                            
                        //scopeName = this.ts.look(-3).data;
                        this.ts.balance(TokenName.LEFT_PAREN);
                        //print(token.toString())
                        token = this.ts.nextTok(); // should be {
                        //print(token.toString())
                        
                        scopeName = this.fixAlias(aliases, scopeName);
                        var fnScope =  new Scope(this.braceNesting, scope, token.id, // was token.n?
            				"", null
			        	); 

                        this.indexedScopes.set(this.ts.cursor, fnScope);
                        //scope = fnScope;
                        // this.scopesIn(fnScope);
                         this.parseScope(fnScope, aliases);
                        locBraceNest++;
                        //print(">>" +locBraceNest);
                        continue; // no more processing..    
                          
                    } 
               /// function foo() {} << really it set"s the "this" scope to foo.prototype
                        //$this$=foo|$private$
                        //$this$=foo
                        
                    if (
                            (this.ts.lookTok(1).isType(TokenType.NAME)) 
                        ) {
                        //scopeName = this.ts.look(-3).data;
                        this.ts.balance(TokenName.LEFT_PAREN);
                        token = this.ts.nextTok(); // should be {
                        var fnScope =  new Scope(this.braceNesting, scope, token.id, // was token.n?
            				"", null
			        	); 

                        this.indexedScopes.set(this.ts.cursor, fnScope);
                        // scope = fnScope;
                        // this.scopesIn(fnScope);
                        this.parseScope(fnScope, aliases);
                        locBraceNest++;
                        //print(">>" +locBraceNest);
                        continue; // no more processing..    
                          
                    }
                    
                     // 0 == FUNCTION...
                     
                     // this is used in Roo.util.JSON
                     // XXXX = new (function() { 
                     
                      if (
                             (this.ts.lookTok(-1).data == "(") &&
                            (this.ts.lookTok(-2).data == "new" ) &&
                            (this.ts.lookTok(-3).data == "=") &&
                            (this.ts.lookTok(-4).isType(TokenType.NAME))
                        ) {
                        
                        
                        scopeName = this.ts.lookTok(-4).data;
                        this.ts.balance(TokenName.LEFT_PAREN);
                        token = this.ts.nextTok(); // should be {
                        var fnScope =  new Scope(this.braceNesting, scope, token.id, // was token.n?
        					"$this$="+scopeName+".prototype|$private$|"+scopeName+".prototype",null
			        	); 

                        this.indexedScopes.set(this.ts.cursor, fnScope);
                        //scope = ;
                        // this.scopesIn(fnScope);
                        this.parseScope(fnScope, aliases);
                        locBraceNest++;
                        //print(">>" +locBraceNest);
                        continue; // no more processing..    
                          
                        
                    }
                     
                // foo = new (function() { }
                // (function() { }
                // RETURN function(...) {
                    
                    if (
                           // (this.ts.lookTok(-1).tokN == Script.TOKlparen) && 
                            (!this.ts.lookTok(1).isType(TokenType.NAME))   
                            
                        //    (this.ts.lookTok(-2).tokN == Script.TOKnew) &&
                         //   (this.ts.lookTok(-3).tokN == Script.TOKassign) &&
                         //   (this.ts.lookTok(-4).tokN == Script.TOKidentifier)
                        ) {
                        
                        //scopeName = this.ts.look(-3).data;
                        this.ts.balance(TokenName.LEFT_PAREN);
                        token = this.ts.nextTok(); // should be {
                        var fnScope =  new Scope(this.braceNesting, scope, token.id, // was token.n?
        					"$private$",null
			        	); 

                        this.indexedScopes.set(this.ts.cursor, fnScope);
                        //scope = ;
                        // this.scopesIn(fnScope);
                         this.parseScope(fnScope, aliases);
                        locBraceNest++;
                        //print(">>" +locBraceNest);
                        continue; // no more processing..    
                          
                        
                    }
                    
                    GLib.error( "dont know how to handle function syntax??\n %s" +
                                token.asString());
                    
            
                    
                    continue;
                    
                    
                    
                    
                } // end checking for TOKfunction
                    
                if (token.data == "{") {
                    
                     // foo = { // !var!!!
                        //$this$=foo|Foo
               
                
                    if (
                            (this.ts.lookTok(-1).data == "=") &&
                            (this.ts.lookTok(-2).isType(TokenType.NAME)) &&
                            (!this.ts.lookTok(-3).isName(TokenName.VAR))  
                        ) {
                            
                            scopeName = this.ts.lookTok(-2).data;
                            //print(scopeName);
                            scopeName = this.fixAlias(aliases, scopeName);
                            GLib.debug("got %s = {", scopeName);
                            
                            //print(this.scopes.length);
                            var fnScope =  new Scope(this.braceNesting, scope, token.id, // was token.n?
		    					"$this$=" + scopeName +"|"+scopeName, null
					    	); 
                            
                            this.indexedScopes.set(this.ts.cursor, fnScope);
                            scope = fnScope;
                            // push the same scope onto the stack..
                            this.scopesIn(fnScope);
                            // this.scopesIn(this.scopes[this.scopes.length-1]);
                            
                              
                            locBraceNest++;
                            //print(">>" +locBraceNest);
                            continue; // no more processing..   
                    }
                    // foo : {
                    // ?? add |foo| ????
                      
                    //print("GOT LBRACE : check for :");
                    if (
                            (this.ts.lookTok(-1).data == ":") &&
                            (this.ts.lookTok(-2).isType(TokenType.NAME)) &&
                            (!this.ts.lookTok(-3).isName(TokenName.VAR)) 
                        ) {
                            
                            scopeName = this.ts.lookTok(-2).data;
                            scopeName = this.fixAlias(aliases, scopeName);
                            var fnScope =  new Scope(this.braceNesting, scope, token.id, // was token.n?
        						scopeName, null
				        	); 

                            this.indexedScopes.set(this.ts.cursor, fnScope);
                            scope = fnScope;
                            this.scopesIn(fnScope);
                            
                            locBraceNest++;
                            //print(">>" +locBraceNest);
                            continue; // no more processing..   
                    }
                    var fnScope =  new Scope(this.braceNesting, scope, token.id, // was token.n?
						"", null
		        	); 

                    this.indexedScopes.set(this.ts.cursor, fnScope);
                    scope = fnScope;
                    this.scopesIn(fnScope);
                   
                    locBraceNest++;
                    //print(">>" +locBraceNest);
                    continue;
                    
                }
                if (token.data == "}") {
                    
                     
                        if (this.currentDoc != null) {
							 GLib.debug("Call addSymbol EMPTY");
                            this.addSymbol("", true);

                            //throw "Unconsumed Doc: (TOKrbrace)" + this.currentDoc.toSource();
                        }
                        
                       
                        locBraceNest--;
                        
                            //assert braceNesting >= scope.getBraceNesting();
                        var closescope = this.scopeOut();
                        
                        scope = this.scopes.get(this.scopes.size-1);
                        
                        //print("<<:" +  locBraceNest)
                        //print("<<<<<< " + locBraceNest );
                        if (locBraceNest < 0) {
                           // print("POPED OF END OF SCOPE!");
                            // this.scopeOut();   
                            // var ls = this.scopeOut();
                            // ls.getUsedSymbols();
                            return;
                        }
                        continue;
                }
              
                
            }
            
            
        }
     
         
        void addSymbol(string in_lastIdent, bool appendIt = false, string atype = "OBJECT")
        {
            
            GLib.debug("addSymbol %s", in_lastIdent);
            var lastIdent = in_lastIdent;
            if (this.currentDoc.getTag(DocTagTitle.PRIVATE).size > 0) {
                
              
                //print(this.currentDoc.toSource());
                 this.currentDoc = null;
                //print("SKIP ADD SYM:  it"s private");
                return;
            }
            
            var token = this.ts.lookTok(0);
          
          //  print(this.currentDoc.toSource(););
            if (this.currentDoc.getTag(DocTagTitle.EVENT).size > 0) {
                //?? why does it end up in desc - and not name/...
                //print(this.currentDoc.getTag("event")[0]);
                lastIdent = "*" + this.currentDoc.getTag(DocTagTitle.EVENT).get(0).desc;
                //lastIdent = "*" + lastIdent ;
            }
            if (lastIdent.length < 1 && this.currentDoc.getTag(DocTagTitle.PROPERTY).size > 0) {
                lastIdent = this.currentDoc.getTag(DocTagTitle.PROPERTY).get(0).name;
                //lastIdent = "*" + lastIdent ;
            }
            
            var _s = lastIdent;
            if (!/\./.match(_s)) {
                    
                //print("WALKER ADDsymbol: " + lastIdent);
                
                string[] s = {};
                GLib.debug("Checking Scopes %d", this.scopes.size);
                for (var i = 0; i < this.scopes.size;i++) {
                    GLib.debug("Scope %s", this.scopes.get(i).ident);
	                var adds = this.scopes.get(i).ident;
	                
                    s = s + adds;
                }
                s += lastIdent;
                
                GLib.debug("FULLSCOPE: '%s'" , string.joinv("', '", s));
                
                
                s = string.joinv("|", s).split("|");
                //print("FULLSCOPE: " + s);
             //  print("Walker:ADDSymbol: " + s.join("|") );
                var _t = "";
                 _s = "";
                
                /// fixme - needs
                for (var i = 0; i < s.length;i++) {
                    
                    if (s[i].length < 1) {
                        continue;
                    }
                    if ((s[i] == "$private$") || (s[i] == "$global$")) {
                        _s = "";
                        continue;
                    }
                    if (s[i].length > 5 &&  s[i].substring(0,6) == "$this$") {
                        var ts = s[i].split("=");
                        _t = ts[1];
                        _s = ""; // ??? VERY QUESTIONABLE!!!
                        continue;
                    }
                    // when to use $this$ (probabl for events)
                    _s += _s.length > 0 ? "." : "";
                    _s += s[i];
                }
                GLib.debug("FULLSCOPE: _s=%s (append = %s)" , _s, appendIt? "YES": "no");
                
                /// calc scope!!
                //print("ADDING SYMBOL: "+ s.join("|") +"\n"+ _s + "\n" +Script.prettyDump(this.currentDoc.toSource()));
                //print("Walker.addsymbol - add : " + _s);
                
                
                if (appendIt && lastIdent.length < 1) {
                    
                    // append, and no symbol???
                    
                    // see if it"s a @class
                    if (this.currentDoc.getTag(DocTagTitle.CLASS).size > 0) {
                        _s = this.currentDoc.getTag(DocTagTitle.CLASS).get(0).desc;
                        var symbol = new Symbol.new_populate_with_args(_s, new Gee.ArrayList<string>(),
                        		 "CONSTRUCTOR", this.currentDoc);
                       
                        DocParser.addSymbol(symbol);
                        this.symbols[_s] = symbol;
                        return;
                    }
                    
                   // if (this.currentDoc.getTag("property").length) {
                     //   print(Script.pretStringtyDump(this.currentDoc.toSource));
                    //    throw "Add Prop?";
                    //}

                    _s = /\.prototype.*$/.replace(_s, _s.length,0, "");
                    
                    if (!this.symbols.has_key(_s)) {
                        //print("Symbol:" + _s);
                    	//print(this.currentDoc.src);
                        
                        //throw {
                        //    name: "ArgumentError", 
                        //    message: "Trying to append symbol "" + _s + "", but no doc available\n" +
                        //        this.ts.lookTok(0).toString()
                        //};
                        this.currentDoc = null;
                        return;
                     
                    }
                    GLib.debug("add to symbol  _s=%s  " , _s);    
                    for (var i =0; i < this.currentDoc.tags.size;i++) {
                        this.symbols.get(_s).addDocTag(this.currentDoc.tags.get(i));
                    } 
                    this.currentDoc = null;
                    return;
                }
            }    
            //print("Walker.addsymbol - chkdup: " + _s);
            if (this.symbols.has_key(_s)) {
                
                if (this.symbols.get(_s).comment.hasTags) {
                    // then existing comment doesnt has tags 
                    //throw {
                    //    name: "ArgumentError", 
                     //   message:"DUPLICATE Symbol " + _s + "\n" + token.toString()
                    //};
                    return;
                }
                // otherwise existing comment has tags - overwrite..
                
                
            }
            //print("Walker.addsymbol - ATYPE: " + _s);



            
            //print("Walker.addsymbol - add : ");
            var symbol = new Symbol.new_populate_with_args(
            		_s, new Gee.ArrayList<string>(), atype, this.currentDoc);

            DocParser.addSymbol(symbol);
            this.symbols[_s] = symbol;
            
             this.currentDoc = null;
            
        }
        
        
        
        
        void scopesIn  (Scope s)
        {
            this.scopes.add(s);
            //print(">>>" + this.ts.context()  + "\n>>>"+this.scopes.length+":" +this.scopeListToStr());
            
        }
        Scope scopeOut()
        {
            
           // print("<<<" + this.ts.context()  + "\n<<<"+this.scopes.length+":" +this.scopeListToStr());
            return this.scopes.remove_at(this.scopes.size -1 );
            
        }
        
        string scopeListToStr ()
        {
            string[] s = {};
            for (var i = 0; i < this.scopes.size;i++) {
                s +=(this.scopes[i].ident);
            }
            return  string.joinv("\n\t",s);
            
        }
        
    }
    
     
}