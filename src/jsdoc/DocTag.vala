

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
	
	
		static bool done_init = false;
		
		static void initRegex()
		{
			if (DocTag.done_init) {
				return;
			}
			DocTag.title_regex = new Regex("^\s*(\S+)(?:\s([\s\S]*))?$");
			DocTag.opval_regex = new GLib.Regex("^\\\([^)]+\\\)");
		
		
			DocTag.done_init = true;
		}
	
	
		public DocTag (string in_src)
		{
		    
		    
		    
		    
		    
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

        if (parts && parts[1]) this.title = parts[1];
        if (parts && parts[2]) src = parts[2];
        else src = "";
        
        return src;
    },
     
	
	
	