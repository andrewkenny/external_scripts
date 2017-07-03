
FILE=$1

echo ""

LEARN_LINE_NO=$(grep -En "learn *capacitance *on" "$FILE" | cut -f1 '-d:')

head -n $(expr $LEARN_LINE_NO - 1) $FILE | \
grep -vE '^ *learn' | grep -vE "^ *test" | \
sed -e 's/^ *sub *Characterize/sub GP_Relay_Check (Status_Code, Message$)/'
echo '   print "not Implemented yet."'
sed 1,$(expr $LEARN_LINE_NO + 1)d "$FILE" | \
grep -vE '^ *learn' | grep -vE "^ *test" | \
sed -e 's/^ *sub *Characterize/sub GP_Relay_Check (Status_Code, Message$)/'


    