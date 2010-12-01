#!/bin/bash

# make folders

cd "${NAUTILUS_SCRIPT_CURRENT_URI#file://}"

mkdir -p /{lab,src,arch,class,doc,tmp}

# README:
# arch, src, lab -- source code
#                -- lab: current project
#                -- src: waiting, not finished projects
#                -- arch: finished projects
#          class -- templates
#            doc -- documentation
#            tmp -- inbox
