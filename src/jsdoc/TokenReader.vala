//<script type="text/javascript">

 
// test code
 
//const Token   = imports.Token.Token;
//const Lang    = imports.Lang.Lang;

/**
	@class Search a {@link JSDOC.TextStream} for language tokens.
*/
 
namespace JSDOC {

    public class TokenArray: Object {
        
        public Gee.ArrayList<Token> tokens;
        Token lastAdded = null;
        
        public int length {
            get { return this.tokens.size; }
        }
        
        public TokenArray()
        {
            this.tokens = new Gee.ArrayList<Token>();
        }
        
        public Token? last() {
            if (this.tokens.size > 0) {
                return this.tokens.get(this.tokens.size-1);
            }
            return null;
        }
        public Token? lastSym () {
            for (var i = this.tokens.size-1; i >= 0; i--) {
                if (!(this.tokens.get(i).isType(TokenType.WHIT) || this.tokens.get(i).isType(TokenType.COMM)))  {
                    return this.tokens.get(i);
                }
            }
            return null;
        }

        
        public void push (Token t) 
        {
    		if (this.lastAdded != null &&
    			 this.lastAdded.isType(TokenType.NAME) &&
    			 (
    				t.isType(TokenType.NAME) ||     // NAME -> ???
    				(t.isType(TokenType.KEYW)  && 
		    			!(t.isName(TokenName.IN) || t.isName(TokenName.INSTANCEOF) || t.isName(TokenName.INSTANCEOF))
	    			)
				)
			) {
				throw new TokenReader_Error.ArgumentError(
					 "File:%s, line %d Error - NAME token followed by %s ".printf( "??", t.line,  t.name.to_string())
				);
    		}
    		// other pattern that are not valid
    		
            this.tokens.add(t);
            
            if (t.isType(TokenType.WHIT) || t.isType(TokenType.COMM)){
               // do not set last...
            } else {
        		this.lastAdded = t;
            }
            
        }
        public Token? pop ()
        {
            if (this.tokens.size > 0) {
                return this.tokens.remove_at(this.tokens.size-1);
            }
            return null;
        }
        
 	    public new Token get(int i) {
            return this.tokens.get(i);
        }
        public void dump()
        {
    		foreach(var token in this.tokens) {
    			stdout.printf ("%s\n", token.asString());
    		}
        }
        
    }

    public errordomain TokenReader_Error {
            ArgumentError
    }
    

    public class TokenReader : Object
    {
        
        
        
        /*
         *
         * I wonder if this will accept the prop: value, prop2 :value construxtor if we do not define one...
         */
        
        /** @cfg {Boolean} collapseWhite merge multiple whitespace/comments into a single token **/
        public bool collapseWhite = false; // only reduces white space...
        /** @cfg {Boolean} keepDocs keep JSDOC comments **/
        public bool keepDocs = true;
        /** @cfg {Boolean} keepWhite keep White space **/
        public bool keepWhite = false;
        /** @cfg {Boolean} keepComments  keep all comments **/
        public bool keepComments = false;
        /** @cfg {Boolean} sepIdents seperate identifiers (eg. a.b.c into ['a', '.', 'b', '.', 'c'] ) **/
        public bool sepIdents = false;
        /** @cfg {String} filename name of file being parsed. **/
        public string filename = "";
        /** @config {Boolean} ignoreBadGrammer do not throw errors if we find stuff that might break compression **/
        public bool ignoreBadGrammer = false;
        
        
        int line = 0;
        
        /**
         * tokenize a stream
         * @return {Array} of tokens
         * 
         * ts = new TextStream(File.read(str));
         * tr = TokenReader({ keepComments : true, keepWhite : true });
         * tr.tokenize(ts)
         * 
         */
        public TokenArray tokenize(TextStream stream)
        {
            this.line =1;
            var tokens = new TokenArray();
           
         
            while (!stream.lookEOF()) {
                

                if (this.read_mlcomment(stream, tokens)) continue;
                if (this.read_slcomment(stream, tokens)) continue;
                if (this.read_dbquote(stream, tokens))   continue;
                if (this.read_snquote(stream, tokens))   continue;
                if (this.read_regx(stream, tokens))      continue;
                if (this.read_numb(stream, tokens))      continue;
                if (this.read_punc(stream, tokens))      continue;
                if (this.read_newline(stream, tokens))   continue;
                if (this.read_space(stream, tokens))     continue;
                if (this.read_word(stream, tokens))      continue;
                
                // if execution reaches here then an error has happened
                tokens.push(
                        new Token(stream.nextS(), TokenType.TOKN, TokenName.UNKNOWN_TOKEN, this.line)
                );
            }
            
            
            
            return tokens;
        }

