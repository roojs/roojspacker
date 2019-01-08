// this walks through the code, and tries to find patterns that match documentable elements..


namespace JSDOC {

	enum WalkerMode {
		BUILDING_SYMBOL_TREE,
		XXX
	}
	
	class Walker  : Object
	{
		TokenStream ts;
		Gee.ArrayList<string> warnings;
		Gee.ArrayList<Scope> scopes;
		Gee.ArrayList<string,Scope> indexedScopes;
		Gee.ArrayList<Symbol> symbols;
		Gee.HashMap<string,string> aliases;
		Scope globalScope;
		
        bool global = false;
        WalkerMode mode =  ""; //"BUILDING_SYMBOL_TREE",
        int braceNesting : 0;
        
//        bool currentDoc =  false;

        bool munge =  true;
		
		public Walker(TokenStream ts)
		{
			this.ts  = ts;
			this.warnings= new Gee.ArrayList<string>();
			this.scopes = new Gee.ArrayList<Scope>();
			this.indexedScopes = new Gee.ArrayList<int,Scope>();
			this.symbols = new Gee.ArrayList<Symbol>();
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
             
            this.globalScope = new Scope(-1, null, -1, "$global$");
            this.indexedScopes = new Gee.ArrayList<int,Scope>();
            this.indexedScopes.set(  0,  this.globalScope );
            
            this.mode = WalkerMode.BUILDING_SYMBOL_TREE;
            this.parseScope(this.globalScope);
            
        }
        

        string fixAlias (Gee.HashMap<string,string>aliases, string str, bool nomore)
        {
            var ar = str.split('.');
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
        };

       



