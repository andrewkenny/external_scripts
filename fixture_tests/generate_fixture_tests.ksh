
EXTERNAL_PATH=$1

# the location of the variable tables.
TABLES_FOLDER_PATH='debug/custom/data/tables'

#get the delimiter of this project:
DELIMITER=$(ksh debug/custom/programs/guess_delimiter.ksh)

PINS_NAME='pins'
SHORTS_NAME='shorts'

TEMP_TESTORDER="debug/custom/temp/testorder"

#count the number of times the testorder is modified.
TESTORDER_MOD_COUNT=0

#get list of all the files in the tables folder,
ls $TABLES_FOLDER_PATH | \


while read TABLE_NAME
do

    #add the TABLES_PATH to the start of it,
    #to allow the files to be directly addressed.
    #double quotes are used to allow the TABLES_PATH
    #variable to be used.
    TABLE_PATH="$TABLES_FOLDER_PATH/$TABLE_NAME"
    
    START=$(cat $TABLE_PATH | sort -n  | head -1)
    STOP=$(cat $TABLE_PATH | sort -n | tail -1)
    #echo $START
    #echo $STOP

    if [[ $START -eq 0 ]] ; then
        PINS=$PINS_NAME
        SHORTS=$SHORTS_NAME    
    else
        PINS="$START$DELIMITER$PINS_NAME"
        SHORTS="$START$DELIMITER$SHORTS_NAME"
    fi
    

    
    if [[ ! -e "$PINS"_plate ]]; then
        ksh $EXTERNAL_PATH/fixture_tests/fixture_test_generators/generate_fixture_pins.ksh $PINS >  "$PINS"_plate
        
        #increment backup counter.
        TESTORDER_MOD_COUNT=$(expr $TESTORDER_MOD_COUNT + 1)
        
        cp testorder "testorder..${TESTORDER_MOD_COUNT}~"
        
        #create an entry in the testorder for this new test.
        ksh $EXTERNAL_PATH/fixture_tests/update_testorder.ksh \
        "$START" "$STOP" 'test pins "pins_plate"' 'test pins "pins"' > \
        $TEMP_TESTORDER
        cp $TEMP_TESTORDER "testorder"
    fi
    
    if [[ ! -e "$SHORTS"_plate ]]; then
        ksh $EXTERNAL_PATH/fixture_tests/fixture_test_generators/generate_fixture_shorts.ksh $SHORTS > "$SHORTS"_plate
    
        #increment backup counter.
        TESTORDER_MOD_COUNT=$(expr $TESTORDER_MOD_COUNT + 1)
        
        cp testorder "testorder..${TESTORDER_MOD_COUNT}~"
        
        #create an entry in the testorder for this new test.
        ksh $EXTERNAL_PATH/fixture_tests/update_testorder.ksh \
        "$START" "$STOP" 'test shorts "shorts_plate"' 'test shorts "shorts"' > \
        $TEMP_TESTORDER
        cp $TEMP_TESTORDER "testorder"
    fi
    
    if [[ $START -ne $STOP ]] ; then
    
        i=$(($START + "1"))
        while [[ $i -le $STOP ]] ; do
            
            #calculate the target files name
            PINSTARGET="$i$DELIMITER"pins_plate
            SHORTSTARGET="$i$DELIMITER"shorts_plate
            
            echo $PINSTARGET
            echo $SHORTSTARGET
            
            #remove them (if they already exist)
            rm -f $PINSTARGET
            rm -f $SHORTSTARGET
            
            ln "$PINS"_plate  $PINSTARGET    
            ln "$SHORTS"_plate  $SHORTSTARGET    
    
            i=$(expr $i + 1)
        done
        
    fi    
   
done



