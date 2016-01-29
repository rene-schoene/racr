#!/bin/bash

# This program and the accompanying materials are made available under the
# terms of the MIT license (X11 license) which accompanies this distribution.

# author: C. Bürger

################################################################################################################ Parse arguments:
while getopts s:d:i:m: opt
do
	case $opt in
		s)	selected_system="$OPTARG";;
		d)	diagram="$OPTARG";;
		i)	input="$OPTARG";;
		m)	mode="$OPTARG";;
		?)
			echo "Usage: -s Scheme system (by default larceny)"
			echo "       -d Activity diagram"
			echo "       -i Activity diagram input"
			echo "       -m Mode (1=parsing, 2=AD-well-formedness, 3=PN-generation, 4=PN-well-formedness"
			echo "                5=PN-execution (no enabled passes), 6=PN-execution (use enabled passes))"
			exit 2
	esac
done
shift $(( OPTIND - 1 ))

if [ -z "$selected_system" ]
then
	selected_system="larceny"
fi

if [ -z "$diagram" ]
then
	echo " !!! ERROR: No activity diagram to interpret given !!!" >&2
	exit 2
fi

if [ -z "$input" ]
then
	input=":false:"
fi

if [ -z "$mode" ]
then
	mode=5
else if (( "$mode" < 1 || "$mode" > 6 ))
then
	echo " !!! ERROR: No valid mode selected !!!" >&2
	exit 2
fi fi

############################################################################### Configure temporary resources & execution script:
old_pwd=`pwd`

my_exit(){
	cd $old_pwd
	rm script.scm	
	exit 0
}
trap 'my_exit' 1 2 3 9 15

echo "#!r6rs" > script.scm
echo "(import (rnrs) (ttc-2015-fuml-activity-diagrams user-interface))" >> script.scm
echo "(define diagram (cadr (command-line)))" >> script.scm
echo "(define input (caddr (command-line)))" >> script.scm
echo "(define mode (cadddr (command-line)))" >> script.scm
echo '(set! input (if (string=? input ":false:") #f input))' >> script.scm
echo '(set! mode (string->number mode))' >> script.scm
echo "(run-activity-diagram diagram input mode)" >> script.scm

####################################################################################################### Execute activity diagram:
../../run-program.bash -s "$selected_system" -e script.scm "$diagram" "$input" "$mode"
my_exit
