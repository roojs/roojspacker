/* Lang.vapi generated by valac 0.36.6, do not modify. */

using GLib;

namespace JSDOC {
	public class Lang_Class : Object {
		public Lang_Class ();
		public bool isBuiltin (string name);
		public string whitespace (string ch);
		public string newline (string ch);
		public TokenName keyword (string word) throws LangError;
		public TokenName? matching (TokenName name) throws LangError;
		public bool isKeyword (string word);
		public TokenName puncFirstString (char ch);
		public TokenName puncString (string ch);
		public bool isNumber (string str);
		public bool isHexDec (string str);
		public bool isWordString (string str);
		public bool isWordChar (char c);
		public bool isSpace (string str);
		public bool isSpaceC (char str);
		public bool isNewline (string str);
		public bool isNewlineC (char str);
		public bool isBoolean (string str);
	}
	public errordomain LangError {
		ArgumentError
	}
	public static Lang_Class Lang;
}
