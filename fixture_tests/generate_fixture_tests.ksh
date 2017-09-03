
EXTERNAL_PATH="$1"

# the location of the variable tables.
TABLES_FOLDER_PATH='debug/custom/data/tables'

#get the delimiter of this project:
DELIMITER=$(ksh "debug/custom/programs/guess_delimiter.ksh")

PINS_NAME='pins'
SHORTS_NAME='shorts'

TEMP_TESTORDER="debug/custom/temp/testorder"

#ensure there are no comments or flags in the "filter_testorder.ksh" output.
NO_COMMENTS=1
NO_FLAGS=1

#create backup of testorder.
#outputs the name of the newly created file.
TEMP_BACKUP=$(ksh "$EXTERNAL_PATH/general_lib/create_backup_init.ksh" "testorder")

TESTORDER_UPDATED='debug/custom/temp/testorder_changed'
#initialise a default updated value of 0
echo 0 > "$TESTORDER_UPDATED"

#get list of all the files in the tables folder,
ls $TABLES_FOLDER_PATH | \


while read TABLE_NAME
do

    #add the TABLES_PATH to the start of it,
    #to allow the files to be directly addressed.
    #double quotes are used to allow the TABLES_PATH
    #variable to be used.
    TABLE_PATH="$TABLES_FOLDER_PATH/$TABLE_NAME"
    
    START=$(cat "$TABLE_PATH" | sort -n  | head -1)
    STOP=$(cat "$TABLE_PATH" | sort -n | tail -1)
    #echo $START
    #echo $STOP

    if [[ $START -eq 0 ]] ; then
        PINS="$PINS_NAME"
        SHORTS="$SHORTS_NAME"   
    else
        PINS="$START$DELIMITER$PINS_NAME"
        SHORTS="$START$DELIMITER$SHORTS_NAME"
    fi
    

    
    if [[ ! -e "$PINS"_plate ]]; then
        ksh $EXTERNAL_PATH/fixture_tests/fixture_test_generators/generate_fixture_pins.ksh $PINS >  "$PINS"_plate
    fi
    
    
    #is the test already in the testorder?
    ksh "$EXTERNAL_PATH/fixture_tests/filter_testorder.ksh" "$START" "$STOP" "$NO_COMMENTS" "$NO_FLAGS" |
    grep -E "^(test |skip )" | grep -Fq "\"pins_plate\""
    
    #if it cannot be found..
    if [[ "$?" -ne 0 ]] ; then
    
        #create an entry in the testorder for this new test.
        ksh $EXTERNAL_PATH/fixture_tests/update_testorder.ksh \
        "$EXTERNAL_PATH" \
        "$START" "$STOP" 'test pins "pins_plate"' 'test pins "pins"' > \
        $TEMP_TESTORDER
        cp $TEMP_TESTORDER "testorder"
        
        #describe that the testorder has been changed.
        echo 1 > $TESTORDER_UPDATED
    fi

    
    if [[ ! -e "$SHORTS"_plate ]]; then
        ksh $EXTERNAL_PATH/fixture_tests/fixture_test_generators/generate_fixture_shorts.ksh $SHORTS > "$SHORTS"_plate
    fi
    
    #is the test already in the testorder?
    ksh "$EXTERNAL_PATH/fixture_tests/filter_testorder.ksh" "$START" "$STOP" "$NO_COMMENTS" "$NO_FLAGS" |
    grep -E "^(test |skip )" | grep -Fq "\"shorts_plate\""
    
    #if it cannot be found..
    if [[ $? -ne 0 ]] ; then
        #create an entry in the testorder for this new test.
        ksh $EXTERNAL_PATH/fixture_tests/update_testorder.ksh \
        "$EXTERNAL_PATH" \
        "$START" "$STOP" 'test shorts "shorts_plate"' 'test shorts "shorts"' > \
        "$TEMP_TESTORDER"
        cp "$TEMP_TESTORDER" "testorder"
        #describe that the testorder has been changed.
        echo 1 > "$TESTORDER_UPDATED"
    fi

    
    if [[ $START -ne $STOP ]] ; then
    
        i="$START"
        while [[ $i -le $STOP ]] ; do
            
            #calculate the target files name
            PINSTARGET="$i$DELIMITER"pins_plate
            SHORTSTARGET="$i$DELIMITER"shorts_plate
            
            echo "$PINSTARGET"    >> "debug/custom/temp/fixture_pins"
            #base test - no versions
            echo " "              >> "debug/custom/temp/fixture_pins"
            echo "$SHORTSTARGET"  >> "debug/custom/temp/fixture_shorts"
            #base test - no versions
            echo " "              >> "debug/custom/temp/fixture_shorts"
            
            if [[ $i -ne $START ]] ; then
            
                #remove them (if they already exist)
                rm -f "$PINSTARGET"
                rm -f "$SHORTSTARGET"
                
                ln "$PINS"_plate  "$PINSTARGET"
                ln "$SHORTS"_plate  "$SHORTSTARGET"
            fi                
    
            i=$(expr $i + 1)
        done
        cat "debug/custom/temp/fixture_pins" "debug/custom/temp/fixture_shorts" > "debug/custom/temp/fixture_tests"
        rm -f "debug/custom/temp/fixture_pins"
        rm -f "debug/custom/temp/fixture_shorts"
    else
        echo "pins_plate"
        echo " "
        echo "shorts_plate"
        echo " "
    fi    
   
done


#if the testorder has been changed, the file will contain a 1.
#in this situation, a backup is created.
TESTORDER_UPDATED_FLAG=$(cat "$TESTORDER_UPDATED")
if [[ $TESTORDER_UPDATED_FLAG -eq 1 ]]; then

    ksh "$EXTERNAL_PATH/general_lib/create_backup.ksh" "testorder"
fi

#cleanup temp files
rm -f $TESTORDER_UPDATED
rm -f $TEMP_TESTORDER
rm -f $TEMP_BACKUP



