

#given a $START, a $STOP, and a $TEST_NAME and a $SENTINAL (insert test above $SENTINAL)
#this script will add the given test to the testorder before the $SENTINAL line.

#Any lines which require 'read' parsing, will be passed to the following file:
PARSE_TEMP='debug/custom/temp/parse_file'
NO_COMMENTS=1
NO_FLAGS=1

EXTERNAL_PATH=$1
TEST_START=$2
TEST_STOP=$3
TEST_NAME=$4
SENTINAL=$5



#the default value for $START and $STOP
#is 0 and 0
START=0
STOP=0

#get the first line of the test.
IFS='' read -r FIRSTLINE < 'testorder'

#print the first line.
echo "$FIRSTLINE"

cat 'testorder' |  \
#remove duplicate spaces, along with preceding and proceding whitespace.
sed -e 's/  */ /g' -e 's/^  *//' -e 's/  *$//'| \

#remove the now incorrect header.
grep -ve '!!!! 14 0 1' | \

while IFS= read -r LINE ; do
    if [[ "$LINE" == boards* ]] ; then
        #get the new START and STOP variables.
        echo "$LINE" | sed -e 's/^boards *//' -e 's/  *to  */,/' > $PARSE_TEMP
        IFS=',' read START STOP < $PARSE_TEMP
        rm -f "$PARSE_TEMP"

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








