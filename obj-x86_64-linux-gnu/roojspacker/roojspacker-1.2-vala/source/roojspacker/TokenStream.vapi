/* TokenStream.vapi generated by valac 0.36.6, do not modify. */

using GLib;

namespace JSDOC {
	public class TokenStream : Object {
		protected Gee.ArrayList<Token> tokens;
		public int cursor;
		public TokenStream (Gee.ArrayList<Token> tokens);
		public Gee.ArrayList<Token> toArray ();
		public void rewind ();
		public Token? look (int n, bool considerWhitespace);
		public Token lookAny (int n);
		public int lookFor (string data);
		public Token lookTok (int n);
		public Token? next ();
		public Gee.ArrayList<Token>? nextM (int howMany) throws TokenStreamError;
		public Token? nextTok ();
		public Token? nextNonSpace ();
		public Gee.ArrayList<Token> balance (TokenName in_start) throws TokenStreamError;
		public Token? getMatchingTokenEnd (TokenName end);
		public Token? getMatchingToken (TokenName start, int depth = 0);
		public Gee.ArrayList<Token> remaining ();
		public void printRange (int start, int end);
		public void dump (int start, int end);
		public void dumpAll (string indent);
		public void dumpAllFlat ();
	}
	public errordomain TokenStreamError {
		ArgumentError
	}
}
