#!/bin/bash

# http://www.linuxquestions.org/questions/linux-software-2/bash-scripting-pipe-input-to-script-vs.-1-570945/
# potok może być zrealizowany dowolną funkcją, która oczekuje danych z potoku :)
potok_xargs()
{
	xargs -i echo "[ xargs ] {}"
}

potok_read()
{
	while read line; do
		echo "[ read ] $line"
	done 
}

reverse()
{
	INPUT="$1"
	for (( i =1 ; i <= $(wc -l < "$INPUT") ; i++ )) ; do
		tail -n $i "$INPUT" | head -n 1 
	done

}
# stan wejścia potoku
PIPE=$( readlink /proc/$$/fd/0 )

if readlink /proc/$$/fd/0 | grep -q "^pipe:"; then
  echo "Pipe input: $PIPE"
  potok_xargs
elif file $( readlink /proc/$$/fd/0 ) | grep -q "character special"; then
  echo "Standard input: $PIPE | $(file $(readlink /proc/$$/fd/0))"
  # dane z parametru
else
  echo "File input: < $PIPE"
  potok_read < $PIPE
fi
