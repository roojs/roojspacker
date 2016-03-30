
/**
 * 
 * base class for parsing segments of token array..
 * 
 * 
 * We want to make parsing the whole thing easy..
 * 
 * so we do various tricks:
 * 
 * 
 * a) white space collased
 *    wsPrefix 
 * b)  toks
 *     { } - collapse into first element.
       ( ) - collapse into first element.
       [ ] - collapse into first element.
 * c) items = , seperation within the above..
 * 
 * usage: x = new Collapse(token_array)
 * 
 * 
 * 
 * 
 */ 

namespace JSDOC {

	public class  Collapse : TokenStream  {




		public Collapse(Gee.ArrayList<Token> tokens) 
		{
		    base(tokens);
		    
		    this.spaces();
		    
		    var ar = this.collapse(this.tokens);
		    
		    this.tokens = ar;
		    
		   // console.dump(ar);
		    
		}
		
		// put spaces into prefix of tokens..
    
        void spaces () 
        {
            var ar = new Gee.ArrayList<Token>();
            var pref =  new Gee.ArrayList<Token>();
            
			
            
            for (var i = 0; i < this.tokens.size; i ++) {
                var tok = this.tokens[i];
                if (tok.isType(TokenType.COMM) || tok.isType(TokenType.WHIT)) {
                    pref.add(tok);
                    continue;
                }
                tok.prefix = "";
                if (pref.size > 0) {
            		foreach(var e in pref) {
                        tok.prefix += e.data;
                    }
                    pref =  new Gee.ArrayList<Token>(); // reset pref..
                }
                
                ar.add(tok);
                

                
            }
            this.tokens = ar;
            
        }
        
        
        
        Gee.ArrayList<Token>  collapse(Gee.ArrayList<Token>  ar) 
        {
            
            var st = new TokenStream(ar);
            var ret = new Gee.ArrayList<Token>();
            var last_is_object_def = false;
            
            while (true) {
                var  tok = st.look(1,true);
                if (tok == null) {
                  //  Seed.print(TokenStream.toString(ret));
                    return ret;
                }
                // console.log(tok.data);
                
                //print("COL: %s\n", tok.asString());
                
                switch(tok.type) {
                    case TokenType.VOID: 
                        return ret; //EOF
                        
                        
                    case TokenType.KEYW: 
                    case TokenType.TOKN:
                    case TokenType.NAME:
                    case TokenType.STRN:
                    case TokenType.NUMB:
                    case TokenType.REGX:
                		var nn = st.next();
                		if (nn != null) { 
	                        ret.add(nn);
                        }
                        last_is_object_def = false;
                        continue;
                        
                    case TokenType.PUNC:
                        switch (tok.data) {
                            case "[":
                            case "{":
                            case "(":
                                last_is_object_def = false;
                                var start = st.cursor;
                                //st.next(); << no need to shift, balance will start at first character..
                                
                                var add = st.balance(tok.name);
                                
                               // print("BALANCE returned %d items\n", add.size);
                                
                                
                               // if (!add) {
                                    //console.dump(tok);
                                    //console.dump(start + '...' + st.cursor);
                                    //console.dump(st.tokens);
                                 
                                //}
                                if (add.size > 0) {
                               		add.remove_at(0);  // remove the first element... (as it's the 
                                }
                                //Seed.print("ADD");
                                //Seed.print(JSON.stringify(add, null,4));
                                
                                
                                
                                var toks = add.size > 0 ? this.collapse(add) : add;
                                
                                tok.items = new Gee.ArrayList<Gee.ArrayList<Token>>(); //?? needed?
                                tok.props = new Gee.HashMap<string,TokenKeyMap>();
                                 
                                
                                if (tok.data != "{") {
                                    // paramters or array elements..
                                    tok.items = this.toItems(toks, ",");
                                } else {
                                    // check for types.. it could be a list of statements.. or object
                                    // format "{" "xXXX" ":" << looks for the ':'.. seems to work.. not sure if it's foolproof...
                                    
                                    var ost = new  TokenStream(toks);
                                    //console.dump(ost.look(2,true) );
                                    if (ost.look(2,true) != null && ost.look(2,true).data == ":") {
                                		// object properties...
										this.toProps(toks,tok);
										last_is_object_def = true;
                                    } else {
                                        // list of statemetns..
                                        tok.items = this.toItems(toks, ";{");;
                                    }
                                    
                                    
                                }
                                 
                                
                                
                                
                                
                                
                                
                                //Seed.print(" ADD : " + add.length  +  " ITEMS: " + tok.items.length);
                                
                                ret.add(tok);
                                
                                continue;
                   
                            default:
	                            last_is_object_def = false;
                                ret.add(st.next());
                                continue;
                        }
                       print("OOPS");
                        continue;
                    default : 
                       print("OOPS" + tok.type.to_string());
                        continue;
                }
            }
                
                
            
            
            
            
            
            
            
            
        }
        // array of arrays of tokens
        Gee.ArrayList<Gee.ArrayList<Token>>  toItems(Gee.ArrayList<Token>  ar, string sep)
        {
            var ret = new Gee.ArrayList<Gee.ArrayList<Token>>() ;
            var g =  new Gee.ArrayList<Token>() ;
              
            for (var i = 0; i < ar.size; i ++) {
                if (sep.index_of(ar.get(i).data) < 0) {
                    g.add(ar.get(i));
                    continue;
                }
                // var a=..., b =...
                if ((ar.get(i).data != ";") && g.size> 0  && (g[0].name == TokenName.VAR)) {;
                    g.add(ar.get(i));
                    continue;
                }
                
                g.add(ar.get(i));
                ret.add(g);
                g =  new Gee.ArrayList<Token>() ;
                
            }
            // last..
            if (g.size > 0) {
                ret.add(g);
            }
            return ret;
            
        }
        
        Gee.HashMap<string,TokenKeyMap> toProps (Gee.ArrayList<Token> ar, Token tok)
        {
            
            var ret = new Gee.HashMap<string,TokenKeyMap>();
			
			var keyseq = new Gee.ArrayList<string>();
               
            var g = new TokenKeyMap();
               
            
            var k = "";
            var state = 0;
            for (var i = 0; i < ar.size; i ++) {
                
                switch(state) {
                    case 0:
                        k = ar.get(i).data;
                        g.key = ar.get(i);
                        keyseq.add(k);
                        state = 1;
                        continue;
                    case 1:
                        state =2; // should be ':'
                        continue;
                    case 2:
                        g.vals.add( ar.get(i));
                        if ( ar.get(i).data != ",") {
                            continue;
                        }
                        ret.set(k, g);
                        g = new TokenKeyMap();
                        state = 0;
                        continue;
                   
                }
            }
             // last.. - if g.val.length is 0 then it's a trailing ','...
             // we should really throw a syntax error in that case..
            if (k.length > 0 && g.vals.size > 0) {
                ret.set(k, g);
            }
            tok.props = ret;
            tok.keyseq = keyseq;
            return ret;
            
            
        }

	}   
    
}
