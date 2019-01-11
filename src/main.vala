public static int main(string[] args) 
{
	//foreach(var a in args) {
	//	debug("ARG: %s\n", a);
	//}
	


	var pr =   JSDOC.PackerRun.singleton( );
	pr.parseArgs(args);
	pr.runPack();
	
	return 0;
}