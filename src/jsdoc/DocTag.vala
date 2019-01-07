

namespace JSDOC 
{
	public enum DocTagTitle
	{
		NO_VALUE,
		PARAM,
		PROPERTY,
		CFG,
		EXAMPLE,
		SINGLETON,
		AUTHOR,
		METHOD,
		DESC,
		OVERVIEW,
		SINCE,
		CONSTANT,
		VERSION,
		DEPRICATED,
 
		SEE,
		CLASS,
		NAMESPACE,
		CONSTRUCTOR,
		STATIC,
 
		
		INNER,
		FIELD,
		FUNCTION,
		EVENT,
		NAME,
		RETURN,
		THROWS,
		REQUIRES,
		TYPE,
 
	}
	
	errordomain DocTagException {
		NO_TITLE,
		INVALID_TITLE,
		INVALID_NAME,
		INVALID_TYPE
	}


	public class DocTag : Object 
	{

		public DocTagTitle title = DocTagTitle.NO_VALUE;
		public string type;  // eg.. boolean / string etc..., may be xxxx|bbbb - eg. optional types
		public string name; // eg. "title" << a property name etc...
		public bool isOptional = false;
		public string defaultValue = "";
		public string desc = "";
		public Gee.ArrayList<string> optvalues;

	
	
		 private static  GLib.Regex title_regex;
		 private static GLib.Regex opval_regex;
		 private static GLib.Regex type_regex;
		 private static GLib.Regex name_regex;
		 
		static bool done_init = false;
		
		static void initRegex()
		{
			if (DocTag.done_init) {
				return;
			}
			DocTag.title_regex = new Regex("^\\s*(\\S+)(?:\\s([\\s\\S]*))?$");
			DocTag.opval_regex = new GLib.Regex("^\\([^)]+\\)");
			DocTag.type_regex = new GLib.Regex("^\\s*\\{");
			DocTag.name_regex = new GLib.Regex("^(\\S+)(?:\\s([\\s\\S]*))?$");
			
			DocTag.done_init = true;
		}
	
	
		public DocTag (string in_src)
		{
		    
		    DocTag.initRegex();
		    
		    
		    
		    this. optvalues = new Gee.ArrayList<string>();
		    
		    var src = in_src;
			
            try {
                src = this.nibbleTitle(src);
                
                src = this.nibbleType(src);
                
                // only some tags are allowed to have names.
                if (
            		this.title == DocTagTitle.PARAM ||
	                this.title == DocTagTitle.PROPERTY || 
	                this.title == DocTagTitle.CFG) { // @config is deprecated
                    src = this.nibbleName(src);
                }
            }
            catch(DocTagException e) {
                GLib.debug(e.message);
                // only throw if in 'strict'??
                throw e;
                return;
            }
            
            // if type == @cfg, and matches (|....|...)
            
            src = src.strip();
 
            MatchInfo mi = null;
            
            if (this.title ==  DocTagTitle.CFG && opval_regex.match_all(src, 0, out mi )) {
				var ms = mi.fetch(0);
				if (ms.contains("|")) {
					var ar = ms.split("|");
					for (var i =0 ; i < ar.length;i++) {
						optvalues.add(ar[i].strip());
					}
					src = src.substring(ms.length, src.length - ms.length);                   
                    
                } 
                
            }
            
            
            this.desc = src; // whatever is left
            
            // example tags need to have whitespace preserved
            if (this.title != DocTagTitle.EXAMPLE) {
        		this.desc = this.desc.strip();
    		}
            

		
	

		}
	
	
		/**
		    Find and shift off the title of a tag.
		    @param {string} src
		    @return src
		 */
		private string nibbleTitle (string src) throws DocTagException
		{
		    MatchInfo mi;
		    if(! title_regex.match_all(src, 0, out mi)) {
				throw new DocTagException.NO_TITLE("missing title");
				return src;
		    }
		    EnumClass enumc = (EnumClass) typeof (DocTagTitle).class_ref ();

		    unowned EnumValue? eval = enumc.get_value_by_name (  mi.fetch(1).up());
		    if (eval == null) {
				throw new DocTagException.INVALID_TITLE("title not supported ??");
				return src;
		    }
		    this.title = (DocTagTitle) eval.value;
		    return mi.fetch(2);

		}
		 
		  /**
            Find and shift off the type of a tag.
            @requires frame/String.js
            @param {string} src
            @return src
         */
    	private string nibbleType(string src) 
        {
		    MatchInfo mi;
            if(! type_regex.match_all(src, 0, out mi)) {
         	   return src;
     	    }
            int start;
            int stop;
              
			this.balance(src,'{', '}', out start, out stop);
            if (stop == -1) {
                throw new DocTagException.INVALID_TYPE("Malformed comment tag ignored. Tag type requires an opening { and a closing }: ") ;
                return src;
            }
            this.type = src.substring(start+1,stop).strip();
            this.type = this.type.replace(",", "|"); // multiples can be separated by , or |
            return src.substring(stop+1, stop+1-src.length);
            
            return src;
        }
         
         
         
        /**
            Find and shift off the name of a tag.
            @requires frame/String.js
            @param {string} src
            @return src
         */
        private string nibbleName( string in_src) throws DocTagException
         {

           
            var src = in_src.strip();
            
            // is optional?
            if (src.get(0) == '[') {
        		int start, stop;
                 this.balance(src,'[', ']', out start, out stop);
                if (stop == -1) {
                    throw new  DocTagException.INVALID_NAME("Malformed comment tag ignored. Tag optional name requires an opening [ and a closing ]: ");
                    return src;
                }
                this.name = src.substring(start+1, stop).strip();
                this.isOptional = true;
                
                src = src.substring(stop+1);
                
                // has default value?
                var nameAndValue = this.name.split("=");
                if (nameAndValue.length > 1) {
            		var oname = this.name;
                    this.name = nameAndValue[0].strip();
                    this.defaultValue = oname.substring( nameAndValue[0].length + 1 , nameAndValue[0].length + 1 - oname.length); /// what about
                }
                return src.substring(stop+1, stop+1-src.length);
            }
			// not encased with [ ]

		    MatchInfo mi;

            if (name_regex.match_all(src, 0,  out mi)) {
        		this.name = mi.fetch(1);
				return mi.fetch(2);        		
            }
           	

            return src;
        }
         
         
        private void balance(string str, char open, char close, out int start, out int stop) {
            start = 0;
            stop  =-1;
            while (str.get(start) != open) {
                if (start == str.length) {
            		return;
        		}
                start++;
            }
            
            stop = start +1;
            var balance = 1;
            while (stop < str.length) {
                if (str.get(stop) == open) balance++;
                if (str.get(stop) == close) balance--;
                if (balance == 0) break;
                stop++;
                if (stop == str.length) {
            		stop = -1;
            		return;
        		}
            }
            

		}
	}
}
	
	