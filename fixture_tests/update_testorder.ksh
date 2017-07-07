

#given a $START, a $STOP, and a $TEST_NAME and a $SENTINAL (insert test above $SENTINAL)
#this script will add the given test to the testorder before the $SENTINAL line.

#Any lines which require 'read' parsing, will be passed to the following file:
PARSE_TEMP='debug/custom/temp/parse_file'
NO_COMMENTS=1
NO_FLAGS=1

#TEST_START=$1
#TEST_STOP=$2
#TEST_NAME=$3
#SENTINAL=$4

TEST_START="1"
TEST_STOP="10"
TEST_NAME='test pins "pins_plate"'
SENTINAL='test pins "pins"'


#is the test already in the testorder?
ksh debug/custom/programs/filter_testorder.ksh "$START" "$STOP" "$NO_COMMENTS" "$NO_FLAGS" |
     
    grep -E "^(test |skip )" | grep -Fq "$TEST_NAME"
    
    
#if the entry can be found,
#cat the testorder,
#exit the script
if [[ $? -eq 0 ]] ; then

    #remove duplicate spaces, along with preceding and proceding whitespace.
    sed -e 's/  */ /g' -e 's/^  *//' -e 's/  *$//' 'testorder'
    exit
fi

#the default value for $START and $STOP
#is 0 and 0
START=0
STOP=0



cat 'testorder' |  \
#remove duplicate spaces, along with preceding and proceding whitespace.
sed -e 's/  */ /g' -e 's/^  *//' -e 's/  *$//'| \

while IFS= read -r LINE ; do
    if [[ "$LINE" == boards* ]] ; then
        #get the new START and STOP variables.
        echo "$LINE" | sed -e 's/^boards *//' -e 's/  *to  */,/' > $PARSE_TEMP
        IFS=',' read START STOP < $PARSE_TEMP

    fi
    
    if [[ "$LINE" == !* || "$LINE" == boards* || "$LINE" == testplan* || \
                          "$START" -ne "$TEST_START" || "$STOP" -ne "$TEST_STOP" ]] ; then
        echo $LINE
    else

        if [[ "${LINE%%;*}" == "$SENTINAL" ]] ; then
            echo "$TEST_NAME"
            echo "$LINE"
        else
            echo "$LINE"
        fi
        

    fi

done








