

#Any lines which require 'read' parsing, will be passed to the following file:
PARSE_TEMP='debug/custom/temp/parse_file'
TEST_LIST_DIR='debug/test_list'
START=0
STOP=0
TEST_STATUS='test'
TEST_NAME='pins'

#remove the old TEST_LIST_DIR
rm -f "$TEST_LIST_DIR"

#remove duplicate spaces, along with preceding and proceding whitespace.
#also removes comments.
grep -ve '^!' 'testorder' | grep '.' | \

sed -e 's/!.*$//' -e 's/  */ /g' -e 's/^  *//' -e 's/  *$//'  | \



#loop through the testorder.
while read -r LINE ; do
    if [[ "$LINE" == boards* ]] ; then
        #get the new START and STOP variables.
        echo "$LINE" | sed -e 's/^boards *//' -e 's/  *to  */,/' > $PARSE_TEMP
        IFS=',' read START STOP < $PARSE_TEMP
    else
        #get the first element (skip / test) from the testorder line.
        TEST_STATUS="$(echo $LINE | cut -d' ' -f1)" # ;echo "\"$TEST_NAME\""
        
        #get the test name from the testorder (assumed to be the text
        #in the first set of quotes.
        TEST_NAME="$(echo $LINE | cut -d\" -f2)" # ;echo "\"$TEST_NAME\""

        
        #gets the test type from the testorder line.
        TEST_TYPE="$(echo ${LINE#* } | cut -d\" -f1 | sed -e 's/ *$//')" # ;echo "\"$TEST_TYPE\""

        #silent grep to see if the line contains a version statement.
        echo $LINE | grep -q 'version "[^"]*"'
        
        #extract the version is the line exists,
        #else set to ' '
        if [[ $? -eq 0 ]] ; then
            VERSION="$(echo $LINE | sed -e 's/.*version \"//' -e 's/".*//')"
        else
            VERSION=' '
        fi
        
        echo "$TEST_STATUS,$START,$STOP,$TEST_NAME,$TEST_TYPE,$VERSION"
        
    
    fi

done
