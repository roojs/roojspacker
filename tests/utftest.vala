


 
 
    public static int main (string[] args) {
        
         string filename = "/tmp/data.txt";

        // Writing
        string content = "hello, worl d简体 繁體";
        FileUtils.set_contents (filename, content);

        // Reading
        string read;
        FileUtils.get_contents (filename, out read);

        stdout.printf ("The content of file '%s' is:\n%s\n", filename, read);
 
        
        return 0;
    }