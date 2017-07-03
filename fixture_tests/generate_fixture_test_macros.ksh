
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
   
   #find the line number where sub shorts starts.
   SUB_SHORTS_START=$(grep -En '^ *sub *Shorts *' 'testplan' | cut -f1 '-d:')

   #add all of the testplan up to the start of sub shorts to 
   head -n $(expr $SUB_SHORTS_START - 1) 'testplan' > $POST_SHORTS_PROCESS

   #find out how long the shorts subroutine is
   SUB_SHORTS_LEN=$(sed 1,$(expr $SUB_SHORTS_START - 1)d 'testplan' | grep -En '^ *subend' | cut -f1 '-d:' | head -n 1)

   #calculate the line number of the end of the shorts subroutine.
   SUB_SHORTS_END=$((SUB_SHORTS_START+SUB_SHORTS_LEN))
   
   #add the sub shorts to the testplan while storing the text to 
   #the file $SUB_SHORTS_PLATE
   sed 1,$(expr $SUB_SHORTS_START - 1)d 'testplan' 2> /dev/null | head -n $SUB_SHORTS_LEN | tee $SUB_SHORTS_PLATE >> $POST_SHORTS_PROCESS

   
   #re-insert the shorts subroutine, modified to test the fixture shorts.
   echo "" >> $POST_SHORTS_PROCESS
   sed -e 's/^ *sub *Shorts/sub Shorts_plate/' -e '/^ *test /s/shorts"/shorts_plate"/' $SUB_SHORTS_PLATE >> $POST_SHORTS_PROCESS
   #echo "" >> $POST_SHORTS_PROCESS
   
   #add the testplan text which comes after the sub shorts.
   sed 1,$(expr $SUB_SHORTS_END - 1)d 'testplan' >> $POST_SHORTS_PROCESS
   
   
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
   
   #find the line number where sub shorts starts.
   SUB_PINS_START=$(grep -En '^ *def *fn *Pinsfailed' $POST_SHORTS_PROCESS | cut -f1 '-d:')

   #add all of the testplan up to the start of fn Pinsfailed to 
   head -n $(expr $SUB_PINS_START - 1) $POST_SHORTS_PROCESS > $POST_PINS_PROCESS

   #find out how long the pins function is
   SUB_PINS_LEN=$(sed 1,$(expr $SUB_PINS_START - 1)d $POST_SHORTS_PROCESS | grep -En '^ *fnend' | cut -f1 '-d:' | head -n 1)

   #calculate the line number of the end of the pins function.
   SUB_SHORTS_END=$((SUB_PINS_START+SUB_PINS_LEN))
   
   #add the fn Pinsfailed to the testplan while storing the text to 
   #the file $SUB_PINS_PLATE
   sed 1,$(expr $SUB_PINS_START - 1)d $POST_SHORTS_PROCESS 2> /dev/null | head -n $SUB_PINS_LEN | tee $SUB_PINS_PLATE >> $POST_PINS_PROCESS

   
   #re-insert the shorts subroutine, modified to test the fixture shorts.
   echo "" >> $POST_PINS_PROCESS
   sed -e 's/^ *def *fn *Pinsfailed/def fnPins_platefailed/' -e '/^ *test /s/pins"/pins_plate"/' $SUB_PINS_PLATE >> $POST_PINS_PROCESS
   #echo "" >> $POST_PINS_PROCESS
   
   #add the testplan text which comes after the sub shorts.
   sed 1,$(expr $SUB_SHORTS_END - 1)d $POST_SHORTS_PROCESS >> $POST_PINS_PROCESS
   
   
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
