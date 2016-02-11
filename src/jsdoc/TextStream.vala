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
            //stdout.printf ("%s", text);
            this.length = text.length; // text.char_count(); //text.length;
            this.cursor = 0;
        }
        
        public string look(int n = 0)
        {
                 
            if (this.cursor+n < 0 || this.cursor+n >= this.length) {
                return "";
            }
            return  this.text.get_char(this.cursor+n).to_string(); // this.text[this.cursor+n]; // 
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
        public string nextS(int n = 1)
        {
            
            if (n < 1) { //?? eof???
                return "";
            }
                
            string pulled = "";
            var i = 0;
            while (i < n) {
                if (this.cursor+i < this.length) {
                    var add =  this.text.get_char(this.cursor+i).to_string(); 
                    pulled += add;
                    i += 1;// add.length;
                } else {
                    return "";
                    
                }
            }
            
            this.cursor +=  pulled.length; // i?
            return pulled;
           
        }
        
        public char nextC()
        {
            
            if (this.cursor+1 < this.length) {
				this.cursor++;
                return this.text[this.cursor];;
            } 
            return '\0';;
           
        }
        
        
    }
}