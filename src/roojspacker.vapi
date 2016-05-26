/* roojspacker.vapi generated by valac 0.32.0, do not modify. */

namespace JSDOC {
	[CCode (cheader_filename = "roojspacker.h")]
	public class Collapse : JSDOC.TokenStream {
		public Collapse (Gee.ArrayList<JSDOC.Token> tokens);
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public class Identifier : GLib.Object {
		public string mungedValue;
		public string name;
		public int refcount;
		public JSDOC.Scope scope;
		public bool toMunge;
		public Identifier (string name, JSDOC.Scope scope);
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public class Lang_Class : GLib.Object {
		public Lang_Class ();
		public bool isBoolean (string str);
		public bool isBuiltin (string name);
		public bool isHexDec (string str);
		public bool isKeyword (string word);
		public bool isNewline (string str);
		public bool isNewlineC (char str);
		public bool isNumber (string str);
		public bool isSpace (string str);
		public bool isSpaceC (char str);
		public bool isWordChar (char c);
		public bool isWordString (string str);
		public JSDOC.TokenName keyword (string word) throws JSDOC.LangError;
		public JSDOC.TokenName? matching (JSDOC.TokenName name) throws JSDOC.LangError;
		public string newline (string ch);
		public JSDOC.TokenName puncFirstString (char ch);
		public JSDOC.TokenName puncString (string ch);
		public string whitespace (string ch);
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public class Packer : GLib.Object {
		public string activeFile;
		public string baseDir;
		public bool cleanup;
		public bool dumpTokens;
		public bool keepWhite;
		public string outstr;
		public bool skipScope;
		public string tmpDir;
		public Packer (string target, string targetDebug = "");
		public void loadFile (string f);
		public void loadFiles (string[] fs);
		public void loadSourceIndex (string in_srcfile);
		public void loadSourceIndexes (Gee.ArrayList<string> indexes);
		public string md5 (string str);
		public string pack ();
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public class Scope : GLib.Object {
		public static Gee.ArrayList<string> builtin;
		public static string[] ones;
		public JSDOC.Scope parent;
		public static Gee.ArrayList<string> skips;
		public Gee.ArrayList<JSDOC.Scope> subScopes;
		public static string[] twos;
		public Scope (int braceN, JSDOC.Scope? parent, int startTokN, JSDOC.Token? token);
		public void addHint (string varName, string varType);
		public void addToParentScope (string ident);
		public JSDOC.Identifier declareIdentifier (string symbol, JSDOC.Token token);
		public void dump (string indent = "");
		public JSDOC.Identifier? getIdentifier (string symbol, JSDOC.Token token);
		public string[] getUsedSymbols ();
		public bool isProtectedVar (string ident);
		public void munge ();
		public void preventMunging ();
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public class ScopeParser : GLib.Object {
		public ScopeParser (JSDOC.TokenStream ts);
		public void buildSymbolTree ();
		public void mungeSymboltree ();
		public void printWarnings ();
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public class TextStream : GLib.Object {
		public TextStream (string text = "");
		public char lookC (int n = 0);
		public bool lookEOF (int n = 0);
		public string lookS (int n = 0);
		public char nextC ();
		public string nextS (int n = 1);
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public class TextStreamChar : GLib.Object {
		public char c;
		public bool eof;
		public TextStreamChar (char val, bool eof = false);
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public class Token : GLib.Object {
		public string data;
		public int id;
		public JSDOC.Identifier identifier;
		public Gee.ArrayList<Gee.ArrayList<JSDOC.Token>> items;
		public Gee.ArrayList<string> keyseq;
		public int line;
		public JSDOC.TokenName name;
		public string outData;
		public string prefix;
		public Gee.HashMap<string,JSDOC.TokenKeyMap> props;
		public JSDOC.TokenType type;
		public Token (string data, JSDOC.TokenType type, JSDOC.TokenName name, int line = -1);
		public string asString ();
		public void dump (string indent);
		public bool isName (JSDOC.TokenName what);
		public bool isType (JSDOC.TokenType what);
		public string toRaw (int lvl = 0);
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public class TokenArray : GLib.Object {
		public Gee.ArrayList<JSDOC.Token> tokens;
		public TokenArray ();
		public void dump ();
		public new JSDOC.Token @get (int i);
		public JSDOC.Token? last ();
		public JSDOC.Token? lastSym ();
		public JSDOC.Token? pop ();
		public void push (JSDOC.Token t);
		public int length { get; }
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public class TokenKeyMap : GLib.Object {
		public JSDOC.Token key;
		public Gee.ArrayList<JSDOC.Token> vals;
		public TokenKeyMap ();
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public class TokenReader : GLib.Object {
		public bool collapseWhite;
		public string filename;
		public bool ignoreBadGrammer;
		public bool keepComments;
		public bool keepDocs;
		public bool keepWhite;
		public bool sepIdents;
		public TokenReader ();
		public int findPuncToken (JSDOC.TokenArray tokens, string data, int n);
		public JSDOC.Token? lastSym (JSDOC.TokenArray tokens, int n);
		public bool read_dbquote (JSDOC.TextStream stream, JSDOC.TokenArray tokens);
		public bool read_hex (JSDOC.TextStream stream, JSDOC.TokenArray tokens);
		public bool read_mlcomment (JSDOC.TextStream stream, JSDOC.TokenArray tokens);
		public bool read_newline (JSDOC.TextStream stream, JSDOC.TokenArray tokens);
		public bool read_numb (JSDOC.TextStream stream, JSDOC.TokenArray tokens);
		public bool read_punc (JSDOC.TextStream stream, JSDOC.TokenArray tokens) throws JSDOC.TokenReader_Error;
		public bool read_regx (JSDOC.TextStream stream, JSDOC.TokenArray tokens);
		public bool read_slcomment (JSDOC.TextStream stream, JSDOC.TokenArray tokens);
		public bool read_snquote (JSDOC.TextStream stream, JSDOC.TokenArray tokens);
		public bool read_space (JSDOC.TextStream stream, JSDOC.TokenArray tokens);
		public bool read_word (JSDOC.TextStream stream, JSDOC.TokenArray tokens);
		public JSDOC.TokenArray tokenize (JSDOC.TextStream stream);
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public class TokenStream : GLib.Object {
		public int cursor;
		protected Gee.ArrayList<JSDOC.Token> tokens;
		public TokenStream (Gee.ArrayList<JSDOC.Token> tokens);
		public Gee.ArrayList<JSDOC.Token> balance (JSDOC.TokenName in_start) throws JSDOC.TokenStreamError;
		public void dump (int start, int end);
		public void dumpAll (string indent);
		public void dumpAllFlat ();
		public JSDOC.Token? getMatchingToken (JSDOC.TokenName start, int depth = 0);
		public JSDOC.Token? getMatchingTokenEnd (JSDOC.TokenName end);
		public JSDOC.Token? look (int n, bool considerWhitespace);
		public JSDOC.Token lookAny (int n);
		public int lookFor (string data);
		public JSDOC.Token lookTok (int n);
		public JSDOC.Token? next ();
		public Gee.ArrayList<JSDOC.Token>? nextM (int howMany) throws JSDOC.TokenStreamError;
		public JSDOC.Token? nextNonSpace ();
		public JSDOC.Token? nextTok ();
		public void printRange (int start, int end);
		public Gee.ArrayList<JSDOC.Token> remaining ();
		public void rewind ();
		public Gee.ArrayList<JSDOC.Token> toArray ();
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public enum ScopeParserMode {
		BUILDING_SYMBOL_TREE,
		PASS2_SYMBOL_TREE
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public enum TokenName {
		UNKNOWN_TOKEN,
		BREAK,
		CASE,
		CATCH,
		CONST,
		CONTINUE,
		DEFAULT,
		DELETE,
		DO,
		ELSE,
		FALSE,
		FINALLY,
		FOR,
		FUNCTION,
		IF,
		IN,
		INSTANCEOF,
		NEW,
		NULL,
		RETURN,
		SWITCH,
		THIS,
		THROW,
		TRUE,
		TRY,
		TYPEOF,
		VOID,
		WHILE,
		WITH,
		VAR,
		EVAL,
		NAME,
		MULTI_LINE_COMM,
		JSDOC,
		SINGLE_LINE_COMM,
		SEMICOLON,
		COMMA,
		HOOK,
		COLON,
		OR,
		AND,
		BITWISE_OR,
		BITWISE_XOR,
		BITWISE_AND,
		STRICT_EQ,
		EQ,
		ASSIGN,
		STRICT_NE,
		NE,
		LSH,
		LE,
		LT,
		URSH,
		RSH,
		GE,
		GT,
		INCREMENT,
		DECREMENT,
		PLUS,
		MINUS,
		MUL,
		DIV,
		MOD,
		NOT,
		BITWISE_NOT,
		DOT,
		LEFT_BRACE,
		RIGHT_BRACE,
		LEFT_CURLY,
		RIGHT_CURLY,
		LEFT_PAREN,
		RIGHT_PAREN,
		SPACE,
		NEWLINE,
		DOUBLE_QUOTE,
		SINGLE_QUOTE,
		OCTAL,
		DECIMAL,
		HEX_DEC,
		REGX,
		START_OF_STREAM,
		END_OF_STREAM,
		UNKNOWN
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public enum TokenType {
		TOKN,
		KEYW,
		NAME,
		COMM,
		PUNC,
		WHIT,
		STRN,
		NUMB,
		REGX,
		VOID
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public errordomain CompressWhiteError {
		BRACE
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public errordomain LangError {
		ArgumentError
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public errordomain PackerError {
		ArgumentError
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public errordomain TokenReader_Error {
		ArgumentError,
		SyntaxError
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public errordomain TokenStreamError {
		ArgumentError
	}
	[CCode (cheader_filename = "roojspacker.h")]
	public static JSDOC.Lang_Class Lang;
	[CCode (cheader_filename = "roojspacker.h")]
	public static int Scope_gid;
	[CCode (cheader_filename = "roojspacker.h")]
	public static string CompressWhite (JSDOC.TokenStream ts, JSDOC.Packer packer, bool keepWhite);
}
