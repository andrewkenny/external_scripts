
#
# This ksh script takes the following arguments:
# SOURCE_START  - The line that indicates the start of the source subroutine.
# SOURCE_END    - The line that indicates the end of the source subroutine.
# MODIFIER_KSH  - The script that modifies the source subroutine.
# SUB_LINE_SKIP - A Regex that describes lines to remove from the source subroutine


SOURCE_START=$1
SOURCE_END=$2 
MODIFIER_KSH=$3
SUB_LINE_SKIP=$4

TEMP_FILE='debug/custom/temp/modified_subroutine'
set -o noglob


#find the line number where source subroutine is.
SUB_SOURCE_START=$(grep -En "$SOURCE_START" 'testplan' | cut -f1 '-d:')
#echo $SUB_SOURCE_START > 'debug/custom/temp/start'

#echo all of the testplan up to the start of source subroutine.
head -n $(expr $SUB_SOURCE_START - 1) 'testplan'

#find out how long the source subroutine is
SUB_SOURCE_LEN=$(sed 1,$(expr $SUB_SOURCE_START - 1)d 'testplan' | grep -En "$SOURCE_END" | cut -f1 '-d:' | head -n 1)
#echo $SUB_SOURCE_LEN > 'debug/custom/temp/len'

#calculate the line number of the end of the source subroutine.
SUB_SOURCE_END=$((SUB_SOURCE_START+SUB_SOURCE_LEN))
#echo $SUB_SOURCE_END > 'debug/custom/temp/end'

#echo the source subroutine while storing the text to the file at $TEMP_FILE
sed 1,$(expr $SUB_SOURCE_START - 1)d 'testplan' 2> /dev/null | \
head -n "$SUB_SOURCE_LEN" | tee "$TEMP_FILE" | \
grep -vE "$SUB_LINE_SKIP"


#re-insert the shorts subroutine, modified to test the fixture shorts.
ksh "$MODIFIER_KSH" "$TEMP_FILE"

#add the testplan text which comes after the sub shorts.
sed 1,$(expr $SUB_SOURCE_END - 1)d 'testplan'

set +o noglob

rm -f $TEMP_FILE
