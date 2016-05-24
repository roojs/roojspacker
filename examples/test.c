/**
 * simple test to see if we can call the shared library from C...
 *
 * compile:
 *
 * PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig" gcc test.c `pkg-config --cflags --libs roojspacker ` -o test
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