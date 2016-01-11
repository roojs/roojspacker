#!/bin/sh


# - this is a bit dependant on checkout locations being correct...

# check 'roojs-core'

# this is the seed version.
 
cd ../../roojs1/
seed ../gnome.introspection-doc-generator/pack.js \
     -f buildSDK/dependancy_core.txt -o /tmp/js-roojs-core.js -O /tmp/js-roojs-core-debug.js

src/roojspacker -i /home/alan/gitlive/roojs1/buildSDK/dependancy_core.txt -t /tmp/pk-roojs-core.js -T /tmp/pk-roojs-core-debug.js -b /home/alan/gitlive/roojs1



# Testing a single file..


src/roojspacker -w -f /home/alan/gitlive/roojs1/Roo.js  -t /tmp/pk-roojs.js -b /home/alan/gitlive/roojs1 > /tmp/test.txt

seed ../gnome.introspection-doc-generator/pack.js -k   -o /tmp/js-roojs.js  ../roojs1/Roo.js  > /tmp/test2.txt


src/roojspacker -w -f /home/alan/gitlive/roojs1/Roo/Number.js  -t /tmp/pk-roojs.js -b /home/alan/gitlive/roojs1 > /tmp/test.txt

seed ../gnome.introspection-doc-generator/pack.js -k   -o /tmp/js-roojs.js  ../roojs1/Roo/Number.js  > /tmp/test2.txt



# seed ../gnome.introspection-doc-generator/pack.js \
#     -f buildSDK/dependancy_ui.txt -o roojs-ui.js -O roojs-ui-debug.js


