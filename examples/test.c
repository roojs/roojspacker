/**
 * simple test to see if we can call the shared library from C...
 *
 * compile:
 *
 * gcc test.c `pkg-config --cflags --libs roojspacker-1.0 ` -o /tmp/test
 *
 * /tmp/test  myjavascriptfile.js
 *
 */

#include <stdio.h>
#include <glib.h>
#include <roojspacker.h>
int main(int argc, char *argv[]) {
    
    JSDOCPacker* packer;
    char* out;
    packer = jsdoc_packer_new ("", "");
    jsdoc_packer_loadFile(packer, argv[1]);
    out = jsdoc_packer_pack(packer);
    printf("RESULT: %s", out );

    return 0;
}