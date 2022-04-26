/* Symbol.vapi generated by valac 0.36.6, do not modify. */

using GLib;

namespace JSDOC {
	public class Symbol : Object {
		public static bool regex_init;
		public Gee.ArrayList<string> augments;
		public Gee.ArrayList<Symbol> methods;
		public Gee.ArrayList<Symbol> properties;
		public Gee.ArrayList<DocTag> returns;
		public Gee.HashMap<string,Gee.ArrayList<string>> childClasses;
		public Gee.ArrayList<string> childClassesList;
		public Gee.ArrayList<string> inheritsFrom;
		public Gee.HashMap<string,DocTag> cfgs;
		public Gee.ArrayList<string> tree_parent;
		public Gee.ArrayList<string> tree_children;
		public DocComment comment;
		public string alias;
		public string desc;
		public string isa;
		public bool isEvent;
		public bool isConstant;
		public bool isIgnored;
		public bool isInner;
		public bool isNamespace;
		public bool isPrivate;
		public bool isStatic;
		public bool isAbstract;
		public bool isBuilderTop;
		public string memberOf;
		public static string srcFile;
		public string asString ();
		public void initArrays ();
		public Symbol.new_builtin (string name);
		public Symbol.new_populate_with_args (string name, Gee.ArrayList<string> @params, string isa, DocComment comment);
		public bool @is (string what);
		public bool isaClass ();
		public bool isBuiltin ();
		public void inherit (Symbol symbol);
		public void addMember (Symbol symbol);
		public void addChildClass (string clsname, string parent);
		public void addDocTag (DocTag docTag);
		public void addConfig (DocTag docTag);
		public Gee.ArrayList<DocTag> configToArray ();
		public string makeFuncSkel ();
		public string makeMethodSkel ();
		public Json.Array stringArrayToJson (Gee.ArrayList<string> ar);
		public Json.Array symbolArrayToJson (Gee.ArrayList<Symbol> ar);
		public Json.Array docTagsArrayToJson (Gee.ArrayList<DocTag> ar);
		public Json.Object assocStringToJson (Gee.HashMap<string,Gee.ArrayList<string>> ar);
		public Json.Object assocDocTagToJson (Gee.HashMap<string,DocTag> ar);
		public Json.Object toJson ();
		public Json.Object toClassDocJSON ();
		public Json.Array paramsToJson ();
		public Json.Array returnsToJson ();
		public Json.Object toClassJSON ();
		public Json.Object toEventJSON (Symbol parent);
		public Json.Object toMethodJSON (Symbol parent);
		public Symbol ();
		public string private_name { set; }
		public string name { get; }
		public Gee.ArrayList<DocTag> @params { get; }
	}
}
