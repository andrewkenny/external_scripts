
if [[ $# -eq 0 ]];then
   print "No Arguments"
   exit
fi

sed '/! Node capacitively isolated\. *$/s/!\(.*\)/\1/' $1       | \
sed '/! Node resistively isolated\. *$/s/!\(.*\)/\1/'           | \
sed '/! Non-digital library pin\. *$/s/!\(.*\)/\1/'             | \
sed '/! Node is isolated *$/s/!\(.*\)/\1/'


