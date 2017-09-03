
if [[ $# -eq 0 ]];then
   print "No Arguments"
   exit
fi

SHORTS_FNAME=$1


#this script alters the **BASE** shorts test, to allow it
#to be used to test the fixture, when the blanking plate is fitted.

#get the first line of the test.
IFS='' read -r FIRSTLINE < "$SHORTS_FNAME"

#print the first line.
echo "$FIRSTLINE"

#The main step step is to replace the first occurance of threshold
#with 'first_threshold 1000', This will prevent it from
#being removed later in the pipeline.
sed -e '1 s/^threshold *.*/first_threshold 1000/; t' -e '1,// s//first_threshold 1000/' $SHORTS_FNAME | \


#The next step is to remove all of the thresholds,
#and settling delays.
grep -ve '^threshold' | grep -ve '^settling delay' | \

sed -e 's/  */ /g' -e 's/^  *//' -e 's/  *$//' | \


#The next step is to remove comments, and no access nodes.
#also removing the test header.
grep -ve '^!!!! 9 0 1 [0-9][0-9]*'       | \
grep -ve '! A node is not accessible *$' | \
grep -ve '! Node not accessible *$' | \
grep -ve '^!! Start of Section' | \
grep -ve '^!IPG' | \
grep . | \

#then the short statements are removed.
grep -ve '^short "[^"]*" to "[^"]*"' | \


#finally, the first_threshold is replaced with threshold to make the test correct.
sed 's/first_threshold/threshold/' |uniq


