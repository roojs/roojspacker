/**
 *	@class Token
 * 
 *  @prop data {String} raw value of token
 *  @prop type {String} type of token
 *     TOKN  (unknown)          - name is UNKNOWN_TOKEN
 * 
 *     KEYW  (keyword)          - name is upper case version of keyword
 *     NAME  (name/identifier)  - name is NAME
 *     COMM  (comment)          - name is MULTI_LINE_COMM, JSDOC, SINGLE_LINE_COMM
 *     PUNC  (puctuation)       - name is String description of punctionan (eg LEFTPARAM)
 *     WHIT  (white space)      - name is SPACE,NEWLINE
 *     STRN  (string)           - name is DOBULE_QUOTE, SINGLE_QUOTE
 *     NUMB  (number)           - name is OCTAL,DECIMAL,HEC_DEC
 *     REGX   (reg.expression)  - name is REGX
 *  @prop name {String} see type details above
 *  @prop identifier {Identifier} identifier class if relivant
 * 
 * 
 * 
 * old mappings:
 * 
 * Script.TOKidentifier  - type == 'NAME'
 * Script.TOKassign  = data == '='
 * Script.TOKsemicolon data == '';
 * 
 * 
 * 
*/
namespace JSDOC
{
    int Token_id = 1;
	public enum TokenType {
		TOKN, //  (unknown)          - name is UNKNOWN_TOKEN
		KEYW, //  (keyword)          - name is upper case version of keyword
		NAME, //  (name/identifier)  - name is NAME
		COMM, //  (comment)          - name is MULTI_LINE_COMM, JSDOC, SINGLE_LINE_COMM
		PUNC, //  (puctuation)       - name is String description of punctionan (eg LEFTPARAM)
		WHIT, //  (white space)      - name is SPACE,NEWLINE
		STRN, //  (string)           - name is DOBULE_QUOTE, SINGLE_QUOTE
		NUMB, //  (number)           - name is OCTAL,DECIMAL,HEC_DEC
		REGX, //   (reg.expression)  - name is REGX
		
		VOID // BAD eof 
	}
	
	
	public enum TokenName {
		UNKNOWN_TOKEN,
		
		// keywords.
			BREAK,
			CASE,
			CATCH,
			CONST,
			CONTINUE,
			DEFAULT,
			DELETE,
			DO,
			ELSE,
			FALSE,
			FINALLY,
			FOR,
			FUNCTION,
			IF,
			IN,
			INSTANCEOF,
			NEW,
			NULL,
			RETURN,
			SWITCH,
			THIS,
			THROW,
			TRUE,
			TRY,
			TYPEOF,
			VOID,
			WHILE,
			WITH,
			VAR,
			EVAL,
		
		NAME,
		
	
		MULTI_LINE_COMM, JSDOC, SINGLE_LINE_COMM,
		// punc
			SEMICOLON,
			COMMA,
			HOOK,
			COLON,
			OR,
			AND,
			BITWISE_OR,
			BITWISE_XOR,
			BITWISE_AND,
			STRICT_EQ,
			EQ,
			ASSIGN,
			STRICT_NE,
			NE,
			LSH,
			LE,
			LT,
			URSH,
			RSH,
			GE,
			GT,
			INCREMENT,
			DECREMENT,
			PLUS,
			MINUS,
			MUL,
			DIV,
			MOD,
			NOT,
			BITWISE_NOT,
			DOT,
			LEFT_BRACE,
			RIGHT_BRACE,
			LEFT_CURLY,
			RIGHT_CURLY,
			LEFT_PAREN,
			RIGHT_PAREN,

		
		
		SPACE,NEWLINE,
		DOUBLE_QUOTE, SINGLE_QUOTE,
		OCTAL,DECIMAL,HEX_DEC,
		REGX,
		
		START_OF_STREAM,
		END_OF_STREAM,
		
		UNKNOWN // we should change void/void to void/unknown.
	}

