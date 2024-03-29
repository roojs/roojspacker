 
/**
 * Create a new DocComment. This takes a raw documentation comment,
 * and wraps it in useful accessors.
 * @class Represents a documentation comment object.
 * 
 */ 
 
namespace JSDOC 
{
	public class DocComment : Object
	{
 
		public bool isUserComment  = true;
		public bool hasTags		= false;
		public string src          = "";
		//string meta       =  "";
		//Gee.ArrayList<string> tagTexts;
		public Gee.ArrayList<DocTag>    tags;
	
		static GLib.Regex has_tag_regex;
		static GLib.Regex tag_regex;
		static GLib.Regex comment_line_start_regex;
		static GLib.Regex comment_line_start_white_space_regex;
		static GLib.Regex comment_needs_desc_regex;
		 /**
		 * Used to store the currently shared tag text.
		 * not sure where we use this yet..
		 * but i think it's related to merging multiple comments together...
		 */

		public static string    shared = "";
		
		static bool done_init = false;
	
		static void initRegex()
		{
			if (DocComment.done_init) {
				return;
			}
			DocComment.has_tag_regex = new GLib.Regex("^\\s*@\\s*\\S+"); // multiline?

			DocComment.tag_regex = new GLib.Regex("(^|[\\r\\n])\\s*@"); // empty line, then @ or starting with @?
			

			DocComment.comment_line_start_regex = new GLib.Regex("(^\\/\\*\\*|\\*\\/$)");
			DocComment.comment_line_start_white_space_regex = new GLib.Regex("\\s*\\* ?");
			DocComment.comment_needs_desc_regex = new GLib.Regex("\\s*@(class|event|property)");
			
			DocComment.done_init = true;
		}
	 
		public DocComment (string comment = "") 
		{
		    
		    DocComment.initRegex();
		     
		    GLib.debug("parse comment : %s", comment);
		    this.tags          = new Gee.ArrayList<DocTag>();

		    
		 
	        if (comment.strip() == "") {
	            comment = "/** @desc */";
	            this.isUserComment = false;
	        }
	        
	        this.src = DocComment.unwrapComment(comment);
	        
	        //println(this.src);
	        
	        // looks like #+ support???
	        /*
	        this.meta = "";
	        if (this.src.indexOf("#") == 0) {
	            this.src.match(/#(.+[+-])([\s\S]*)$/);
	            if (RegExp.$1) this.meta = RegExp.$1;
	            if (RegExp.$2) this.src = RegExp.$2;
	        }
	        */
	        this.hasTags = /^\s*@\s*\S+/.match(this.src);

	        this.fixDesc();
	        
	        //if (typeof JSDOC.PluginManager != "undefined") {
	        //    JSDOC.PluginManager.run("onDocCommentSrc", this);
	        //}
	        
	        this.src = DocComment.shared+"\n"+this.src;

			//var tagTexts      = new Gee.ArrayList<string>();
 
	        
	        var bits = /(^|[\r\n])\s*@/.split(this.src);
   			for(int i=0; i<bits.length; i++) {
   				var sa = bits[i];
   				if (sa.strip().length >0) {
   					this.tags.add(new DocTag(sa));
	   				// tagTexts.add(sa); // ?? strip again?
   				}
			}
			
	   				
	        
	    }
	        
		   
		    
		/**
		 * Remove slash-star comment wrapper from a raw comment string.
		 *  @type String
		 */
		public static string  unwrapComment( string comment) 
		{
		     if (comment.length < 1) {
				 return "";
			 }
			 
			 var ret = /^\/\*\*|\*\/$/.replace(
			 		comment, comment.length, 0, "", 0 ); //GLib.RegexMatchFlags.NEWLINE_ANYCRLF );
			 
			 ret = /(^|[\r\n])\s*\* ?/.replace(ret, ret.length, 0, "\n"  ); //);
		     
		    return ret.strip();
		 }
	    /**
	        If no @desc tag is provided, this function will add it.
	     */
	    void fixDesc() 
	    {
	        //if (this.meta && this.meta != "@+") return;
	        
	        
	        
	        // does not have any @ lines..
	        // -- skip comments without @!!
	        if (!this.hasTags) {
	            this.src = "@desc "+ this.src;
	            // TAGS that are not \n prefixed!! ...
	            // does not make sense....???
	            //this.src = this.src.replace(/@\s*type/g, '\n@type'); 
	        
	            return;
	        }
	        // kdludge for stuff...
	        //this.src = this.src.replace(/@\s*type/g, '\n@type'); 
	        
	        // only apply @desc fix to classes..
	        if (!DocComment.comment_needs_desc_regex.match(this.src,GLib.RegexMatchFlags.NEWLINE_ANYCRLF) ) {
	            return;
	        }
	        // if no desc - add it on the first line that is not a @
	        var lines = this.src.split("\n");
	        var nsrc = "";
	        var gotf = false;
	        
	        for(var i =0; i < lines.length;i++) {
	            var line = lines[i];
	            if (gotf) {
	                nsrc += line + "\n";
	                continue;
	            }
	            if (DocComment.has_tag_regex.match(line)) { // line with @
	                nsrc += line + "\n";
	                continue;
	            }
	            gotf = true;
	            nsrc += "@desc " + line + "\n";
	            
	        }
	         
	        this.src = nsrc;
	        
	         
	        
	    }
		  
		 
	    public Gee.ArrayList<DocTag> getTag ( DocTagTitle tagTitle) {
			var ret = new Gee.ArrayList<DocTag>();
	        foreach(var tag in this.tags) {
	    		if (tag.title == tagTitle) {
	    			ret.add(tag);
    			}
			}
			return ret;
	    }
	     public string getTagAsString ( DocTagTitle tagTitle) {
			string[] ret =  {};
	        foreach(var tag in this.tags) {
	    		if (tag.title == tagTitle) {
	    			ret += tag.desc;
    			}
			}
			return string.joinv("\n", ret);
	    }
	    
	    public Json.Object toJson()
		{
			var ret = new Json.Object();
			ret.set_string_member("src", this.src);
			var ar = new Json.Array();
			foreach(var a in this.tags) {
				ar.add_object_element(a.toJson());
			}
			ret.set_array_member("tags", ar);
			ret.set_boolean_member("isUserComment", this.isUserComment);			
			ret.set_boolean_member("hasTags", this.hasTags);						
			return ret;
		}
	
	}
}

