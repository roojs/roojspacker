//<script type="text/javscript">

/**
	@namespace
*/
// test
// valac gitlive/app.Builder.js/JsRender/Lang.vala --pkg gee-1.0 -o /tmp/Lang ;/tmp/Lang

/*
void main () {
    new JsRender.Lang_Class();
    print(JsRender.Lang.keyword("delete") + "\n");
}
*/
 

namespace JSDOC {

	public errordomain LangError {
            ArgumentError
    }

    public Lang_Class Lang = null;
    
    public class Lang_Class : Object {
        
        GLib.List<string> coreObjects;
        Gee.HashMap<string,string> whitespaceNames;
        Gee.HashMap<string,string> newlineNames;
        
       
        
        public Lang_Class ()
        {
            if (Lang != null) {
                //print("lang not null\n");
                return;
            }
            //print("init\n");
            this.init();
            //print("init Lang");
            Lang = this;
            Lang.ref();
            
        }
        
        
        public bool isBuiltin(string  name) {
            return (this.coreObjects.index(name) > -1);
        }
        
        public string whitespace (string ch) {
            return this.whitespaceNames.get(ch);
        }
        public string  newline (string ch) {
            return this.newlineNames.get(ch);
        }
        public TokenName keyword(string word) throws LangError {
        
    		switch(word) {
			    case "break": return TokenName.BREAK;
				case "case": return TokenName.CASE;
				case "catch": return TokenName.CATCH;
				case "const": return TokenName.VAR;
				case "continue": return TokenName.CONTINUE;
				case "default": return TokenName.DEFAULT;
				case "delete": return TokenName.DELETE;
				case "do": return TokenName.DO;
				case "else": return TokenName.ELSE;
				case "eval": return TokenName.EVAL;
				case "false": return TokenName.FALSE;
				case "finally": return TokenName.FINALLY;
				case "for": return TokenName.FOR;
				case "function": return TokenName.FUNCTION;
				case "if": return TokenName.IF;
				case "in": return TokenName.IN;
				case "instanceof": return TokenName.INSTANCEOF;
				case "new": return TokenName.NEW;
				case "null": return TokenName.NULL;
				case "return": return TokenName.RETURN;
				case "switch": return TokenName.SWITCH;
				case "this": return TokenName.THIS;
				case "throw": return TokenName.THROW;
				case "true": return TokenName.TRUE;
				case "try": return TokenName.TRY;
				case "typeof": return TokenName.TYPEOF;
				case "void": return TokenName.VOID;
				case "while": return TokenName.WHILE;
				case "with": return TokenName.WITH;
				case "var": return TokenName.VAR;
 
			
				default: 
					throw new LangError.ArgumentError("invalid keyword : %s", word);
			}
          
        }
        
        public TokenName? matching(TokenName name) throws LangError
        {
        
            
            switch(name) {
				case TokenName.LEFT_PAREN: return TokenName.RIGHT_PAREN;
				case TokenName.RIGHT_PAREN: return TokenName.LEFT_PAREN;
				case TokenName.LEFT_CURLY: return TokenName.RIGHT_CURLY;
				case TokenName.RIGHT_CURLY: return TokenName.LEFT_CURLY;
				case TokenName.LEFT_BRACE: return TokenName.RIGHT_BRACE;
				case TokenName.RIGHT_BRACE: return TokenName.LEFT_BRACE;
               default:
	               throw new LangError.ArgumentError("invalid matching character : %s", name.to_string());
				 
           };
        
            //return this.matchingNames.get(name);
        }
        