	public class TokenKeyMap : Object {
		public Token key;
		public Gee.ArrayList<Token> vals;
		
		public TokenKeyMap()
		{
			this.key = new Token("",TokenType.VOID, TokenName.VOID); 
			this.vals = new  Gee.ArrayList<Token>();
		}
		
		
	}


    public class Token : Object {
        
        public int id;
        
        public string data;
        public TokenType type;
        public TokenName name;
        public int line;
        public string prefix; // white space prefix... (when outputing with WS)
        
        public string outData;
        
        public Identifier identifier;
        
        

         // used to stuff tokens together when building a tree..
        public Gee.ArrayList<Gee.ArrayList<Token>> items;
        // for a object definition, key -> array of tokens..
	    public Gee.HashMap<string,TokenKeyMap> props;
        public Gee.ArrayList<string> keyseq;        
        // props??? what's this???
        
        public Token(string data, TokenType type, TokenName name, int line = -1)
        {
            this.data = data;
            this.type = type;
            this.name = name;
            this.line = line;
            this.prefix = "";    
            this.outData = ""; // used by packer/scopeparser
            this.identifier = null; // used by scope
            this.id = Token_id++;
            
            // should we initialize when needed...?? to keep the usage down..
            this.items = null;
            this.props = null;
            if (name == TokenName.LEFT_BRACE || 
		        name == TokenName.LEFT_CURLY || 
	            name == TokenName.LEFT_PAREN ) {
            
		        this.items = new Gee.ArrayList<Gee.ArrayList<Token>>();
		        this.props = new Gee.HashMap<string,TokenKeyMap>();
		        this.keyseq =  new Gee.ArrayList<string>();
	        }
	        
        }
    
        public string asString()
        {
            return "line:%d, id %d, type %s, IS=%d,PS=%d,KS=%d, data : %s,  name %s, , outData: %s".printf(
                    this.line,
                    this.id,
                    this.type.to_string(),
                    this.items == null : 0 : this.items.size,
                    this.props == null : 0 : this.props.size,
                    this.keyseq == null : 0 : this.keyseq.size,
                    this.data,
                    this.name.to_string(),
                    this.outData == null ? "" : this.outData
            );
            
        }
        
        
        public void dump(string indent)
		{
	        print("%s%s\n",indent, this.asString());
	        if (this.items.size > 0) {
		        
				for (var i = 0;i < this.items.size; i++) {
			        print("%s --ITEMS[%d] [ \n",indent,i);
					for (var j = 0;j < this.items[i].size; j++) {
						this.items[i][j].dump(indent + "  ");
					}
				}
			}
			if (this.props.size > 0) {
				var m = this.props.map_iterator();
				while(m.next()) {
			        print("%s --KEY %s ::  \n",indent,m.get_key());
			        var vals = m.get_value().vals;
		   			for (var i = 0;i < vals.size; i++) {

						vals[i].dump(indent + "  ");
					}
				}
			
			
			}
			
		}
        
        
        public string toRaw(int lvl = 0)
        {
            
            
            var ret =  this.data ;
            
            foreach(var ai in this.items ) {
                // supposed to iterate properties???
                string str = "";
                //foreach( var it in ai) {
                 //   str += it.toRaw(lvl+1);
               // }
                ret += str;
            }
            
            /* -- what is a prop..
            if (this.props) {
                for (var i in this.props) {
                    ret += this.props[i].key.toRaw(lvl+1) + ' : ';
                    this.props[i].val.forEach( function(e) {
                        ret+=e.toRaw(lvl+1);
                    })
                    
                }
            }
            
            */
            
            return this.prefix +   ret;
             
        }
        /*
        toJS : function() {
            
            try {
                var _tmp = '';
                eval( "_tmp = " + this.data);
                return _tmp;
            } catch( e) {
                return "ERROR unparsable" + this.data;
            }
        },
        */
                        

        public bool isName(TokenName what) {
            return this.name == what;
        }
        public bool isType(TokenType what) {
            return  this.type == what;
        }
        
    }
}
  