public static int main(string[] args) 
{
	//foreach(var a in args) {
	//	debug("ARG: %s\n", a);
	//}
	


	var pr = new JSDOC.PackerRun( );
	pr.parseArgs(args);
	pr.run();
	
	return 0;
}