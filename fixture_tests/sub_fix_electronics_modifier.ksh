
FILE=$1

echo ""

LEARN_LINE_NO=$(grep -En "learn *capacitance *on" "$FILE" | cut -f1 '-d:')

#print the data leading up to "learn capacitance on
head -n $(expr $LEARN_LINE_NO - 1) $FILE | \
grep -vE '^ *learn' | grep -vE "^ *test" | \
sed -e 's/^ *sub *Characterize/sub Fixture_Electronics (Status_Code, Message$)/'

#print any tests to be called,
#just placeholder for now
echo '   print "not Implemented yet."'

#print the rest of the file.
sed 1,$(expr $LEARN_LINE_NO + 1)d "$FILE" | \
grep -vE '^ *learn' | grep -vE "^ *test" | \
sed -e 's/^ *sub *Characterize/sub Fixture_Electronics (Status_Code, Message$)/'


    