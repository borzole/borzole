#!/bin/bash

abs_path="$(readlink -f `dirname $0`)"
cd "$abs_path"

# ------------------------------------------------------------------------------
# make folders
# ------------------------------------------------------------------------------

depth=1
find "$abs_path" -mindepth $depth -maxdepth $depth -type d -exec \
	mkdir -p '{}'/{lab,src,arch,class,doc,tmp} \;


# README:
# arch, src, lab -- source code
#                -- lab: current project
#                -- src: waiting, not finished projects
#                -- arch: finished projects
#          class -- templates
#            doc -- documentation
#            tmp -- inbox
