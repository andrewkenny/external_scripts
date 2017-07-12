
FILE=$1

echo ""
grep -vE 'shorts_plate"' $FILE | \
sed -e 's/^ *sub *Shorts/sub Shorts_plate/' \
    -e '/^ *test /s/shorts"/shorts_plate"/'
    