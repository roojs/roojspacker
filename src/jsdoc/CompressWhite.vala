 
/**
 * 
 * pack a javascript file, and return a shorter version!
 * 
 * a bit picky at present with ; and crlf reading...
 * @arg ts {TokenStream} 
   @arg packer {Packer} 
 */
namespace JSDOC 
{
	public errordomain CompressWhiteError {
            BRACE
    }
	 
	public string CompressWhite (TokenStream ts, Packer packer, bool keepWhite) // throws CompressWhiteError,TokenStreamError
	{
		//keepWhite = keepWhite || false;
		ts.rewind();
		//ts.dumpAllFlat(); GLib.Process.exit(1);
		
		//var str = File.read(fn);
		var rep_var = 1;
	
	
	
		while (true) {
			var tok = ts.next();
			if (tok == null) {
			    break;
			}
			if (tok.type == TokenType.WHIT) {
			   
			    continue;
			    //if (tok._isDoc) {
			    //    continue;
			    //}
			    // just spaces, not \n!
			    //if (tok.data.indexOf("\n") < 0) {
			    //    continue;
			   // }
			    
			    
			}
			if (tok.data == "}")  {
			    
			    if (ts.lookTok(0).type == TokenType.NAME && ts.look(1,true).name == TokenName.NEWLINE) {
			        ts.look(0,true).outData = ts.look(0,true).data+"\n";
			    }
			    // restore.. 
			    
			    continue;
			}
			// add semi-colon's where linebreaks are used... - not foolproof yet.!
			if (tok.type == TokenType.NAME)  {
			    //var tokident = ts.look(-1).data + tok.data + ts.look(1).data +  ts.look(2).data;
			    // a = new function() {} 
			    if (ts.lookTok(1).data == "=" && ts.lookTok(2).name == TokenName.NEW  && 
			        ts.lookTok(3).name == TokenName.FUNCTION) {
			        // freeze time.. 
			        var cu = ts.cursor;
			        
			        ts.balance(TokenName.LEFT_PAREN); //"(");
			        
			        
			        ts.balance(TokenName.LEFT_CURLY); //"{");
			        // if next is not ';' -> make it so...
			        
			        if (ts.lookTok(1).data != ";"  && ts.lookTok(1).data != "}" && ts.lookTok(1).name == TokenName.NEWLINE) {
			            ts.look(0,true).outData = ts.lookTok(0).data +";";
			        }
			        // restore.. 
			        ts.cursor = cu;
			        continue;
			    }
			    // a = function() { ... -- add a semi colon a tthe end if not one there..
			       
			    if (ts.lookTok(1).data == "=" &&  ts.lookTok(2).name == TokenName.FUNCTION) {
			        // freeze time.. 
			        //println("got = function() ");
			        tok = ts.nextTok();
			        tok = ts.nextTok();
			        
			        //tok = ts.next();
			         var cu = ts.cursor;
					//print("NEXT = should be brac: %s\n", ts.lookTok(1).asString());
					  
			       //print("cursor = %d", ts.cursor);
			          
			        if (ts.lookTok(1).data != "(" || ts.balance(TokenName.LEFT_PAREN /*"("*/).size < 1 ){
			    		print("balance ( issue on line %d\n", ts.toArray().get(cu).line);
			            ts.dump(cu-40, cu+2);
			            print(">>>>>>>>>>>>>>>>>HERE>>>>>>>>>>>>");
			            ts.dump(cu+2, cu+40);
			            
			            throw new CompressWhiteError.BRACE( "could not find end lbrace!!!" );
			        }
			        //print("cursor = %d", ts.cursor);
			        //print("CUR = should be ): %s\n", ts.lookTok(0).asString());

			        tok = ts.nextTok();
			        //print("CUR = should be {: %s\n", ts.lookTok(0).asString());			        
			        cu = ts.cursor; // set the cursor to here.. so the next bit of the code will check inside the method.
			        
			        //print("cursor = %d", ts.cursor);
			       // print("AFTER BALANCE (");
			        //ts.dump(cu, ts.cursor);
			        
			        
			        ts.cursor--; // cursor at the (
			        if (tok.data != "{" || ts.balance(TokenName.LEFT_CURLY /*"("*/).size < 1 ){

			            ts.dump(cu-40, cu);
			            print(">>>>>>>>>>>>>>>>>HERE>>>>>>>>>>>>");
			            ts.dump(cu, cu+40);
			            
			            throw new CompressWhiteError.BRACE( "could not find end lbrace!!!");
			        }
			        //print('FN: '+ts.tokens[cu].toString());
			        //print('F1: '+ts.lookTok(1).toString());
			        //print('F2: '+ts.look(1,true).toString());
			        
			        // if next is not ';' -> make it so...
			        // although this var a=function(){},v,c; causes 
			        if (ts.lookTok(1).data != ";" && ts.lookTok(1).data != "}" && ts.look(1,true).name == TokenName.NEWLINE) {
			            
			            ts.look(0,true).outData = ts.look(0,true).data+";";
			           // print("ADDING SEMI: " + ts.look(0).toString());
			            //ts.dump(cu, ts.cursor+2);
			        }
			        
			         //ts.dump(cu, ts.cursor+2);
			        // restore.. 
			        ts.cursor = cu;
			        continue;
			    }
			    // next item is a name..
			    if ((ts.lookTok(1).type == TokenType.NAME || ts.lookTok(1).type == TokenType.KEYW ) 
						&&  ts.look(1,true).name == TokenName.NEWLINE) {
			        // preserve linebraek
			        ts.look(0,true).outData = ts.look(0,true).data+"\n";
			    }
			    // method call followed by name..
			    if (ts.lookTok(1).data == "(")  {
			        var cu = ts.cursor;
			        
			         ts.balance(TokenName.LEFT_PAREN); //"(");
			         // although this var a=function(){},v,c; causes 
			        
			        if (ts.lookTok(1).type == TokenType.NAME && ts.look(1,true).name == TokenName.NEWLINE) {
			        
			            ts.look(0,true).outData = ts.look(0,true).data+"\n";
			        }
			        // restore.. 
			        ts.cursor = cu;
			        continue;
			    }
			    
			    
			    // function a () { ... };
			        /*
			    if (ts.look(-1).isTypeN(Script.TOKfunction) &&  ts.look(1).isTypeN(Script.TOKlparen)) {
			        // freeze time.. 
			        //println("got = function() ");
			        var cu = ts.cursor;
			        
			        ts.balance("lparen");
			        ts.balance("lbrace");
			        // if next is not ';' -> make it so...
			        // although this var a=function(){},v,c; causes 
			        if (!ts.look(1).isData(';') && !ts.look(1).isData('}') && ts.look(1,true).isLineBreak()) {
			            ts.cur().outData = ts.cur().data+";";
			        }
			        // restore.. 
			        ts.cursor = cu;
			        continue;
			    }
			    */
			    
			    // a = { ....
			        
			    if (ts.lookTok(1).data == "=" &&  ts.lookTok(2).data == "{") {
			        // freeze time.. 
			        //println("----------*** 3 *** --------------");
			        var cu = ts.cursor;
			        ;
			        if (ts.balance(TokenName.LEFT_CURLY /*"{" */).size < 1 ){

			            ts.dump(cu-40, cu);
			            print(">>>>>>>>>>>>>>>>>HERE>>>>>>>>>>>>");
			            ts.dump(cu, cu+40);
			            
			            throw new CompressWhiteError.BRACE("could not find end lbrace!!!");
			        }
			        // if next is not ';' -> make it so...
			        
			        if (ts.lookTok(1).data != ";" && ts.lookTok(1).data != "}" && ts.look(1,true).name==TokenName.NEWLINE) {
			            ts.look(0,true).outData = ts.look(0,true).data +";";
			        }
			        // restore.. 
			        ts.cursor = cu;
			        continue;
			    }
			    
			    // any more??
			    // a = function(....) { } 
			  
			}
			
			
			
			 
			//println("got Token: " + tok.type);
			
			
			
			switch(tok.name) {
			    // things that need space appending
			    case TokenName.FUNCTION:
			    case TokenName.BREAK:
			    case TokenName.CONTINUE:
			        // if next item is a identifier..
			        if (ts.lookTok(1).type == TokenType.NAME || Regex.match_simple("^[a-z]+$", ts.lookTok(1).data, GLib.RegexCompileFlags.CASELESS) ) { // as include is a keyword for us!!
			           tok.outData =  tok.data + " ";
			        }
			        continue;
			        
			        
			    case TokenName.RETURN: // if next item is not a semi; (or }
			        if (ts.lookTok(1).data == ";" || ts.lookTok(1).data == "}") {
			            continue;
			        }
			        tok.outData =  tok.data + " ";
			        
			        continue;
			    
			        
			    case TokenName.ELSE: // if next item is not a semi; (or }
			        if (ts.lookTok(1).name != TokenName.IF) {
			            continue;
			        }
			        // add a space if next element is 'IF'
			        tok.outData =  tok.data + " ";
			        continue;
			    
			    case TokenName.INCREMENT: //"++": // if previous was a plus or next is a + add a space..
			    case TokenName.DECREMENT: //"--": // if previous was a - or next is a - add a space..
			    
			        var p = (tok.data == "--" ? "-" : "+"); 
			    
			        if (ts.lookTok(1).data == p) {
			            tok.outData =  tok.data + " ";
			        }
			        if (ts.lookTok(-1).data == p) {
			            tok.outData =  " " +  tok.data;
			            
			        }
			        continue;
			    
			    case TokenName.IN: // before and after?? 
			    case TokenName.INSTANCEOF:
			        
			        tok.outData = " " + tok.data + " ";
			        continue;
			    
			    case TokenName.VAR: // always after..
			    case TokenName.NEW:
			    case TokenName.DELETE:
			    case TokenName.THROW:
			    case TokenName.CASE:
			    case TokenName.CONST:
			    case TokenName.VOID:
			        tok.outData =  tok.data + " ";
			        
			        continue;
			        
			    case TokenName.TYPEOF: // what about typeof(
			        if (ts.lookTok(1).data != "(") {
			            tok.outData =  tok.data + " ";
			        }
			        continue;
			     case TokenName.SEMICOLON: //";":
			        //remove semicolon before brace -- 
			        //if(ts.look(1).isTypeN(Script.TOKrbrace)) {
			        //    tok.outData = '';
			       // }
			        continue;
			   
			    default:
			        continue;
			}
		}
	
		ts.rewind();
	
		// NOW OUTPUT THE THING.
		//var f = new File(minfile, File.NEW);
	
		var outstr = "";
		var outoff = 0;
		//try { out.length = ts.slen; } catch (e) {} // prealloc.
	

		Token tok;
		while (true) {
			
			tok = keepWhite ? ts.next() : ts.nextTok();
			
			if (tok == null) {
			    break;
			}
			if (tok.type == TokenType.COMM) {
			    tok.outData = "\n";
			}
			
			///print(tok.type + ':' + tok.data);
			
			if (tok.type == TokenType.NAME  &&
				 tok.identifier != null  &&
			    tok.identifier.mungedValue.length > 0) {
			    //f.write(tok.identifier.mungedValue);
			    //print("MUNGED: " + tok.identifier.mungedValue);
			    outstr += tok.identifier.mungedValue;
			    continue;
			}
			
			// at this point we can apply a text translation kit...
			// NOT SUPPORTED..
			//if ((tok.type == "STRN") && (tok.name== "DOUBLE_QUOTE")) {
			//    if (packer && packer.stringHandler) {
			//        outstr += packer.stringHandler(tok);
			//        continue;
			//    }
			//}
		 
			outstr += tok.outData != "" ? tok.outData : tok.data;
			
			if ((tok.name == TokenName.SEMICOLON || tok.name == TokenName.RIGHT_CURLY) && (outstr.length - outoff > 255)) {
			    outoff = outstr.length;
			    outstr += "\n";
			}
		}
		//f.close();
		/*
		// remove the last ';' !!!
		if (out.substring(out.length-1) == ';') {
			return out.substring(0,out.length-1);
		   }
		*/
		return outstr;
	
	}
	 
}