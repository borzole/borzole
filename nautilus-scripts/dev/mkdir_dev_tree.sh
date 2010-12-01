#!/bin/bash

# make folders

cd "${NAUTILUS_SCRIPT_CURRENT_URI#file://}"

mkdir -p {lab,src,scrum,arch,class,doc,tmp}

# source code
#    -- lab: current project
#    -- src: waiting, not finished projects
#    -- scrum: proces-projects
#    -- arch: finished projects
#
#  class -- templates
#    doc -- documentation
#    tmp -- inbox
