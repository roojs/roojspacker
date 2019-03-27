<?php

// in flutter - an event is actually a property..?

// we have 2 types of data - the overall summary, and the 'detail one we use for docs..
//

class  Prop {
    var $name = '';
    var $type = '';
    var $desc = '';
    var $memberOf = '';
}

class  Method {  // doubles up for events? - normally 'on' is the name
    var $name = '';
    var $type = ''; // return...
    var $desc = '';
    var $static = false;
    var $memberOf = '';
    var $sig = '';
    var $args  = array();
}

class Cls {
    var $name;
    var $extends;
    var $events = array();
    var $methods = array();
    var $props = array();
}
class Param {
    var $name = '';
    var $type = '';
    var $desc = '';
    var $isOptional = true;
}



$fdir = '/home/alan/Downloads/flutterdocs/flutter/';
$js = json_decode(file_get_contents($fdir.'index.json'));
print_r($js);exit;