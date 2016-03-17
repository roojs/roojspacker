
/**
 * @class TokenStream
 * 
 * BC notes:
 * 
 * nextT => nextTok
 * lookT => lookTok
 * 
 */


namespace JSDOC {

	public errordomain TokenStreamError {
            ArgumentError
    }
	public class TokenStream : Object
	{
	
		protected Gee.ArrayList<Token> tokens;
		public int cursor; // where are we in the stream.		
	
	
		public TokenStream(Gee.ArrayList<Token> tokens) {
		 
			this.tokens = tokens;

			this.rewind();
		}
		public  Gee.ArrayList<Token> toArray()
		{
			return this.tokens;
		}

		
		public void rewind() {
		    this.cursor = -1;
		}

		/**
		    @type JSDOC.Token
		*/
		public Token? look (int n, bool considerWhitespace)  // depricated... causes all sorts of problems...
		{


		    if (considerWhitespace == true) {
		    
		        if (this.cursor+n < 0 || this.cursor+n > (this.tokens.size -1)) {
		            return new Token("", TokenType.VOID, TokenName.START_OF_STREAM);
		        }
		        return this.tokens.get(this.cursor+n);
		    }
		    

	        var count = 0;
	        var i = this.cursor;

	        while (true) {
	            if (i < 0) {
	        		return new Token("", TokenType.VOID, TokenName.START_OF_STREAM);
	    		}
	            if (i >= this.tokens.size) {
	        		return new Token("", TokenType.VOID, TokenName.END_OF_STREAM);
	    		}

	            if (i != this.cursor && this.tokens.get(i).isType(TokenType.WHIT)) {
	        		i += (n < 0) ? -1 : 1;
	                continue;
	            }
	            
	            if (count == n) {
	                return this.tokens.get(i);
	            }
	            count++;
	            i += (n < 0) ? -1 : 1;
	        }

	       // return new Token("", "VOID", "STREAM_ERROR"); // because null isn't an object and caller always expects an object
		    
		}
		// look through token stream, including white space...
		public Token  lookAny (int n)
		{


	         if (this.cursor+n < 0 || this.cursor+n > (this.tokens.size -1)) {
	            return new Token("", TokenType.VOID, TokenName.START_OF_STREAM);
	        }
	        return this.tokens.get(this.cursor+n);
	    
	    
  
		}
		
		

		public int lookFor  (string data)
		{
		    // non tree version..
		    var i = this.cursor < 0 ? 0 : this.cursor ;
		    
		    while (true) {
		        if (i >= this.tokens.size) {
		    		return -1;
	    		}
		        if (this.tokens.get(i).data == data) {
		            return i;
		        }
		        i++;
		        
		    }
		    // should not get here!
		   // return -1;

		}


		/**
		 * look ahead (or back) x number of tokens (which are not comment or whitespace)
		 * ?? used by scope parser & compress white to look back?
		 */
		 public Token lookTok (int n) {


		    var step =  (n < 0) ? -1 : 1;
		    var count = 0;
		    
		    var i = this.cursor;

		    while (true) {
		        // print("lookTok:i=%d n= %d count=%d\n" , i, n, count);
		        
		        if (i < 0 &&  n > -1) {
		                i = 0; 
		                count += step;
		                continue;
	            }

		        
	            // beyond beginnnig..
	            if (i < 0 &&  n < 0) {
		            return  new Token("BEG", TokenType.VOID, TokenName.END_OF_STREAM);
		        }
	            
		        
		        // beyond end..
		        if (i >= this.tokens.size) {
		    		return  new Token("END", TokenType.VOID, TokenName.END_OF_STREAM);
	    		}
				// print("lookTok:i= %d n= %d : %s\n" , i, n, this.tokens.get(i).asString());
				var tok = this.tokens.get(i);
				
		        if (i != this.cursor && ( 
		    				tok.isType(TokenType.WHIT) || tok.isType(TokenType.COMM)
    				)) {
		            i += step;
		            continue;
		        }
		        
		        if (count == n) {
		            return this.tokens.get(i);
		        }
		        count+=step;
		        i += step;
		    }
		// should never get here..
		//    return  new Token("", "VOID", "END_OF_STREAM");; // because null isn't an object and caller always expects an object;
		    
		}
		
		/**
		 *  @return {Token|null}
		 * next token (with white space)
		 */
		    
		   
		public Token? next() {
		
		
		    //if (typeof howMany == "undefined") howMany = 1;
		    // if (howMany < 1) { return  null;     		}
		    
		    if (this.cursor+1 >= this.tokens.size) {
		        return null;
	        }
		    this.cursor++;
		    return this.tokens.get(this.cursor);

		}
		
 	    public Gee.ArrayList<Token>? nextM(int howMany) throws TokenStreamError {
		
		    //if (typeof howMany == "undefined") howMany = 1;
		    if (howMany < 2) { 
				throw new  TokenStreamError.ArgumentError("nextM called with wrong number : %d", howMany);
		    }
		    var got = new Gee.ArrayList<Token>();

		    for (var i = 1; i <= howMany; i++) {
		        if (this.cursor+i >= this.tokens.size) {
		            return null;
		        }
		        got.add(this.tokens.get(this.cursor+i));
		    }
		    this.cursor += howMany;
		    
			return got;
		}
		
		
		
		
		// what about comments after 'function'...
		// is this used ???
		public Token? nextTok() {
		    return this.nextNonSpace();
		}
		
