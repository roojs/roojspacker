//<script type="text/javscript">

 

/**
	@constructor
*/
namespace JSDOC {
    
    public class TextStreamChar : Object {
        public char c;
        public bool eof;
        public TextStreamChar(char val, bool eof=false) {
            this.c = val;
            this.eof = eof;
        }
    }
    
    public class TextStream : Object {
        
        string text;
        int cursor;
        int length;
        
        public TextStream (string text = "")
        {
            
            
            this.text = text;
            this.length = text.length; // text.char_count();
            this.cursor = 0;
        }
        
        public char look(int n = 0)
        {
                 
            if (this.cursor+n < 0 || this.cursor+n >= this.length) {
                return '\0';
            }
            return this.text[this.cursor+n]; // this.text.get_char(this.cursor+n);
        }
        
        public bool lookEOF(int n = 0)
        {
            if (this.cursor+n < 0 || this.cursor+n >= this.length) {
                return true;
            }
            return  false;
        }
        
        /**
         * @param n - number of characters to return..
         */
        public string next(int n = 1)
        {
            
            if (n < 1) { //?? eof???
                return "\0";
            }
                
            string pulled = "";
            var i = 0;
            while (i < n) {
                if (this.cursor+i < this.length) {
                    var add = this.text[this.cursor+i]; //this.text.get_char(this.cursor+i).to_string();
                    pulled += add.to_string();
                    i += 1;// add.length;
                } else {
                    return "";
                    
                }
            }
            
            this.cursor += pulled.length;
            return pulled;
           
        }
    }
}