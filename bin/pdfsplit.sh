#!/bin/bash

# pdfsplit.sh - extract each page of a PDF into a separate file
# http://linuxgazette.net/180/grebler.html

myname=`basename $0`
# ------------------------------------------------------------------------------
Usage(){
	cat <<EOF
Usage: $myname file.pdf
Output: goes to /tmp/page_n.pdf
EOF
	exit
}
#----------------------------------------------------------------------#
Die(){
	echo $myname: $* >&2
	exit 1
}
#----------------------------------------------------------------------#
[ $# -eq 1 ] || Usage

pages=`pdfinfo $1 | grep Pages | awk '{print $2}'`
[ "$pages" = '' ] && Die "No pages found. Perhaps $1 is not a pdf."
[ "$pages" -eq 1 ] && Die "Only 1 page in $1. Nothing to do."

jj=1
while [ $jj -le $pages ] ; do
	gs -dSAFER -sDEVICE=pdfwrite -dNOPAUSE -dBATCH \
		-dFirstPage=$jj -dLastPage=$jj \
		-sOutputFile=/tmp/page_$jj.pdf $1
	jj=`expr $jj + 1`
done
