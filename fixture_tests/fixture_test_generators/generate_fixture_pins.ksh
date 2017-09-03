
if [[ $# -eq 0 ]];then
   print "No Arguments"
   exit
fi
PINS_FNAME=$1

#get the first line of the test.
IFS='' read -r FIRSTLINE < "$PINS_FNAME"

#print the first line.
echo "$FIRSTLINE"

#remove duplicate spaces, along with preceding and proceding whitespace.
sed -e 's/  */ /g' -e 's/^  *//' -e 's/  *$//' $PINS_FNAME |  \

#remove the ! before the commented out pins line.
sed -e '/! Node capacitively isolated\. *$/s/^!\(.*\)/\1/' | \
sed -e '/! Node resistively isolated\. *$/s/^!\(.*\)/\1/'  | \
sed -e '/! Non-digital library pin\. *$/s/^!\(.*\)/\1/'    | \
sed -e '/! Node is isolated *$/s/^!\(.*\)/\1/'             | \

#remove the irrelevent ipg comments from the pins test.
sed -e 's/ *! Node capacitively isolated\..*//' | \
sed -e 's/ *! Node resistively isolated\..*//'  | \
sed -e 's/ *! Non-digital library pin\..*//'    | \
sed -e 's/ *! Node is isolated.*//'             | \

#remove irrelevent lines
grep -ve '^!!!! 16 0 1 [0-9][0-9]*'       | \
grep -vE '! Not accessible$' | \
grep -vE '^!IPG' | \

grep .

echo '!!!!!!!!!!!!!!!!!!!!!!!'
echo '!nodes with no access.!'
echo '!!!!!!!!!!!!!!!!!!!!!!!'
sed -e 's/  */ /g' -e 's/^  *//' -e 's/  *$//' $PINS_FNAME | \
grep -E '! Not accessible$' 

