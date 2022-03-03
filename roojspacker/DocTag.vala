

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
		DEPRECATED,
 
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
		PRIVATE,
		IGNORE,
		ARGUMENTS,
		EXTENDS,
		DEFAULT,
		MEMBEROF,
		PUBLIC,
		SCOPE,
		SCOPEALIAS,
		
		// these are some we have added for creating trees etc..
		CHILDREN, // what classes can be added as child in a tree
		PARENT,  // restrict what the class can be added to.
		ABSTRACT, // is the class abstract
		BUILDER_TOP // can the element be used as a top level in the gui builder
  
  
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
		public string type = "";  // eg.. boolean / string etc..., may be xxxx|bbbb - eg. optional types
		public string name = ""; // eg. "title" << a property name etc...
		public bool isOptional = false;
		public string defaultValue = "";
		public string desc = "";
		public Gee.ArrayList<string> optvalues;
		public string memberOf = ""; // set by add addMember..

		public string asString()
		{
			return "DocTag: title=%s name=%s type=%s  desc=%s".printf(
				this.title.to_string(),
				this.name,
				this.type,
				this.desc
			);
		}
	
 		public Json.Object toJson()
		{
			var ret = new Json.Object();
			ret.set_string_member("title", this.title.to_string());
			ret.set_string_member("type", this.type);
			ret.set_string_member("name", this.name);
			ret.set_string_member("defaultValue", this.defaultValue);
			ret.set_string_member("desc", this.desc);
			ret.set_string_member("memberOf", this.memberOf);
			ret.set_boolean_member("isOptional", this.isOptional);
			var ar = new Json.Array();
			foreach(var ov in this.optvalues) {
		 	 	ar.add_string_element(ov);
	 	 	}
	 	 	ret.set_array_member("optvalues", ar);
	 	 	return ret;
 	 	}
	
	
		public DocTag (string in_src)
		{
		    
		    GLib.debug("Parsing Tag: %s", in_src);
		    
		     
		    
		    
		    this.optvalues = new Gee.ArrayList<string>();
		    
		    var src = in_src;
			
            try {
                src = this.nibbleTitle(src);
                
                src = this.nibbleType(src);
                

                // only some tags are allowed to have names.
                if (
            		this.title == DocTagTitle.PARAM ||
	                this.title == DocTagTitle.PROPERTY || 
	                this.title == DocTagTitle.CFG) { // @config is deprecated << not really?
                    src = this.nibbleName(src);
                }
            }
            catch(DocTagException e) {
                GLib.debug("Failed to parse tag: '%s' = error = %s", in_src, e.message);
                // only throw if in 'strict'??
                //throw e;
                return;
            }
            
            // if type == @cfg, and matches (|....|...)
            
            src = src.strip();
            
            // our code uses (Optional) - but we really want to ignore this.
            src = /\(Optional\)/.replace(src, src.length, 0,  "").strip();
            
 
            MatchInfo mi = null;
            
            
            
            if (this.title ==  DocTagTitle.CFG && /^\([^)]+\)/.match_all(src, 0, out mi )) {
	            
				var ms = mi.fetch(0);
				GLib.debug("Got Opt list: %s", ms);
				
				ms = ms.substring(1,ms.length-2);
				GLib.debug("clan to: %s", ms);
				if (ms.contains("|")) {
					var ar = ms.split("|");
				GLib.debug("split to: %d", ar.length);
					for (var i =0 ; i < ar.length;i++) {
	                    GLib.debug("Add optvalue: %s",ar[i].strip());
						this.optvalues.add(ar[i].strip());
					}
					src = src.substring(ms.length, src.length - (ms.length+2));
                    GLib.debug("SRC NOW: %s",src);
                } 
                
            }
            if (this.title ==  DocTagTitle.CFG &&  /\[required\]/.match(src)) {
            	this.isOptional = false;
            	src = /\[required\]/.replace(src, src.length, 0,  "").strip();
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
		    //GLib.debug("nibbleTitle: %s", src);
		    MatchInfo mi;
		     
		    if(! /^\s*(\S+)\s*(?:\s([\s\S]*))?$/.match_full(src, src.length, 0, 0, out mi) || 
			    mi.get_match_count() < 2)  {
				throw new DocTagException.NO_TITLE("missing title");
				return src;
		    }
		    
		    // convert the @xxx to a DocTagTitle
		    // wonder if caching this as a GeeHashmap would be quicker?
		    
		    EnumClass enumc = (EnumClass) typeof (DocTagTitle).class_ref ();

		    unowned EnumValue? eval = enumc.get_value_by_name(
			//	 "JSDOC_DOC_TAG_TITLE_"+  mi.fetch(1).up()
		   		 "JSDOC_DOC_TAG_TITLE_"+  mi.fetch(1).up().replace("-", "_")
    		 );
		    if (eval == null) {
				throw new DocTagException.INVALID_TITLE("title not supported ??");
				return src;
		    }
		    this.title = (DocTagTitle) eval.value;
		    return mi.get_match_count() > 2 ? mi.fetch(2) : "";

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
            if(! /^\s*\{/.match_all(src, 0, out mi)) {
         	   return src;
     	    }
            int start;
            int stop;
              
			this.balance(src,'{', '}', out start, out stop);
			//GLib.debug("nibble type: %s %d, %d", src, start,stop);
            if (stop == -1) {
                throw new DocTagException.INVALID_TYPE("Malformed comment tag ignored. Tag type requires an opening { and a closing }: ") ;
                return src;
            }
            this.type = src.substring(start+1,stop-1).strip();
            this.type = this.type.replace(",", "|"); // multiples can be separated by , or |
            return src.substring(stop+1, -1);
            
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
            //GLib.debug("nibbleName: %s", in_src);
            
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
                GLib.debug("got name %s", this.name);                
                return src.substring(stop+1, stop+1-src.length);
            }
			// not encased with [ ]

		    MatchInfo mi;

            if (/^(\S+)(?:\s([\s\S]*))?$/.match_full(src, src.length, 0, 0,  out mi)) {
        		this.name = mi.fetch(1);
        		GLib.debug("got name %s", this.name);
				return mi.get_match_count() > 2 ? mi.fetch(2) : "";
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
		
		public Json.Array optvalue_as_json_array()
		{
			var ret = new Json.Array();
			foreach (var str in this.optvalues ) {
				ret.add_string_element(str);
			}
			return ret;
			
			
		}
		public Json.Object toPropertyJSON (Symbol parent)
		{
			
			var add = new Json.Object();
			add.set_string_member("name",this.name);
			add.set_string_member("type",this.type);
			add.set_string_member("desc",this.desc);
			add.set_string_member("memberOf", this.memberOf == parent.alias ? "" : this.memberOf);
		    return add;
	    }   
		
		
	}
}
	
	