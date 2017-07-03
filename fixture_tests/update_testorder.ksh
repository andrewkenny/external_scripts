

#given a $START, a $STOP, and a $TEST_NAME and a $SENTINAL (insert test above $SENTINAL)
#this script will add the given test to the testorder before the $SENTINAL line.

START=$1
STOP=$2
TEST_NAME=$3
SENTINAL=$4


#is the test already in the testorder?
ksh debug/custom/programs/filter_testorder.ksh $START $STOP 1 |  \
    grep -E "^ *test" | grep -Fq "\"$TEST_NAME\""
#if the entry can be found,
#exit script
if [[ $? -eq 0 ]] ; then
    exit
fi





