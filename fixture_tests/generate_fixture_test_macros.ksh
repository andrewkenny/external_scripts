
External_Path=$1

#remove the tempfiles (if they exist)
#that this script uses to prevent problems
#if they do.
TEMP_TESTPLAN='debug/custom/temp/testplan'



TESTPLAN_MOD_COUNT=0


#first create the fixture pins and fixture shorts macro.

sed 's/^if fnPinsfailed/if fnPins_platefailed/' 'debug/board/Testplan_Macros/Pins' > 'debug/board/Fixture_Check_Macros/Pins'

sed 's/^call Shorts/call Shorts_plate/' 'debug/board/Testplan_Macros/Shorts' > 'debug/board/Fixture_Check_Macros/Shorts'


#add the gp relay macro.
sed 's/^call Pre_Shorts/call GP_Relay_Check/' 'debug/board/Testplan_Macros/Preshorts' >  'debug/board/Fixture_Check_Macros/Fixture_Relays'

#add the fixture electronics macro
sed 's/^call Pre_Shorts/call Fixture_Electronics/' 'debug/board/Testplan_Macros/Preshorts' >  'debug/board/Fixture_Check_Macros/Fixture_Electronics'

#second create a new menu.

echo 'Pins'            > 'debug/board/Fixture_Check_Macros/menu'
echo 'P'              >> 'debug/board/Fixture_Check_Macros/menu'
echo 'Shorts'         >> 'debug/board/Fixture_Check_Macros/menu'
echo 'S'              >> 'debug/board/Fixture_Check_Macros/menu'
echo 'Fixture Relays' >> 'debug/board/Fixture_Check_Macros/menu'
echo 'R'              >> 'debug/board/Fixture_Check_Macros/menu'
echo 'Fixture Electronics' >> 'debug/board/Fixture_Check_Macros/menu'
echo 'E'              >> 'debug/board/Fixture_Check_Macros/menu'
echo ''               >> 'debug/board/Fixture_Check_Macros/menu'

#init flags


#check the testplan for the shorts_plate subroutine.
#if the Shorts plate sub already exists,
#there is no need to create it.
grep -qE '^ *sub *Shorts_plate' 'testplan'
if [[ $? -ne 0 ]] ; then

    TESTPLAN_MOD_COUNT=$(expr $TESTPLAN_MOD_COUNT + 1)
    cp testplan "testplan..${TESTPLAN_MOD_COUNT}~"
    
    #modify the subroutine (1) with arguments (2) direct output to (3)
    ksh $External_Path/fixture_tests/add_modified_subroutine.ksh \
    'testplan' '^ *sub *Shorts *'  '^ *subend' "$External_Path/fixture_tests/testplan_modifiers/sub_shorts_plate_modifier.ksh" 'shorts_plate"'\
    > $TEMP_TESTPLAN
    cp $TEMP_TESTPLAN testplan
fi


#check the testplan for the pins_plate.
#if the pins_plate function already exists,
#there is no need to create it.
grep -qE '^ *def *fn *Pins_platefailed' $POST_SHORTS_PROCESS
if [[ $? -ne 0 ]] ; then

    TESTPLAN_MOD_COUNT=$(expr $TESTPLAN_MOD_COUNT + 1)
    cp testplan "testplan..${TESTPLAN_MOD_COUNT}~"
 
   #modify the subroutine (1) with arguments (2) direct output to (3)
   ksh $External_Path/fixture_tests/add_modified_subroutine.ksh \
   "$POST_SHORTS_PROCESS" '^ *def *fn *Pinsfailed'  '^ *fnend' "$External_Path/fixture_tests/testplan_modifiers/sub_pins_plate_modifier.ksh" 'pins_plate"'\
    > $TEMP_TESTPLAN
    cp $TEMP_TESTPLAN testplan
   
fi


#check the testplan for the GP_Relay_Check.
#if the GP_Relay_Check sub already exists,
#there is no need to create it.
grep -qE '^ *sub *GP_Relay_Check' $POST_SHORTS_PROCESS
if [[ $? -ne 0 ]] ; then

    TESTPLAN_MOD_COUNT=$(expr $TESTPLAN_MOD_COUNT + 1)
    cp testplan "testplan..${TESTPLAN_MOD_COUNT}~"
 
   #modify the subroutine (1) with arguments (2) direct output to (3)
   ksh $External_Path/fixture_tests/add_modified_subroutine.ksh \
   "$POST_PINS_PROCESS" '^ *sub *Characterize'  '^ *subend' "$External_Path/fixture_tests/testplan_modifiers/sub_gp_relay_modifier.ksh" 'execute'\
    > $TEMP_TESTPLAN
    cp $TEMP_TESTPLAN testplan
fi

#check the testplan for the FIXTURE_ELECTRONICS.
#if the FIXTURE_ELECTRONICS sub already exists,
#there is no need to create it.
grep -qE '^ *sub *Fixture_Electronics' $POST_GP_PROCESS
if [[ $? -ne 0 ]] ; then

    TESTPLAN_MOD_COUNT=$(expr $TESTPLAN_MOD_COUNT + 1)
    cp testplan "testplan..${TESTPLAN_MOD_COUNT}~"
 
   #modify the subroutine (1) with arguments (2) direct output to (3)
   ksh $External_Path/fixture_tests/add_modified_subroutine.ksh \
   "$POST_GP_PROCESS" '^ *sub *Characterize'  '^ *subend' "$External_Path/fixture_tests/testplan_modifiers/sub_fix_electronics_modifier.ksh" 'execute'\
    > $TEMP_TESTPLAN
    cp $TEMP_TESTPLAN testplan
fi


