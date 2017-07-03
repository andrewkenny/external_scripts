
External_Path=$1

#remove the tempfiles (if they exist)
#that this script uses to prevent problems
#if they do.
SUB_SHORTS_PLATE='debug/custom/temp/shorts_plate'
rm -f $SUB_SHORTS_PLATE

SUB_PINS_PLATE='debug/custom/temp/pins_plate'
rm -f $SUB_PINS_PLATE

POST_SHORTS_PROCESS='debug/custom/temp/testplan~1'
rm -f $POST_SHORTS_PROCESS

POST_PINS_PROCESS='debug/custom/temp/testplan~2'
rm -f $POST_PINS_PROCESS

#first create the fixture pins and fixture shorts macro.

sed 's/^if fnPinsfailed/if fnPins_platefailed/' 'debug/board/Testplan_Macros/Pins' > 'debug/board/Fixture_Check_Macros/Pins'

sed 's/^call Shorts/call Shorts_plate/' 'debug/board/Testplan_Macros/Shorts' > 'debug/board/Fixture_Check_Macros/Shorts'


#add the gp relay setup.
echo print \"not implemented yet\" >  'debug/board/Fixture_Check_Macros/Fixture_Relays'


#second create a new menu.

echo 'Pins'            > 'debug/board/Fixture_Check_Macros/menu'
echo 'P'              >> 'debug/board/Fixture_Check_Macros/menu'
echo 'Shorts'         >> 'debug/board/Fixture_Check_Macros/menu'
echo 'S'              >> 'debug/board/Fixture_Check_Macros/menu'
echo 'Fixture Relays' >> 'debug/board/Fixture_Check_Macros/menu'

#init flags


#check the testplan for the shorts_plate subroutine.
grep -qE '^ *sub *Shorts_plate' 'testplan'

#if the Shorts plate sub already exists,
#there is no need to create it.
if [[ $? -ne 0 ]] ; then

   #modify the subroutine (1) with arguments (2) direct output to (3)
   ksh $External_Path/fixture_tests/add_modified_subroutine.ksh \
   'testplan' '^ *sub *Shorts *'  '^ *subend' "$External_Path/fixture_tests/sub_shorts_plate_modifier.ksh" 'shorts_plate"'\
   > $POST_SHORTS_PROCESS
  
else
    #even if the shorts_plate isnt being added,
    #the testplan must be moved to $POST_SHORTS_PROCESS 
    #so that other operations can be applied to it.
    cp testplan $POST_SHORTS_PROCESS   

fi




#check the testplan for the pins_plate.
grep -qE '^ *def *fn *Pins_platefailed' $POST_SHORTS_PROCESS

#if the Shorts plate sub already exists,
#there is no need to create it.
if [[ $? -ne 0 ]] ; then
   
   #modify the subroutine (1) with arguments (2) direct output to (3)
   ksh $External_Path/fixture_tests/add_modified_subroutine.ksh \
   "$POST_SHORTS_PROCESS" '^ *def *fn *Pinsfailed'  '^ *fnend' "$External_Path/fixture_tests/sub_pins_plate_modifier.ksh" 'pins_plate"'\
   > $POST_PINS_PROCESS
   
   
else
    #even if the shorts_plate isnt being added,
    #the testplan must be moved to $POST_SHORTS_PROCESS 
    #so that other operations can be applied to it.
    cp $POST_SHORTS_PROCESS $POST_PINS_PROCESS   

fi

#create backup of testplan.
cat testplan > testplan.bak

#copy new testplan over current testplan.
cp $POST_PINS_PROCESS testplan

#remove temp files (if not removed already)

rm -f $SUB_SHORTS_PLATE
rm -f $SUB_PINS_PLATE
rm -f $POST_SHORTS_PROCESS
rm -f $POST_PINS_PROCESS
