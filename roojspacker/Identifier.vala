

/**
 * @class  Identifier
 * holds details about identifiers and their replacement values
 * used by the packer..
 * 
 */

namespace JSDOC 
{
    public class  Identifier  : Object 
    {
		
		public string name;
		public int refcount = 1; // used?
		public string mungedValue; // should be at least 1?!?!
		public Scope scope ;  // script of fn scope..
		public bool toMunge = true;
	
	

		public  Identifier(string name, Scope scope) {
		   // print("NEW IDENT: " + name);
			this.name = name;
			this.scope = scope;
			this.mungedValue = "";
		//	this.identifiers = {}; <<< used where?
	
		}
	}
	
}

 
