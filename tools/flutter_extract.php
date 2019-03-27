<?php

// in flutter - an event is actually a property..?


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