		public Token? nextNonSpace ()
		{
		    
		    while (true) {
		        var tok = this.next();
		        if (tok == null) {
		            return null;
		        }
		        if (tok.isType(TokenType.WHIT) ||  tok.isType(TokenType.COMM)) {
		            continue;
		        }
		        return tok;
		    }
		}
		
		/**
		 *  balance 
		 * -- returns all the tokens betweeen and including stop token eg.. from {... to  }
		 * @param start {String}  token name or data (eg. '{'
		 * @param stop {String} (Optional) token name or data (eg. '}'
		 */
		 
		 
		//public Gee.ArrayList<Token> balanceStr (string start) throws TokenStreamError 	
		//{
		//	return this.balance( Lang.punc(start));
		//}	 

		 
		public Gee.ArrayList<Token> balance (TokenName in_start) throws TokenStreamError 
		{
		    
		    // fixme -- validate start...
		    
		    // accepts names or "{" etc..
		    
		    var start = in_start;
		    var stop =  Lang.matching(start); /// validates start..
		    if (stop == null) {
				throw new TokenStreamError.ArgumentError("balance called with invalid start/stop : %s",start.to_string());
			}
		    
		    print("START=%s, STOP=%s \n", start.to_string(),stop.to_string());
		    var depth = 0;
		    var got = new Gee.ArrayList<Token>();
		    var started = false;
		    //Seed.print("START:" + start);
		    //Seed.print("STOP:" + stop);
		    Token token;
		    
		    while (null != (token = this.lookAny(1))) {
				print("BALANCE: %d %s " , this.cursor,  token.asString());
		        if (token.isName(start)) {
		      //      Seed.print("balance: START : " + depth + " " + token.data);
		            depth++;
		            started = true;
		        }
		        
		        if (started) {
		            got.add(token);
		        }
		        
		        if (token.isName(stop)) {
		            depth--;
		            
	    			//debug("balance (%d): STOP: %s" ,  depth ,  token.data);
		            if (depth < 1) {
			            this.next(); // shift cursor to eat closer...
		        		debug("returning got %d", got.size);
		        		return got;
	        		}
	        		
		        }
		        if (null == this.next()) {
		    		break;
	    		}
		    }
		    return new Gee.ArrayList<Token>();
		}
		// designed to get either end or start..
		
		
		public Token? getMatchingTokenEnd(TokenName end) 		
		{
			return this.getMatchingToken(Lang.matching(end), 1);
		}
		
		public Token? getMatchingToken(TokenName start, int depth = 0) 
		{
 
		    var cursor = this.cursor;
		    
		    
				var stop= Lang.matching(start);
			Token token;
		    
		    while (null != (token = this.tokens[cursor])) {
		        if (token.isName(start)) {
		            depth++;
		        }
		        
		        if (token.isName(stop) && cursor != 0) {
		            depth--;
		            if (depth == 0) {
		        		return this.tokens[cursor];
	        		}
		        }
		        cursor++;
		    }
		    return null;
		}
		/*
		public Gee.ArrayList<Token> insertAhead(Token token) 
		{
		    this.tokens.splice(this.cursor+1, 0, token); // fixme...
		}
		*/
		 
		public Gee.ArrayList<Token> remaining() {
		    var ret = new Gee.ArrayList<Token>();
		    while (true) {
		        var tok = this.look(1,true);
		        if (tok.isType(TokenType.VOID)) {
		            return ret;
		        }
		        var nt = this.next();
		        if (nt != null) {
			        ret.add(nt);
		        }
		    }
		}
		 
		 
		public void printRange(int start,  int end) {
			
			for(var i = start; i < end +1; i++) {
	            print(this.tokens.get(i).asString());
			} 
		}
		 
		/*
		arrayToString : function(ar) {
		    console.log(typeof(ar));
		    var ret = [];
		    ar.forEach(function(e) {
		        ret.push(e.data);
		    })
		    return ret.join('');
		},
		*/
		public void dump(int start, int end)
		{
		    start = int.max(start , 0);
		    end = int.min(end, this.tokens.size);
		    var  outs = "";;
		    for (var i =start;i < end; i++) {
		        
		        outs += (this.tokens[i].outData == "") ? this.tokens[i].data : this.tokens[i].outData;
		    }
		    print(outs);
		}
		
		public void dumpAll(string indent)
		{
		    for (var i = 0;i < this.tokens.size; i++) {
		        
		         this.tokens[i].dump("");
		    }
		    
		}
		public void dumpAllFlat()
		{
		    for (var i = 0;i < this.tokens.size; i++) {
		        
		         print("%d: %s\n", i, this.tokens[i].asString());
		    }
		    
		}
		
	}
}

