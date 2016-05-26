<?php 

dl('roojspacker.so');
$p = new roojspacker();

$p->loadFile("/home/alan/gitlive/roojs1/Function.js");
echo $p->pack();

