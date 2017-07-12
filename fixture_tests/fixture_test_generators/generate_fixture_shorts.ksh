
if [[ $# -eq 0 ]];then
   print "No Arguments"
   exit
fi




#this script alters the **BASE** shorts test, to allow it
#to be used to test the fixture, when the blanking plate is fitted.

#The first step is to replace the first occurance of threshold
#with 'first_threshold 1000', This will prevent it from
#being removed later in the pipeline.
sed -e '1 s/^threshold *.*/first_threshold 1000/; t' -e '1,// s//first_threshold 1000/' $1| \


#The next step is to remove all of the thresholds,
#and settling delays.
grep -ve '^threshold' | grep -ve '^settling delay' | \


#The next step is to remove comments, and no access nodes.
grep -ve '! A node is not accessible *$' | \
grep -ve '! Node not accessible *$' | \
grep -ve '^!! Start of Section' | \


#then the short statements are removed.
grep -ve '^short  *"[^"]*"  *to  *"[^"]*"' | \


#finally, the first_threshold is replaced with threshold to make the test correct.
sed 's/first_threshold/threshold/' |uniq


