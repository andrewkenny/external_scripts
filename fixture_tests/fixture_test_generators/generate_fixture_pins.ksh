
if [[ $# -eq 0 ]];then
   print "No Arguments"
   exit
fi
PINS_FNAME=$1

#remove duplicate spaces, along with preceding and proceding whitespace.
sed -e 's/  */ /g' -e 's/^  *//' -e 's/  *$//' $PINS_FNAME |  \

sed -e '/! Node capacitively isolated\. *$/s/^!\(.*\)/\1/' | \
sed -e '/! Node resistively isolated\. *$/s/^!\(.*\)/\1/'  | \
sed -e '/! Non-digital library pin\. *$/s/^!\(.*\)/\1/'    | \
sed -e '/! Node is isolated *$/s/^!\(.*\)/\1/'             | \
grep -vE '! Not accessible$' | grep .

echo '!!!!!!!!!!!!!!!!!!!!!!!'
echo '!nodes with no access.!'
echo '!!!!!!!!!!!!!!!!!!!!!!!'
sed -e 's/  */ /g' -e 's/^  *//' -e 's/  *$//' $PINS_FNAME | \
grep -E '! Not accessible$' 

