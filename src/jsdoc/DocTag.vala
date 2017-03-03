

namespace JSDOC 
{
	public enum DocTagTitle
	{
		NO_VALUE,
		PARAM,
		PROPERTY,
		CFG
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
            }
            
            // if type == @cfg, and matches (|....|...)
            
            src = src.strip();
            var re = new GLib.Regex("^\\\([^)]+\\\)")
            MatchInfo mi;
            
            if (this.title ==  DocTagTitle.CFG && re.match_all(src, 0, out mi )) {
				var ms = mi.fetch();
				if (ms.contains("|")) {
					var ar = ms.split("|");
					for (var i =0 ; i < ar.length;i++) {
						optvalues.add(ar[i].strip());
					}
					src = src.substring(ms.length, src.length - ms.length);                   
                    
                } else {
                
                }
                
                
            }
            
            
            this.desc = src; // whatever is left
            
            // example tags need to have whitespace preserved
            if (this.title != "example") this.desc = this.desc.trim();
            
            //if (JSDOC.PluginManager) {
            //    JSDOC.PluginManager.run("onDocTag", this);
            //}
		
	

	}