 

namespace JSDOC 
{
	public int Scope_gid = 0;
	
	public class Scope : Object 
	{
	
	    int id ;
		int braceN ;
		public Scope parent;
		public Gee.ArrayList<Scope> subScopes;
		
		
		Gee.HashMap<string,Identifier> identifier_map;   // map of identifiers to {Identifier} objects
		Gee.ArrayList<Identifier> identifier_list;
		
		Gee.HashMap<string,string> hints;
		bool mungeM = true;
		//ident: '',
		
		bool munged  = false;
	    Gee.HashMap<string,bool> protectedVars ; // only used by to parent..
		Token? token;

		public Scope(int braceN, Scope? parent, int startTokN, Token? token) // Identifier? lastIdent
		{
			//if (lastIdent.length) {
			   //  println("NEW SCOPE: " + lastIdent);
			//}
		
			this.braceN = braceN;
			this.parent = parent;
			this.id = startTokN;
			this.identifier_map = new Gee.HashMap<string,Identifier>();
			this.identifier_list = new Gee.ArrayList<Identifier>();
			this.subScopes = new Gee.ArrayList<Scope> ();
			this.hints = new Gee.HashMap<string,string>();
			this.protectedVars = new Gee.HashMap<string,bool>();
			//this.ident = lastIdent;
			this.id = Scope_gid++;
			this.token = token;
			//print("ADD SCOPE(" + this.gid + ") TO "+ (parent ? this.parent.gid : 'TOP') + ' : ' + 
			//    (token ? token.toString() : ''));
		
			if (parent != null) {
				this.parent.subScopes.add(this);
			} 
			Scope.init();
		
		}







	 
		/**
		 * dump the scope to StdOut...
		 * 
		 */
		public void dump (string indent = "") 
		{
		    //indent = indent || '';
		    
		    var str = "";
			 var idents = this.identifier_list;
		    var iter = idents.list_iterator();
		    while (iter.next()) {
			    var identifier = iter.get();
				str += indent + " $" + identifer.name + " => " +  identifer.mungedValue;
			}
			
		    print(
		        indent +  "Scope: %d\n" +
		        indent + "Started: %d\n" +
		        indent + "- idents..: fixme\n"
				, 
				this.id,
				this.token != null ? this.token.line  : -1
				//		     " + XObject.keys(this.identifiers).join(", ") + "
		    );
		    foreach(var s in this.subScopes) {
			   s.dump(indent + " ");
		    };
		    
		    
		}
    
    
		public Identifier declareIdentifier(string symbol, Token token) 
		{
		    
		    //print("SCOPE : " + this.gid +  " :SYM: " + symbol + " " + token.toString()+"");
		    
		    if (!this.identifier_map.has_key(symbol)) {
				var nid = new Identifier(symbol, this);
		        this.identifier_list.add(nid);
		        this.identifier_map.set(symbol,   nid);
		        
		    }
		    
		    //if (typeof(token) != 'undefined') { // shoudl this happen?
		        token.identifier = this.identifier_map.get(symbol);
		        
		    //}
		    if (this.braceN < 0) {
		            // then it's global... 
	            this.identifier_map.get(symbol).toMunge  = false;
		    }
		     
		    
		    this.addToParentScope(symbol);
		    return this.identifier_map.get(symbol);
		}
		
		
		
		public Identifier? getIdentifier(string symbol, Token token) 
		{
		    if (!this.identifier_map.has_key(symbol)) {
				return null;
		        //if (['String', 'Date'].indexOf(symbol)> -1) {
		         //   return false;
		        //}
		        
		        //print("SCOPE : " + this.gid +" = SYMBOL NOT FOUND?" + token.toString());
		        //return n;
		    }
		     //print("SCOPE : " + this.gid +" = FOUND:" + token.toString());
		    return this.identifier_map.get(symbol);
		}
		
		public void addHint(string varName, string varType) {
		
		    this.hints.set(varName, varType);
		}
		public void preventMunging () {
		    this.mungeM = false;
		}

		//usedsymcache : false,
		
		public string[] getUsedSymbols () {
		    
		    string[] result = {};
		    
		    // if (this.usedsymcache !== false) {
		    //    return this.usedsymcache;
		    //}
		    
		    var idents = this.identifier_list;
		    var iter = idents.list_iterator();
		    while (iter.next()) {
			    var identifier = iter.get();
		        //println('<b>'+i+'</b>='+typeof(idents[i]) +'<br/>');
		        //var identifier = this.identifier_map.get(i);
		        var mungedValue = identifier.mungedValue;
		        
		        if (mungedValue.length < 1) {
		            //println(identifier.toSource());
		            mungedValue = identifier.name;
		        }
		        result += mungedValue;
		    }
		    //println("Symbols for ("+ this.id +"): <B>" + result.join(',') + "</B><BR/>");
		    //this.usedsymcache = result;
		    return result;
		}

		string[] getAllUsedSymbols() 
		{
		    var result = this.getUsedSymbols();
		    var scope = this.parent;
		    while (scope != null) {
				var ps = scope.getUsedSymbols();
				for (var i =0;  i< ps.length; i++) {
					result += ps[i];
				}
		        scope = scope.parent;
		    }
		     //println("Done - addused");
		    return result;
		}
		/** - we need to register short vairalbes so they never get munged into.. */
		public void addToParentScope(string ident) 
		{
		    if (ident.length > 2) {
		        return;
		    }
		    var scope = this.parent;
		    while (scope != null) {
		        //println("addused:"+scope.id);
		        if (scope.parent != null) {
		            scope.protectedVars.set(ident, true);
		        }
		        scope = scope.parent;
		    }
		    
		}
		public bool isProtectedVar(string ident)
		{
		    if (ident.length > 2) {
		        return false;
		    }
		    var scope = this.parent;
		    while (scope != null) {
		        //println("addused:"+scope.id);
		        if (scope.parent != null) {
		    		if (scope.protectedVars.has_key(ident)) {
		    			return true;
					}
		        }
		        scope = scope.parent;
		    }
		    return false;
		}
		
		
		
		
		/**
		 * set's all the munged values on the identifiers.
		 * 
		 * 
		 */

