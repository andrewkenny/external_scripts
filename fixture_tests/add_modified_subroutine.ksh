
#
# This ksh script takes the following arguments:
# TESTPLAN_PATH - The Path of the testplan containing the source subroutine.
# SOURCE_START  - The line that indicates the start of the source subroutine.
# SOURCE_END    - The line that indicates the end of the source subroutine.
# MODIFIER_KSH  - The script that modifies the source subroutine.

TESTPLAN_PATH=$1
SOURCE_START=$2
SOURCE_END=$3   
MODIFIER_KSH=$4

TEMP_FILE='debug/custom/temp/modified_subroutine'

#find the line number where source subroutine is.
SUB_SOURCE_START=$(grep -En $SOURCE_START $TESTPLAN_PATH | cut -f1 '-d:')

#echo all of the testplan up to the start of source subroutine.
head -n $(expr $SUB_SOURCE_START - 1) $TESTPLAN_PATH

#find out how long the source subroutine is
SUB_SOURCE_LEN=$(sed 1,$(expr $SUB_SOURCE_START - 1)d $TESTPLAN_PATH | grep -En $SOURCE_END | cut -f1 '-d:' | head -n 1)

#calculate the line number of the end of the source subroutine.
SUB_SOURCE_END=$((SUB_SOURCE_START+SUB_SOURCE_LEN))

#echo the source subroutine while storing the text to the file at $TEMP_FILE
sed 1,$(expr $SUB_SOURCE_START - 1)d $TESTPLAN_PATH 2> /dev/null | head -n $SUB_SOURCE_LEN | tee $TEMP_FILE


#re-insert the shorts subroutine, modified to test the fixture shorts.
ksh $MODIFIER_KSH $TEMP_FILE

#add the testplan text which comes after the sub shorts.
sed 1,$(expr $SUB_SOURCE_END - 1)d $TESTPLAN_PATH