        /**
         * findPuncToken - find the id of a token (previous to current)
         * need to back check syntax..
         * 
         * @arg {Array} tokens the array of tokens.
         * @arg {String} token data (eg. '(')
         * @arg {Number} offset where to start reading from
         * @return {Number} position of token
         */
        public int findPuncToken(TokenArray tokens, string data, int n)
        {
            n = n > 0 ? n :  tokens.length -1;
            var stack = 0;
            while (n > -1) {
                
                if (stack < 1 && tokens.get(n).data == data) {
                    return n;
                }
                
                if (tokens.get(n).data  == ")" || tokens.get(n).data  == "}") {
                    stack++;
                    n--;
                    continue;
                }
                if (stack > 0 && (tokens.get(n).data  == "{" || tokens.get(n).data  == "(")) {
                    stack--;
                    n--;
                    continue;
                }
                
                
                n--;
            }
            return -1;
        }
        /**
         * lastSym - find the last token symbol
         * need to back check syntax..
         * 
         * @arg {Array} tokens the array of tokens.
         * @arg {Number} offset where to start..
         * @return {Token} the token
         */
        public Token? lastSym(TokenArray tokens, int n)
        {
            for (var i = n-1; i >= 0; i--) {
                if (!(tokens.get(i).isType(TokenType.WHIT) || tokens.get(i).isType(TokenType.COMM))) {
                    return tokens.get(i);
                }
            }
            return null;
        }
        
         
        
        /**
            @returns {Boolean} Was the token found?
         */
        public bool read_word (TextStream stream, TokenArray tokens)
        {
            string found = "";
            while (!stream.lookEOF() && Lang.isWordChar(stream.lookC() )) {
                found += stream.nextC().to_string();
            }
             
            if (found == "") {
                return false;
            }
            TokenName name;
            try {
        		name = Lang.keyword(found);
        		tokens.push(new Token(found, TokenType.KEYW, name, this.line));
        		return true;
        	}  catch (LangError e) {	
        		// noop -- then it's a word / not a keyword...
        	}
        	 /*
        		What did all this do...
        		
    		//
                
                // look for "()return" ?? why ???
                var ls = tokens.lastSym();
                if (found == "return" && ls != null && ls.data == ")") {
                    //Seed.print('@' + tokens.length);
                    var n = this.findPuncToken(tokens, ")", 0);
                    //Seed.print(')@' + n);
                    n = this.findPuncToken(tokens, "(", n-1);
                    //Seed.print('(@' + n);
                    
                    //var lt = this.lastSym(tokens, n);
                    /*
                    //print(JSON.stringify(lt));
                    if (lt.type != "KEYW" || ["IF", 'WHILE'].indexOf(lt.name) < -1) {
                        if (!this.ignoreBadGrammer) {
                            throw new TokenReader_Error.ArgumentError(
                                this.filename + ":" + this.line + " Error - return found after )"
                            );
                        }
                    }
                    
                    */
                    /*
                }
                
                
                tokens.push(new Token(found, TokenType.KEYW, name, this.line));
                return true;
            }
            */
            if (!this.sepIdents || found.index_of(".") < 0 ) {
                tokens.push(new Token(found, TokenType.NAME, TokenName.NAME, this.line));
                return true;
            }
            var n = found.split(".");
            var p = false;
            foreach (unowned string nm in n) {
                if (p) {
                    tokens.push(new Token(".", TokenType.PUNC, TokenName.DOT, this.line));
                }
                p=true;
                tokens.push(new Token(nm, TokenType.NAME, TokenName.NAME, this.line));
            }
            return true;
                

        }

        /**
            @returns {Boolean} Was the token found?
         */
        public bool read_punc (TextStream stream, TokenArray tokens) throws TokenReader_Error
        {
            string found = "";
            int pos = 0;
            TokenName tokname = TokenName.UNKNOWN;
            while (!stream.lookEOF()) {
        		var ns = stream.lookC();
				if (pos == 0 ){
					tokname = Lang.puncFirstString(ns);
					if (TokenName.UNKNOWN == tokname) {
						break;
					} 
					pos++;
	                found += stream.nextS();
					continue;
				}
        		var nx = Lang.puncString(found + ns.to_string() );
				if (TokenName.UNKNOWN == nx) {
					break;
				}
				
				tokname = nx;
                found += stream.nextS();
            }
            
            
            if (tokname == TokenName.UNKNOWN) {
                return false;
            }
            
            var ls = tokens.lastSym();
            
            if ((found == "}" || found == "]") && ls != null && ls.data == ",") {
                //print("Error - comma found before " + found);
                //print(JSON.stringify(tokens.lastSym(), null,4));
                if (this.ignoreBadGrammer) {
                    print("\n" + this.filename + ":" + this.line.to_string() + " Error - comma found before " + found);
                } else {
                    throw new TokenReader_Error.ArgumentError(
                                this.filename + ":" + this.line.to_string() + "  comma found before " + found
                  
                    );
                     
                }
            }
            
            tokens.push(new Token(found, TokenType.PUNC, tokname, this.line));
            return true;
            
        } 