        parseScope : function(scope, ealiases) // parse a token stream..
        {
            //this.timerPrint("parseScope EnterScope"); 
            
            var aliases = new Gee.HashMap<string,string>();

            for(var i in ealiases.keys) {
                aliases.set(i, ealiases.get(i);
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
            
            while (null != (var token = this.ts.next())) {
                //print("TOK"+ token.toString());
                //  this.timerPrint("parseScope AFTER lookT: " + token.toString()); 
                  
                if (token.is('COMM')) {
                      
                 
                    if (token.name != 'JSDOC') {
                        //print("Walker2 : spce is not JSDOC");
                        continue; //skip.
                    }
                    if (this.currentDoc) {
                        // add it to the current scope????
                        
                        this.addSymbol('', true);
                        //print ( "Unconsumed Doc: " + token.toString())
                        //throw "Unconsumed Doc (TOKwhitespace): " + this.currentDoc.toSource();
                    }
                    
                   // print ( "NEW COMMENT: " + token.toString())
                    var newDoc = new DocComment(token.data);
                    
                    // it's a scope changer..
                    if (newDoc.getTag("scope").length) {
                        //print("Walker2 : doctag changes scope");
                        //throw "done";
                        scope.ident = '$private$|' + newDoc.getTag("scope")[0].desc;
                        continue;
                    }
                    
                    // it's a scope changer..
                    if (newDoc.getTag("scopeAlias").length) {
                        //print(newDoc.getTag("scopeAlias").toSource());
                        // @scopeAlias a=b
                        //print("Walker2 : doctag changes scope (alias)");
                        var sal = newDoc.getTag("scopeAlias")[0].desc.split("=");
                        aliases[sal[0]] = sal[1];
                        
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
                
                if (this.currentDoc && (
                        token.data == ';' || 
                        token.data == '}')) {
                    this.addSymbol('', true);
                    //throw "Unconsumed Doc ("+ token.toString() +"): " + this.currentDoc.toSource();
                }
                    
                
                // the rest are scoping issues...
                
                // var a = b;
                
                 if (token.name == 'VAR' &&
                 
                        this.ts.lookTok(1).type == 'NAME' &&
                        this.ts.lookTok(2).data == '=' &&
                        this.ts.lookTok(3).type == 'NAME'  &&
                        this.ts.lookTok(4).data == ';'  
                        
                 
                 ) {
                    //print("SET ALIAS:" + this.ts.lookTok(1).data +'=' + this.ts.lookTok(3).data);
                     
                    aliases[this.ts.lookTok(1).data] = this.ts.lookTok(3).data;
                    
                
                }
                
                if ((token.data == 'eval') || /\.eval$/.test(token.data)) {
                    this.currentDoc = false;
                    continue;
                }
              
                // extends scoping  *** not sure if the can be x = Roo.apply(....)
                // xxx.extends(a,b, {
                    // $this$=b|b.prototype
                // xxx.apply(a, {
                    // a  << scope
                // xxx.applyIf(a, {
                    // a  << scope
                if (token.type == 'NAME') {
                    
                    //print("TOK(ident)"+ token.toString());
                     
                    if (/\.extend$/.test(token.data) &&
                        this.ts.lookTok(1).data == '(' &&
                        this.ts.lookTok(2).type == 'NAME' &&
                        this.ts.lookTok(3).data == ',' &&
                        this.ts.lookTok(4).type == 'NAME' &&
                        this.ts.lookTok(5).data == ',' &&
                        this.ts.lookTok(6).data == '{' 
                           
                        ) {
                        // ignore test for ( a and ,
                        this.ts.nextTok(); /// (
                        token = this.ts.nextTok(); // a
                        scopeName = token.data;
                        
                        if (this.currentDoc) {
                            this.addSymbol(scopeName,false,'OBJECT');

                        }
                        this.ts.nextTok(); // ,
                        this.ts.nextTok(); // b
                        
                        
                        this.ts.nextTok(); // ,
                        token = this.ts.nextTok(); // {
                            
                        scopeName = fixAlias(scopeName);
                        
                        var fnScope = new Scope(this.braceNesting, scope, token.n, 
                            '$this$=' + scopeName  + '|'+scopeName+'.prototype');
                        this.indexedScopes[this.ts.cursor] = fnScope;
                        scope = fnScope;
                        this.scopesIn(fnScope);
                       
                        locBraceNest++;
                        //print(">>" +locBraceNest);
                        continue; // no more processing..
                        
                    }
                    
                    // a = Roo.extend(parentname, {
                        
                     if (/\.extend$/.test(token.data) &&
                        this.ts.lookTok(-2).type == 'NAME'  &&
                        this.ts.lookTok(-1).data == '=' &&
                        this.ts.lookTok(1).data == '(' &&
                        this.ts.lookTok(2).type == 'NAME' &&
                        this.ts.lookTok(3).data == ',' &&
                        this.ts.lookTok(4).data == '{' 
                        ) {
                        // ignore test for ( a and ,
                        token = this.ts.lookTok(-2);
                        scopeName = token.data;
                        if (this.currentDoc) {
                            this.addSymbol(scopeName,false,'OBJECT');

                        }
                        this.ts.nextTok(); /// (
                        this.ts.nextTok(); // parent
                        
                        this.ts.nextTok(); // ,
                        token =  this.ts.nextTok(); // {
                             
                        
                        scopeName = fixAlias(scopeName);
                        var fnScope = new Scope(this.braceNesting, scope, token.n, 
                            '$this$=' + scopeName  + '|'+scopeName+'.prototype');
                        this.indexedScopes[this.ts.cursor] = fnScope;
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
                    
                    if (/\.(applyIf|apply)$/.test(token.data) && 
                        this.ts.lookTok(1).data == '('  &&
                        this.ts.lookTok(2).type == 'NAME' &&
                        this.ts.lookTok(3).data == ','  &&
                        this.ts.lookTok(4).data == '{' 
                        
                        ) {
                        this.ts.nextTok(); /// (
                         
                        //print("GOT : applyIF!"); 
                         
                        token = this.ts.nextTok(); // b
                        scopeName = token.data;
                        
                                      
                        if (this.currentDoc) {
                            this.addSymbol(scopeName,false,'OBJECT');
                        }
                     

                        
                        this.ts.nextTok(); /// ,
                        this.ts.nextTok(); // {
                        scopeName = fixAlias(scopeName);
                        var fnScope = new Scope(this.braceNesting, scope, token.n, scopeName);
                        this.indexedScopes[this.ts.cursor] = fnScope;
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
                    if ( this.ts.lookTok(1).data == '=' &&
                        this.ts.lookTok(2).name == 'NEW' &&
                        this.ts.lookTok(3).type == 'NAME' &&
                        this.ts.lookTok(4).data == '(' &&
                        this.ts.lookTok(5).data == '{' 
                        ) {
                        scopeName = token.data;
                        if (this.currentDoc) {
                            this.addSymbol(scopeName,false,'OBJECT');
                            
                        }
                        
                        this.ts.nextTok(); /// =
                        this.ts.nextTok(); /// new
                        this.ts.nextTok(); /// yyy
                        this.ts.nextTok(); /// (
                        this.ts.nextTok(); /// {
                            
                        scopeName = fixAlias(scopeName);
                        var fnScope = new Scope(this.braceNesting, scope, token.n, scopeName);
                        this.indexedScopes[this.ts.cursor] = fnScope;
                        scope = fnScope;
                        this.scopesIn(fnScope);
                         
                        locBraceNest++;
                        //print(">>" +locBraceNest);
                        
                        continue; // no more processing..
                    }
                    

                     
                    
                    
                    
                    
                    // eval can be prefixed with a hint hider for the compresser..
                    
                    
                    if (this.currentDoc) {
                        //print(token.toString());
                        
                        // ident : function ()
                        // ident = function ()
                        var atype = 'OBJECT';
                        
                        if (((this.ts.lookTok(1).data == ':' )|| (this.ts.lookTok(1).data == '=')) &&
                            (this.ts.lookTok(2).name == "FUNCTION")
                            ) {
                               // this.ts.nextTok();
                               // this.ts.nextTok();
                                atype = 'FUNCTION';
                        }
                        
                        //print("ADD SYM:" + atype + ":" + token.toString() + this.ts.lookTok(1).toString() + this.ts.lookTok(2).toString());
                        
                        this.addSymbol(
                            this.ts.lookTok(-1).data == '.' ? token.data :    fixAlias(token.data),
                            false,
                            atype);
                        
                        this.currentDoc = false;
                        
                        
                    }
                 
                    
                    continue; // dont care about other idents..
                    
                }
                
                //print ("NOT NAME");
                
                
                if (token.type == "STRN")   { // THIS WILL NOT HAPPEN HERE?!!?
                    if (this.currentDoc) {
                        this.addSymbol(token.data.substring(1,token.data.length-1),false,'OBJECT');

                    }
                }
            
                // really we only have to deal with object constructs and function calls that change the scope...
                
                
                if (token.name == 'FUNCTION') {
                    //print("GOT FUNCTION");
                    // see if we have an unconsumed doc...
                    
                    if (this.currentDoc) {
                            throw {
                                name: "ArgumentError", 
                                message: "Unhandled doc (TOKfunction)" + token.toString()
                            };
                            
                            //this.addSymbol(this.currentDoc.getTag('class')[0].name, true);

                            //throw "Unconsumed Doc: (TOKrbrace)" + this.currentDoc.toSource();
                    }
                    
                     
                     
                     
                     
                    /// foo = function() {} << really it set's the 'this' scope to foo.prototype
                    //$this$=foo.prototype|$private$|foo.prototype
        
                    if (
                            (this.ts.lookTok(-1).data == '=') && 
                            (this.ts.lookTok(-2).type == 'NAME')
                        ) {
                        scopeName = this.ts.lookTok(-2).data;
                        this.ts.balance('(');
                        token = this.ts.nextTok(); // should be {
                        //print("FOO=FUNCITON() {}" + this.ts.context() + "\n" + token.toString());
                        
                        
                        scopeName = fixAlias(scopeName);
                        var fnScope = new Scope(this.braceNesting, scope, token.n, 
                            '$this$='+scopeName+'.prototype|$private$|'+scopeName+'.prototype');
                            
                        this.indexedScopes[this.ts.cursor] = fnScope;
                        //scope = fnScope;
                        //this.scopesIn(fnScope);
                        this.parseScope(fnScope, aliases);
                        
                        
                       
                        locBraceNest++;
                        //print(">>" +locBraceNest);
                        continue; // no more processing..    
                          
                        
                    }
                        
                
                // foo = new function() {}
                        // is this actually used much!?!?!
                        //$private$
                        
                    if (
                            (this.ts.lookTok(-1).name == 'NEW') && 
                            (this.ts.lookTok(-2).data == '=') &&
                            (this.ts.lookTok(-3).type = 'FUNCTION')
                        ) {
                        //scopeName = this.ts.look(-3).data;
                        this.ts.balance("(");
                        token = this.ts.nextTok(); // should be {
                            scopeName = fixAlias(scopeName);
                        var fnScope = new Scope(this.braceNesting, scope, token.n, '$private$');
                        this.indexedScopes[this.ts.cursor] = fnScope;
                        //scope = fnScope;
                        //this.scopesIn(fnScope);
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
                            (this.ts.lookTok(-1).data == ':') && 
                            (this.ts.lookTok(-2).type == 'NAME') &&
                            (this.ts.lookTok(-3).data == '(' || this.ts.lookTok(-3).data== ',') 
                        ) {
                        //print("got for : function() {"); 
                            
                        //scopeName = this.ts.look(-3).data;
                        this.ts.balance('(');
                        //print(token.toString())
                        token = this.ts.nextTok(); // should be {
                        //print(token.toString())
                        scopeName = fixAlias(scopeName);
                        var fnScope = new Scope(this.braceNesting, scope, token.n, '');
                        this.indexedScopes[this.ts.cursor] = fnScope;
                        //scope = fnScope;
                        //this.scopesIn(fnScope);
                         this.parseScope(fnScope, aliases);
                        locBraceNest++;
                        //print(">>" +locBraceNest);
                        continue; // no more processing..    
                          
                    } 
               /// function foo() {} << really it set's the 'this' scope to foo.prototype
                        //$this$=foo|$private$
                        //$this$=foo
                        
                    if (
                            (this.ts.lookTok(1).type == 'NAME') 
                        ) {
                        //scopeName = this.ts.look(-3).data;
                        this.ts.balance('(');
                        token = this.ts.nextTok(); // should be {
                            
                        var fnScope = new Scope(this.braceNesting, scope, token.n, '');
                        this.indexedScopes[this.ts.cursor] = fnScope;
                        //scope = fnScope;
                        //this.scopesIn(fnScope);
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
                            (this.ts.lookTok(1).name != 'NAME')   
                            
                        //    (this.ts.lookTok(-2).tokN == Script.TOKnew) &&
                         //   (this.ts.lookTok(-3).tokN == Script.TOKassign) &&
                         //   (this.ts.lookTok(-4).tokN == Script.TOKidentifier)
                        ) {
                        //scopeName = this.ts.look(-3).data;
                        this.ts.balance('(');
                        token = this.ts.nextTok(); // should be {
                        var fnScope = new Scope(this.braceNesting, scope, token.n, '$private$');
                        this.indexedScopes[this.ts.cursor] = fnScope;
                        //scope = ;
                        //this.scopesIn(fnScope);
                         this.parseScope(fnScope, aliases);
                        locBraceNest++;
                        //print(">>" +locBraceNest);
                        continue; // no more processing..    
                          
                        
                    }
                    
                    
                    throw {
                        name: "ArgumentError", 
                        message: "dont know how to handle function syntax??\n" +
                                token.toString()
                    };
            
                    
                    continue;
                    
                    
                    
                    
                } // end checking for TOKfunction
                    
                if (token.data == '{') {
                    
                     // foo = { // !var!!!
                        //$this$=foo|Foo
               
                
                    if (
                            (this.ts.lookTok(-1).data == '=') &&
                            (this.ts.lookTok(-2).type == 'NAME') &&
                            (this.ts.lookTok(-3).name != 'VAR')  
                        ) {
                            
                            scopeName = this.ts.look(-2).data;
                            //print(scopeName);
                            scopeName = fixAlias(scopeName);
                            
                            //print(this.scopes.length);
                            var fnScope = new Scope(this.braceNesting, scope, token.n, 
                                '$this$='+scopeName + '|'+scopeName
                            );
                            
                            this.indexedScopes[this.ts.cursor] = fnScope;
                            scope = fnScope;
                            // push the same scope onto the stack..
                            this.scopesIn(fnScope);
                            //this.scopesIn(this.scopes[this.scopes.length-1]);
                            
                              
                            locBraceNest++;
                            //print(">>" +locBraceNest);
                            continue; // no more processing..   
                    }
                    // foo : {
                    // ?? add |foo| ????
                      
                    //print("GOT LBRACE : check for :");
                    if (
                            (this.ts.lookTok(-1).data == ':') &&
                            (this.ts.lookTok(-2).type == 'NAME') &&
                            (this.ts.lookTok(-3).name != 'VAR') 
                        ) {
                            
                            scopeName = this.ts.lookTok(-2).data;
                            scopeName = fixAlias(scopeName);
                            var fnScope = new Scope(this.braceNesting, scope, token.n, scopeName);
                            this.indexedScopes[this.ts.cursor] = fnScope;
                            scope = fnScope;
                            this.scopesIn(fnScope);
                            
                            locBraceNest++;
                            //print(">>" +locBraceNest);
                            continue; // no more processing..   
                    }
                    var fnScope = new Scope(this.braceNesting, scope, token.n, '');
                    this.indexedScopes[this.ts.cursor] = fnScope;
                    scope = fnScope;
                    this.scopesIn(fnScope);
                   
                    locBraceNest++;
                    //print(">>" +locBraceNest);
                    continue;
                    
                }
                if (token.data == '}') {
                    
                     
                        if (this.currentDoc) {
                            this.addSymbol('', true);

                            //throw "Unconsumed Doc: (TOKrbrace)" + this.currentDoc.toSource();
                        }
                        
                       
                        locBraceNest--;
                        
                            //assert braceNesting >= scope.getBraceNesting();
                        var closescope = this.scopeOut();   
                        scope = this.scopes[this.scopes.length-1];
                        //print("<<:" +  locBraceNest)
                        //print("<<<<<< " + locBraceNest );
                        if (locBraceNest < 0) {
                           // print("POPED OF END OF SCOPE!");
                            ///this.scopeOut();   
                            //var ls = this.scopeOut();
                            //ls.getUsedSymbols();
                            return;
                        }
                        continue;
                }
              
                
            }
            
            
        },
     
         
        addSymbol: function(lastIdent, appendIt, atype )
        {
            //print("Walker.addSymbol : " + lastIdent);
           // print("Walker.curdoc: " + JSON.stringify(this.currentDoc, null,4));
            
            /*if (!this.currentDoc.tags.length) {
                
              
                //print(this.currentDoc.toSource());
                //  this.currentDoc = false;
                
                print("SKIP ADD SYM: no tags");
                print(this.currentDoc.src);
                return;
            }
            */
            if (this.currentDoc.getTag('private').length) {
                
              
                //print(this.currentDoc.toSource());
                 this.currentDoc = false;
                //print("SKIP ADD SYM:  it's private");
                return;
            }
            
            var token = this.ts.lookTok(0);
            if (typeof(appendIt) == 'undefined') {
                appendIt= false;
            }
          //  print(this.currentDoc.toSource(););
            if (this.currentDoc.getTag('event').length) {
                //?? why does it end up in desc - and not name/...
                //print(this.currentDoc.getTag('event')[0]);
                lastIdent = '*' + this.currentDoc.getTag('event')[0].desc;
                //lastIdent = '*' + lastIdent ;
            }
            if (!lastIdent.length && this.currentDoc.getTag('property').length) {
                lastIdent = this.currentDoc.getTag('property')[0].name;
                //lastIdent = '*' + lastIdent ;
            }
            
            var _s = lastIdent;
            if (!/\./.test(_s)) {
                    
                //print("WALKER ADDsymbol: " + lastIdent);
                
                var s = [];
                for (var i = 0; i < this.scopes.length;i++) {
                    s.push(this.scopes[i].ident);
                }
                s.push(lastIdent);
                
                //print("FULLSCOPE: " + JSON.stringify(s));
                
                
                var s = s.join('|').split('|');
                //print("FULLSCOPE: " + s);
             //  print("Walker:ADDSymbol: " + s.join('|') );
                var _t = '';
                 _s = '';
                
                /// fixme - needs
                for (var i = 0; i < s.length;i++) {
                    
                    if (!s[i].length) {
                        continue;
                    }
                    if ((s[i] == '$private$') || (s[i] == '$global$')) {
                        _s = '';
                        continue;
                    }
                    if (s[i].substring(0,6) == '$this$') {
                        var ts = s[i].split('=');
                        _t = ts[1];
                        _s = ''; // ??? VERY QUESTIONABLE!!!
                        continue;
                    }
                    // when to use $this$ (probabl for events)
                    _s += _s.length ? '.' : '';
                    _s += s[i];
                }
                //print("FULLSCOPE: s , t : " + _s +', ' + _t);
                
                /// calc scope!!
                //print("ADDING SYMBOL: "+ s.join('|') +"\n"+ _s + "\n" +Script.prettyDump(this.currentDoc.toSource()));
                //print("Walker.addsymbol - add : " + _s);
                if (appendIt && !lastIdent.length) {
                    
                    // append, and no symbol???
                    
                    // see if it's a @class
                    if (this.currentDoc.getTag('class').length) {
                        _s = this.currentDoc.getTag('class')[0].desc;
                        var symbol = new Symbol(_s, [], "CONSTRUCTOR", this.currentDoc);
                        Parser       = imports.Parser.Parser;
                        Parser.addSymbol(symbol);
                        this.symbols[_s] = symbol;
                        return;
                    }
                    
                   // if (this.currentDoc.getTag('property').length) {
                     //   print(Script.pretStringtyDump(this.currentDoc.toSource));
                    //    throw "Add Prop?";
                    //}
                    
                    _s = _s.replace(/\.prototype.*$/, '');
                    if (typeof(this.symbols[_s]) == 'undefined') {
                        //print("Symbol:" + _s);
                    //print(this.currentDoc.src);
                        
                        //throw {
                        //    name: "ArgumentError", 
                        //    message: "Trying to append symbol '" + _s + "', but no doc available\n" +
                        //        this.ts.lookTok(0).toString()
                        //};
                        this.currentDoc = false;
                        return;
                     
                    }
                        
                    for (var i =0; i < this.currentDoc.tags.length;i++) {
                        this.symbols[_s].addDocTag(this.currentDoc.tags[i]);
                    }
                    this.currentDoc = false;
                    return;
                }
            }    
            //print("Walker.addsymbol - chkdup: " + _s);
            if (typeof(this.symbols[_s]) != 'undefined') {
                
                if (this.symbols[_s].comment.hasTags) {
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

            if (typeof(atype) == "undefined") {
                atype = 'OBJECT'; //this.currentDoc.getTag('class').length ? 'OBJECT' : 'FUNCTION';;
               }
            
            //print("Walker.addsymbol - add : ");
            var symbol = new Symbol(_s, [], atype, this.currentDoc);
            Parser       = imports.Parser.Parser;
            Parser.addSymbol(symbol);
            this.symbols[_s] = symbol;
            
             this.currentDoc = false;
            
        },
        
        
        
        
        scopesIn : function(s)
        {
            this.scopes.push(s);
            //print(">>>" + this.ts.context()  + "\n>>>"+this.scopes.length+":" +this.scopeListToStr());
            
        },
        scopeOut : function()
        {
            
           // print("<<<" + this.ts.context()  + "\n<<<"+this.scopes.length+":" +this.scopeListToStr());
            return this.scopes.pop();
            
        },
        
        scopeListToStr : function()
        {
            var s = [];
            for (var i = 0; i < this.scopes.length;i++) {
                s.push(this.scopes[i].ident);
            }
            return  s.join('\n\t');
            
        }
        
    
    
     
});