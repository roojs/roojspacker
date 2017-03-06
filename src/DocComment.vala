 
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

		bool isUserComment  = true;
		bool hasTags		= false;
		string src          = "";
		//string meta       =  "";
		//Gee.ArrayList<string> tagTexts;
		Gee.ArrayList<DocTag>    tags;
	
		GLib.Regex hastag_regex;
		GLib.Regex tag_regex;
		
		static bool done_init = false;
	
		static void initRegex()
		{
			if (DocComment.done_init) {
				return;
			}
			DocComment.hastag_regex = new GLib.Regex("^\s*@\s*\S+"); // multiline?
			DocComment.tag_regex = new GLib.Regex("(^|[\r\n])\s*@"); // empty line, then @ or starting with @?
			DocComment.done_init = true;
		}
	 
		public DocComment (string comment) 
		{
		    
		    DocComment.initRegex();
		     
		    this.tags          = Gee.ArrayList<DocTag>();
			this.parse(comment);
		    
		
		    /**
		     * serialize..
		     */
		     /*
		    toJSON :function(t)
		    {
		        
		        var ret = { '*object' : 'DocComment' };
		        
		        var _this = this;
		        ['isUserComment','src', 'meta',  'tags'].forEach(function(k) {
		            ret[k] = _this[k];
		        })
		        
		        return ret;
		    }, 
		    */   
		    /**
		    * @requires JSDOC.DocTag
		    */
		    void parse( string comment) {
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
		        

		        if (!DocComment.hastag_regex.match(this.src)) {

		            this.hasTags = false;
		            
		            //return;
		        }
		        this.fixDesc();
		        
		        //if (typeof JSDOC.PluginManager != "undefined") {
		        //    JSDOC.PluginManager.run("onDocCommentSrc", this);
		        //}
		        
		        this.src = DocComment.shared+"\n"+this.src;
 
				//var tagTexts      = new Gee.ArrayList<string>();
		        GLib.MatchInfo mi;
		        
	    		if (DocComment.tag_regex.match_all.match(this.src, 0, mi) {
		   			while(mi.next()) {
		   				var sa = mi.fetch(0);
		   				if (sa.strip().length >0) {
		   					this.tags.add(new DocTag(sa));
			   				// tagTexts.add(sa); // ?? strip again?
		   				}
	   				}
   				}
		   				
		        
		    },
		     

		    /**
		        If no @desc tag is provided, this function will add it.
		     */
		    fixDesc : function() {
		        if (this.meta && this.meta != "@+") return;
		        
		        
		        
		        // does not have any @ lines..
		        // -- skip comments without @!!
		        if (!/^\s*@\s*\S+/.test(this.src)) {
		            this.src = "@desc "+this.src;
		            // TAGS that are not \n prefixed!! ...
		            this.src = this.src.replace(/@\s*type/g, '\n@type'); 
		        
		            return;
		        }
		        // kdludge for stuff...
		        //this.src = this.src.replace(/@\s*type/g, '\n@type'); 
		        
		        // only apply @desc fix to classes..
		        if (!/\s*@(class|event|property)/m.test(this.src) ) {
		            return;
		        }
		        // if no desc - add it on the first line that is not a @
		        var lines = this.src.split("\n");
		        var nsrc = '';
		        var gotf = false;
		        
		        for(var i =0; i < lines.length;i++) {
		            var line = lines[i];
		            if (gotf) {
		                nsrc += line + "\n";
		                continue;
		            }
		            if (/^\s*[@\s]/.test(line)) { // line with @
		                nsrc += line + "\n";
		                continue;
		            }
		            gotf = true;
		            nsrc += '@desc ' + line + "\n";
		            
		        }
		         
		        this.src = nsrc;
		        
		        
		        
		    },
		  
		/**
		    Provides a printable version of the comment.
		    @type String
		 */
		    toString : function() {
		        return this.src;
		    },

		/*~t
		    assert("testing JSDOC.DocComment#fixDesc");
		    var com = new JSDOC.DocComment();
		    com.src = "foo";
		    assertEqual(""+com, "foo", "stringifying a comment returns the unwrapped src.");
		*/

		/**
		    Given the title of a tag, returns all tags that have that title.
		    @type JSDOC.DocTag[]
		 */
		 /*
		 
		    toQDump : function(t)
		    {
		        //println(t.toSource());
		        var r =  JSDOC.toQDump(t, 'JSDOC.DocComment.fromDump({', '})', {}); // send it an empty object..
		        //println(r);
		        return r;
		    } ,
		    */
		 
		    getTag : function(/**String*/tagTitle) {
		        return this.tags.filter(function($){return (typeof($['title']) != 'undefined') && ($.title == tagTitle)});
		    }
		    
	});


	/// static methods..

	XObject.extend(DocComment, 
		{
		    
		    /**
		     * Used to store the currently shared tag text.
		     */
		    shared : "",
		    
		    /**
		     * Remove slash-star comment wrapper from a raw comment string.
		     *  @type String
		     */
		    unwrapComment : function(/**String*/comment) {
		        if (!comment) return "";
		        var unwrapped = comment.replace(/(^\/\*\*|\*\/$)/g, "").replace(/^\s*\* ?/gm, "");
		        return unwrapped;
		    },

		    fromDump : function(t)
		    {
		        var ns = new DocComment();
		        for (var i in t) {
		            ns[i] = t[i];
		        }
		        return ns;
		    }
	});