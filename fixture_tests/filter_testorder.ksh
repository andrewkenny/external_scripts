
#this ksh script is used to filter the testorder, 
#so that only tests that fall within the required board are printed.

#if REMOVE_COMMENTS is 1, then all comments are removed.

if [[ $# -eq 0 ]] ; then
   print "No Arguments have been passed" >&2
   exit
fi



START=$1
STOP=$2
REMOVE_TEST_COMMENTS=$3
REMOVE_TEST_FLAGS=$4





CORRECT_BOARD_FLAG=0


#remove duplicate spaces, along with preceding and proceding whitespace.
sed -e 's/  */ /g' -e 's/^  *//' -e 's/  *$//' -e 's/ *!/!/' 'testorder' | \
while read -r LINE ; do
    
    #if $START is 0, then we have a single board test,
    #and all lines are valid.
    #if not, $START and STOP have to match the previous
    #board numbers given in 'boards X to Y' lines.
    if [[ "$START" -eq 0 || "$LINE" == !* ]] ; then
        CORRECT_BOARD_FLAG=1
    else
        if [[ "$LINE" == boards* ]]
        then
            echo "$LINE" | grep -qE "^boards ${START} to ${STOP}$"
            if [ $? -eq 0 ] ; then
                CORRECT_BOARD_FLAG=1
            else
                CORRECT_BOARD_FLAG=0
            fi
        fi
    fi
    
    if [[ "$CORRECT_BOARD_FLAG" -eq 1 ]] ; then

        if [[ "$LINE" == !* || "$LINE" == boards* || "$LINE" == testplan* ]] ; then
            echo "$LINE"
        else
            #remove comments from end of testorder (if required to)
            if [[ "$REMOVE_TEST_COMMENTS" -eq 1 ]]
            then
                LINE="${LINE%%!*}"
            fi

            #remove restorder flags from testorder (if required to)
            if [[ "$REMOVE_TEST_COMMENTS" -eq 1 ]]
            then
                LINE="${LINE%%;*}"
            fi
            echo $LINE
            
        fi
    fi
    
done

