
FILE=$1

echo ""
grep -vE 'pins_plate"' $FILE | \
sed -e 's/^ *def *fn *Pinsfailed/def fnPins_platefailed/' \
    -e '/^ *test /s/pins"/pins_plate"/'
    