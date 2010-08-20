#!/bin/bash

# dziwaczny INI parser w bash, raczej ciekawostka

# Check if TMPDIR is set, default to /tmp
#~ : ${SRC:=~/.rss}

cfg.parser(){
	# And then you can parse your ini files as following:

	# parse the config file called 'myfile.ini', with the following
	# contents::
	#   [sec2]
	#   var2='something'
	# $ cfg.parser 'myfile.ini'

	# enable section called 'sec2' (in the file [sec2]) for reading
	# $ cfg.section.sec2

	# read the content of the variable called 'var2' (in the file
	# var2=XXX). If your var2 is an array, then you can use
	# ${var[index]}
	# $ echo "$var2"

    IFS=$'\n' && ini=( $(<$1) )              # convert to line-array
    ini=( ${ini[*]//;*/} )                   # remove comments
    ini=( ${ini[*]/#[/\}$'\n'cfg.section.} ) # set section prefix
    ini=( ${ini[*]/%]/ \(} )                 # convert text2function (1)
    ini=( ${ini[*]/=/=\( } )                 # convert item to array
    ini=( ${ini[*]/%/ \)} )                  # close array parenthesis
    ini=( ${ini[*]/%\( \)/\(\) \{} )         # convert text2function (2)
    ini=( ${ini[*]/%\} \)/\}} )              # remove extra parenthesis
    ini[0]=''                                # remove first element
    ini[${#ini[*]} + 1]='}'                  # add the last brace
    eval "$(echo "${ini[*]}")"               # eval the result
}
cfg.writer(){
	# And the example of use:
	# cfg.parser sample.ini
	# cfg.write > sample_copy.ini
    IFS=' '$'\n'
    fun="$(declare -F)"
    fun="${fun//declare -f/}"
    for f in $fun; do
        [ "${f#cfg.section}" == "${f}" ] && continue
        item="$(declare -f ${f})"
        item="${item##*\{}"
        item="${item%\}}"
        item="${item//=*;/}"
		vars="${item//=*/}"
		eval $f
		echo "[${f#cfg.section.}]"
		for var in $vars; do
			echo $var=\"${!var}\"
		done
	done
}
