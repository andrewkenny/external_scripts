
FILE=$1

echo ""
grep -vE '^ *learn' $FILE | grep -vE "^ *test"  | \
sed -e 's/^ *sub *Characterize/sub GP_Relay_Check (Status_Code, Message$)/' 

    