<?php 

dl('roojspacker.so');


$p = new roojspacker();
// add files to pack
$p->loadFile("/home/alan/gitlive/roojs1/Function.js");
// arguments are output filename/debug version filename (empty strings = return output)
echo $p->pack("","");