		public void munge() 
		{

		    if (!this.mungeM) {
		        // Stop right here if this scope was flagged as unsafe for munging.
		       // println("MUNGE: SKIP -  Scope" + this.id+"</BR>");
		        return;
		    }
		    if (this.munged) {
		        return;
		    }
		    

		    
		    
		    var pickFromSet = 1;

		    // Do not munge symbols in the global scope!
		    if (this.parent == null) {
				// same code at bottom... ?? goto::
				this.munged = true;
				//println("Doing sub scopes");
				for (var j = 0; j < this.subScopes.size; j++) {
					this.subScopes.get(j).munge();
					
				}
		    
				return;
			}
		        
		    string[] all = {};
		    var iter = this.identifier_list.list_iterator();
		    while (iter.next()) {
		        all += iter.get().name;
		    }
		    //print("MUNGE: " + all.join(', '));
		        
		        //println("MUNGE: Building FreeSyms:" + this.id+"</BR>");
		        
		    Gee.ArrayList<string> freeSymbols= new Gee.ArrayList<string>();
		    
		    var sy = this.getAllUsedSymbols();
		        
			Scope.array_merge(freeSymbols,Scope.ones); 
		         
		    var repsym = "";
		        //println(freeSymbols.toSource());
		       
		        //println("MUNGE: Replacing " + this.id+"</BR>");
		    iter = this.identifier_list.list_iterator();
		    while (iter.next()) {
				var i = iter.get().name;
		        
		        // is the identifer in the global scope!?!!?
		        
		        
		        if (!this.identifier_map.get(i).toMunge) {
		            //print("SKIP toMunge==false : " + i)
		            continue;
		        }
		        
		        if (this.isProtectedVar(i)) {
		            //print("SKIP PROTECTED: " + i)
		            continue; // 
		        }
		        
		        
		        
		        //if (this.identifiers[i].constructor !=  Identifier) {
		        //    print("SKIP NOT IDENTIFIER : " + i)
		        //    continue;
		       // }
		       // println("IDENT:" +i+'</BR>');
		        
		        if (repsym.length < 1) {
		            if (freeSymbols.size < 1) {
		                Scope.array_merge(freeSymbols,Scope.twos); 
		            }
		            repsym = freeSymbols.remove_at(0); // pop off beginngin???
		        }
		        
		        var identifier = this.identifier_map.get(i); 
		        //println(typeof(identifier.name));
		        var mungedValue = identifier.name; 
		        
		        if (mungedValue.length < 3) {  // don't bother replacing 1&2 character variables..
			        continue;
		        }
		        
		        //println([     repsym,mungedValue ]);
		        
		        if (this.mungeM && repsym.length < mungedValue.length) {
		            //print("REPLACE:"+ mungedValue +" with " + repsym );    
		            mungedValue = repsym;
		            repsym = "";
		        }
		        
		        identifier.mungedValue =  mungedValue;
		    }
		    //println("MUNGE: Done " + this.id+"</BR>");
			 
			this.munged = true;
			//println("Doing sub scopes");
			for (var j = 0; j < this.subScopes.size; j++) {
				this.subScopes.get(j).munge();
			}
		}
		 


		// ---------------------- static part... --------------------



		static void array_merge(Gee.ArrayList<string> fs, string[] toadd) 
		{
			foreach(var i in toadd) {
				fs.add(i);
			}
		 
		}
		static bool initialized = false;
		public static Gee.ArrayList<string> builtin;
		public static Gee.ArrayList<string> skips;
			 
		public static string[] ones;
		public static string[] twos;
	//	static string[] threes : [],
		static	void init () 
		{
			if (Scope.initialized) {
				return;
			}
			Scope.initialized = true;
			Scope.builtin = new Gee.ArrayList<string>(); 
			array_merge(Scope.builtin, "NaN,top".split(","));
		
			Scope.skips =  new Gee.ArrayList<string>(); 
			array_merge(Scope.skips, "as,is,do,if,in,for,int,new,try,use,var,NaN,top".split(","));
		
			Scope.ones = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z".split(",");
			var n = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,0,1,2,3,4,5,6,7,8,9".split(",");

			string[] twos = {};
			for(var i = 0; i < Scope.ones.length; i++) {
			    for(var j = 0; j < n.length; j++) {
			        string tw = Scope.ones[i] + n[j];
			        if (Scope.skips.index_of(tw) < 0) {
			            twos += tw;
			        }
			            
			        /*
			        for(var k = 0; k < n.length; k++) {
			            var thr = a[i] + n[j] + n[k];
			            //println("thr="+ thr + ":iOf="+this.skips.indexOf(thr) );
			            if (this.skips.indexOf(thr)  < 0) {
			                //println("+"+thr);
			                this.threes.push(thr);
			               }
			            
			        }
			        */
			    }
			}
			Scope.twos = twos;
			//println("done creating var list");
			//println("threes="+ this.threes.toSource());
			//throw "DONE";
			
			 
		}
	
	}
}