        public bool isKeyword(string word) {
       		try {
       			 this.keyword(word);
				return true;
            } catch (LangError e) {
        		return false;
    		}
        }
        /*
 		public TokenName punc (string ch) throws LangError 
 		{
 			var x = this.puncNull(ch);
 			if (x == null) {
 				throw new LangError.ArgumentError("invalid punctuation character : %s",ch);
			}
			return x;
 		
        }
        public bool isPunc(string ch) {
    		return this.puncNull(ch) != null;
        }
        */
        public TokenName puncFirstString (char ch)
        {
        
    		switch(ch) {
				case ';': return TokenName.SEMICOLON;
				case ',': return TokenName.COMMA;
				case '?': return TokenName.HOOK;
				case ':': return TokenName.COLON;
				case '|': return TokenName.BITWISE_OR;				
				case '^': return TokenName.BITWISE_XOR;
				case '&': return TokenName.BITWISE_AND;
				case '=': return TokenName.ASSIGN;
				case '<': return TokenName.LT;
				case '>': return TokenName.GT;
				case '+': return TokenName.PLUS;
				case '-': return TokenName.MINUS;
				case '*': return TokenName.MUL;
				case '/': return TokenName.DIV;
				case '%': return TokenName.MOD;
				case '!': return TokenName.NOT;
				case '~': return TokenName.BITWISE_NOT;
				case '0': return TokenName.DOT;
				case '[': return TokenName.LEFT_BRACE;
				case ']': return TokenName.RIGHT_BRACE;
				case '{': return TokenName.LEFT_CURLY;
				case '}': return TokenName.RIGHT_CURLY;
				case '(': return TokenName.LEFT_PAREN;
				case ')': return TokenName.RIGHT_PAREN;
			}
			return TokenName.UNKNOWN;
		}
        public TokenName puncString (string ch)
        {
        
    		switch(ch) {
								
				case "||": return TokenName.OR;
				case "&&": return TokenName.AND;
				case "==": return TokenName.EQ;
				case "!=": return TokenName.NE;
				case "<<": return TokenName.LSH;
				case "<=": return TokenName.LE;
				case ">>": return TokenName.RSH;
				case ">=": return TokenName.GE;
				case "++": return TokenName.INCREMENT;
				case "--": return TokenName.DECREMENT;
				
				
				case "===": return TokenName.STRICT_EQ;
				case "!==": return TokenName.STRICT_NE;
				case ">>>": return TokenName.URSH;
				
				
			default:
				return TokenName.UNKNOWN;
				 
				
			}        
         
        }
         
        
        
        public bool isNumber (string str) {
            return Regex.match_simple("^(\\.[0-9]|[0-9]+\\.|[0-9])[0-9]*([eE][+-]?[0-9]+)?$",str);
        }
    
        public bool  isHexDec (string str) {
            return Regex.match_simple("^0x[0-9A-Fa-f]+$",str);
        }
    
        public bool isWordString (string str) {
            return Regex.match_simple("^[a-zA-Z0-9$_.]+$", str);
        }
        public bool isWordChar (char  c) {
    		return 
    			(c >= 'a' && c <= 'z')
    			||
    			(c >= 'A' && c <= 'Z')
    			||
    			(c >= '0' && c <= '9')
    			||
    			c == '$' || c == '.' || c == '_' ;
        }
    
        public bool isSpace (string str) {
            return this.whitespaceNames.get(str) != null;
        }
 	    public bool isSpaceC (char str) {
 			var s = str.to_string();
            return this.whitespaceNames.get(s) != null;
        }
        
        public bool isNewline (string str) {
            return this.newlineNames.get(str) != null;
		}	   
        public bool isNewlineC (char str) {
    		var s =str.to_string();
            return this.newlineNames.get(s) != null;
        }
 	    public bool isBoolean (string str) {
			var ss = str.down();
            return ss == "false" || ss == "true";
        }
        
         
        
        void init() {
            
            this.coreObjects = new GLib.List<string>();
            
            this.whitespaceNames = new Gee.HashMap<string,string>();
            this.newlineNames = new Gee.HashMap<string,string>();
            
            
 
            
            
            
            string[] co = { "_global_", "Array", "Boolean", "Date", "Error", 
                "Function", "Math", "Number", "Object", "RegExp", "String" };
            for(var i =0; i< co.length;i++ ) {
                this.coreObjects.append(co[i]);
                //this.match_strings.add(co[i]);
            }
            string[] ws =  {
                " :SPACE",
                "\f:FORMFEED",
                "\t:TAB" //,
              //  "\u0009:UNICODE_TAB",
              //  "\u000A:UNICODE_NBR",
              //  "\u0008:VERTICAL_TAB"
            };
            for(var i =0; i< ws.length;i++ ) {
                var x = ws[i].split(":");
                this.whitespaceNames.set(x[0],x[1]);
            }
            
            ws = {
                "\n:NEWLINE",
                "\r:RETURN" //,
    //            "\u000A:UNICODE_LF",
      //          "\u000D:UNICODE_CR",
        //        "\u2029:UNICODE_PS",
          //      "\u2028:UNICODE_LS"
            };
            for(var i =0; i< ws.length;i++ ) {
                var x = ws[i].split(":");
                this.newlineNames.set(x[0],x[1]);
            }
            

                // << was keywords here...
                //this.match_strings.add(x[0].substring(1));
            
        
      
  
        
           
           
           
           
        }
        
        
    }
}