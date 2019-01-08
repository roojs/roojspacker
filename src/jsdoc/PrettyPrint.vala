
namespace JSDOC {
	class PrettyPrint : Object 
	{

		// pretty simple...
		static string  escapeHTML(string str) { 
			return str.replace("&","&amp;").
				    replace(">","&gt;"). 
				    replace("<","&lt;"). 
				    replace("\"","&quot;");
		}

		 static  string toPretty(string str)
		{
			
			var txs = new TextStream(str);
			var tr = new TokenReader(null);
			tr.keepComments = true;
			tr.keepWhite = true;
			var toks = tr.tokenize(txs);
			
			//var sp = new ScopeParser(new Collapse(toks));
			//sp.buildSymbolTree();
			
			
		   // sp.mungeSymboltree();
			var r = "";
			//r += sp.warnings.join("<BR>");
			//r == "<BR>";
			
			
			
			
			var cs = ""; // current style..
			
			// loop through and print it...?
			
			
			for (var i = 0;i < toks.length; i++) {
				var ns = toStyle(toks.get(i));
				if (ns != cs) {
				    // change of style
				    if (cs.length > 0) { r += "</span>"; };
				    r +="<span class=\"jsdoc-"+ns+"\">";
				    cs = ns;
				}
				if (toks.get(i).identifier.length > 0) {
				    
				    r += "<span class=\"with-ident2\">" +
				        escapeHTML(toks.get(i).data) + "</span>";
				        continue;
				        
				}
				r += escapeHTML(toks.get(i).data); //.replace(/\n/g, "<BR/>\n");
			}
			if (cs.length > 0) r += "</span>";
			
			return "<code class=\"jsdoc-pretty\">"+r+"</code>";
			
				
		}
		
		static string toStyle(Token tok)
		{

			if (tok.is("WHIT") || tok.is("COMM") ) {
			    if (tok.data.index_of("/") > -1) {
			        return "comment";
			    }
			    return cs; // keep the same..
			}
			if (tok.is("STRN")) {
			    return "string";
			}
			// other 'vary things??
			if (tok.is("NAME") || tok.data == '.' || tok.name == "THIS") {
			    return "var";
			}
			var r = new Regex("^[a-zA-Z]+");
			
			if (r.match(tok.data)) {
			    return "keyword";
			}
			return "syntax";
		}
	}
}