        /**
            @returns {Boolean} Was the token found?
         */
        public bool read_space  (TextStream stream, TokenArray tokens)
        {
            // not supported yet.. newlines can be unicode...
            var found = "";
            
            while (!stream.lookEOF() && Lang.isSpace(  stream.lookS()) && !Lang.isNewline(stream.lookS())) {
                found += stream.nextS();
            }
            
            if (found == "") {
                return false;
            }
            //print("WHITE = " + JSON.stringify(found));
            
             
            if (this.collapseWhite) {
                found = " "; // this might work better if it was a '\n' ???
            }
            if (this.keepWhite) {
                tokens.push(new Token(found, TokenType.WHIT, TokenName.SPACE, this.line));
            }
            return true;
        
        }

        /**
            @returns {Boolean} Was the token found?
         */
        public bool read_newline  (TextStream stream, TokenArray tokens)
        {
            // we do not support it yet, but newlines can be UNICODE..
            var found = "";
            var line = this.line;
            while (!stream.lookEOF() && Lang.isNewline(stream.lookS())) {
                this.line++;
                found += stream.nextS();
            }
            
            if (found == "") {
                return false;
            }
            
            // if we found a new line, then we could check if previous character was a ';' - if so we can drop it.
            // otherwise generally keep it.. in which case it should reduce our issue with stripping new lines..
           
            
            //this.line++;
            if (this.collapseWhite) {
                found = "\n"; // reduces multiple line breaks into a single one...
            }
            
            if (this.keepWhite) {
                var last = tokens.pop();
                if (last != null && last.type != TokenType.WHIT) {
                    tokens.push(last);
                }
                // replaces last new line... 
                tokens.push(new Token(found, TokenType.WHIT, TokenName.NEWLINE, line));
            }
            return true;
        }

        /**
            @returns {Boolean} Was the token found?
         */
        public bool read_mlcomment  (TextStream stream, TokenArray tokens)
        {
            if (stream.lookC() != '/') {
                return false;
            }
            if (stream.lookC(1) != '*') {
                return false;
            }
            
            var found = new StringBuilder();
            found.append(stream.nextS(2));
           

            string  c = "";
            var line = this.line;
            while (!stream.lookEOF() && !(stream.lookC(-1) == '/' && stream.lookC(-2) == '*')) {
                c = stream.nextS();
                if (c == "\n") {
                    this.line++;
                }
                found.append(c);
            }
            
            // to start doclet we allow /** or /*** but not /**/ or /****
            //if (found.length /^\/\*\*([^\/]|\*[^*])/.test(found) && this.keepDocs) {
            if (this.keepDocs && found.len > 4 && found.str.index_of("/**") == 0 && found.str[3] != '/') {
                tokens.push(new Token(found.str, TokenType.COMM, TokenName.JSDOC, this.line));
            } else if (this.keepComments) {
                tokens.push(new Token(found.str, TokenType.COMM, TokenName.MULTI_LINE_COMM, line));
            }
            return true;
        
        } 
 
        /**
            @returns {Boolean} Was the token found?
         */
         public bool read_slcomment  (TextStream stream, TokenArray tokens)
         {
            var found = "";
            if (
                (stream.lookC() == '/' && stream.lookC(1) == '/' && (""!=(found=stream.nextS(2))))
                || 
                (stream.lookC() == '<' && stream.lookC(1) == '!' && stream.lookC(2) == '-' && stream.lookC(3) == '-' && (""!=(found=stream.nextS(4))))
            ) {
                var line = this.line;
                while (!stream.lookEOF()) {
					//print(stream.look().to_string());
            		if ( Lang.isNewline(stream.lookS().to_string())) {
            			break;
            		}
                    found += stream.nextS();
                }
                if (!stream.lookEOF()) { // lookinng for end  of line... if we got it, then do not eat the character..
                    found += stream.nextS();
                }
                if (this.keepComments) {
                    tokens.push(new Token(found, TokenType.COMM, TokenName.SINGLE_LINE_COMM, line));
                }
                this.line++;
                return true;
            }
            return false;
        }

