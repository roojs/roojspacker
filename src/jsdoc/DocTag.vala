

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
		public ?? optvalues;

	
	
	
	
	
		public DocTag (string in_src)
		{
		    
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
                GLib.debug(e.toString());
                else throw e;
            }
            
            // if type == @cfg, and matches (|....|...)
            
            src = src.trim();
            if (this.title == "cfg" && src.match(/^\([^)]+\)/)) {
                var m = src.match(/^\(([^)]+)\)/);
                print(m);
                if (m[1].match(/\|/)) {
                    var opts = m[1].trim().split(/\s*\|\s*/);
                    this.optvalues = opts;
                    src = src.substring(m[0].length).trim();
                    print(src);
                    
                    
                }
                
                
            }
            
            
            this.desc = src; // whatever is left
            
            // example tags need to have whitespace preserved
            if (this.title != "example") this.desc = this.desc.trim();
            
            //if (JSDOC.PluginManager) {
            //    JSDOC.PluginManager.run("onDocTag", this);
            //}
		
	

	}