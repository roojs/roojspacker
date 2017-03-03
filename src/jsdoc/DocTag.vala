

namespace JSDOC 
{
	public enum DocTagTitle
	{
		NO_VALUE,
		PARAM,
		PROPERTY,
		CFG,
		EXAMPLE
	}


	public class DocTag : Object 
	{

		public DocTagTitle title = DocTagTitle.NO_VALUE;
		public ?? type;
		public string name;
		public bool isOptional = false;
		public string defaultValue = "";
		public string desc = "";
		public Gee.ArrayList<string> optvalues;

	
	
		static private GLib.Regex title_regex;
		static private GLib.Regex opval_regex;
		static private GLib.Regex type_regex;
	
		static bool done_init = false;
		
		static void initRegex()
		{
			if (DocTag.done_init) {
				return;
			}
			DocTag.title_regex = new Regex("^\s*(\S+)(?:\s([\s\S]*))?$");
			DocTag.opval_regex = new GLib.Regex("^\\\([^)]+\\\)");
			DocTag.type_regex = new GLib.Regex("^\s*\{");
		
			DocTag.done_init = true;
		}
	
	
		public DocTag (string in_src)
		{
		    
		    this.initRegex();
		    
		    
		    
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
            catch(DocTagExcetion e) {
                GLib.debug(e.message);
                // only throw if in 'strict'??
                throw e;
                return;
            }
            
            // if type == @cfg, and matches (|....|...)
            
            src = src.strip();
 
            MatchInfo mi;
            
            if (this.title ==  DocTagTitle.CFG && opval_regex.match_all(src, 0, out mi )) {
				var ms = mi.fetch();
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
		private string nibbleTitle (string in_src)
		{
		    MatchInfo mi;
		    if(! title_regex.match_all(src, 0, mi)) {
				throw new DocTagException.NO_TITLE("missing title");
				return src;
		    }
		    EnumClass enumc = (EnumClass) typeof (DocTagTitle).class_ref ();
		    unowned EnumValue? eval = enumc.get_value_by_name ( mi.fetch(1).upper());
		    if (eval == null) {
				throw new DocTagException.INVALID_TITLE("title not supported ??");
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

            
            if (src.match(/^\s*\{/)) {
                var typeRange = this.balance(src,"{", "}");
                if (typeRange[1] == -1) {
                    throw "Malformed comment tag ignored. Tag type requires an opening { and a closing }: "+src;
                }
                this.type = src.substring(typeRange[0]+1, typeRange[1]).trim();
                this.type = this.type.replace(/\s*,\s*/g, "|"); // multiples can be separated by , or |
                src = src.substring(typeRange[1]+1);
            }
            
            return src;
        },
         
	
	