        /**
            @returns {Boolean} Was the token found?
         */
        public bool read_dbquote  (TextStream stream, TokenArray tokens)
        {
            if (stream.lookC() != '"') {
                return false;
            }
                // find terminator
            var str = new StringBuilder();
            str.append_unichar(stream.nextC());
            
            while (!stream.lookEOF()) {
                if (stream.lookC() == '\\') {
                    if (Lang.isNewline(stream.lookS(1).to_string())) {
                        do {
                            stream.nextC();
                        } while (!stream.lookEOF() && Lang.isNewline(stream.lookS().to_string()));
                        str.append( "\\\n");
                    }
                    else {
                        str.append(stream.nextS(2));
                    }
                    continue;
                }
                if (stream.lookC() == '"') {
                    str.append_unichar(stream.nextC());
                    tokens.push(new Token(str.str, TokenType.STRN, TokenName.DOUBLE_QUOTE, this.line));
                    return true;
                }
            
                str.append(stream.nextS());
                
            }
            return false;
        }

        /**
            @returns {Boolean} Was the token found?
         */
        public bool read_snquote  (TextStream stream, TokenArray tokens)
        {
            if (stream.lookC() != '\'') {
                return false;
            }
            // find terminator
            var str = new StringBuilder();
     		str.append_unichar(stream.nextC());
            
            while (!stream.lookEOF()) {
                if (stream.lookC() == '\\') { // escape sequence
                    str.append( stream.nextS(2));
                    continue;
                }
                if (stream.lookC() == '\'') {
                    str.append_unichar(stream.nextC());
                    tokens.push(new Token(str.str, TokenType.STRN, TokenName.SINGLE_QUOTE, this.line));
                    return true;
                }
                str.append(stream.nextS());
                
            }
            return false;
        }
        

        /**
            @returns {Boolean} Was the token found?
         */
        public bool read_numb  (TextStream stream, TokenArray tokens)
        {
            if (stream.lookC() == '0' && stream.lookC(1) == 'x') {
                return this.read_hex(stream, tokens);
            }
            
            var found = "";
            
            while (!stream.lookEOF() && !Lang.isNewline(stream.lookS()) && Lang.isNumber(found+stream.lookC().to_string())){
                found += stream.nextS();
            }

            if (found == "") {
                return false;
            }
            if (GLib.Regex.match_simple("^0[0-7]", found)) {
                tokens.push(new Token(found, TokenType.NUMB, TokenName.OCTAL, this.line));
                return true;
            }
            //print("got number '%s'\n", found);
            
            tokens.push(new Token(found, TokenType.NUMB, TokenName.DECIMAL, this.line));
            return true;
        
        }
       
        /**
            @returns {Boolean} Was the token found?
         */
        public bool read_hex  (TextStream stream, TokenArray tokens)
        {
            var found = stream.nextS(2);
            
            while (!stream.lookEOF()) {
                if (Lang.isHexDec(found) && !Lang.isHexDec(found+stream.lookC().to_string())) { // done
                    tokens.push(new Token(found, TokenType.NUMB, TokenName.HEX_DEC, this.line));
                    return true;
                }
                
                found += stream.nextS();
               
            }
            return false;
        }

        /**
            @returns {Boolean} Was the token found?
         */
        public bool read_regx (TextStream stream, TokenArray tokens)
        {
              
            if (stream.lookC() != '/') {
                return false;
            }
            var  last = tokens.lastSym();
            if (
                (last == null)
                || 
                (
                       !last.isType(TokenType.NUMB)   // stuff that can not appear before a regex..
                    && !last.isType(TokenType.NAME)
                    && !last.isName(TokenName.RIGHT_PAREN)
                    && !last.isName(TokenName.RIGHT_BRACE)
                )
            )  {
                var regex = stream.nextS();
                var in_brace = false; // this is really hacky... we ignore [ .../ ]  so aforward slash in a regex.. 
                while (!stream.lookEOF()) {
	                if (stream.lookC() == '[') {
	            		in_brace = true;
            		}
	                if (stream.lookC() == ']') {
	            		in_brace = false;
            		}
            		
                    if (stream.lookC() == '\\') { // escape sequence
                        regex += stream.nextS(2);
                        continue;
                    }
                    if (!in_brace && stream.lookC() == '/') {
                        regex += stream.nextS();
                        
                        while (GLib.Regex.match_simple("[gmi]", stream.lookS().to_string())) {
                            regex += stream.nextS();
                        }
                        
                        tokens.push(new Token(regex, TokenType.REGX, TokenName.REGX, this.line));
                        return true;
                    }
                     
                    regex += stream.nextS();
                     
                }
                // error: unterminated regex
            }
            return false;
        }
    }
}