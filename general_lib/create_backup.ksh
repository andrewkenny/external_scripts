
#
#This script is intended to create backups
#in a similar (if not identical) way that ipg 
#creates backups.
#
# current assumption:
#
# given "testplan" to backup:
# plan to copy to testplan.1~
# if testplan.1~ already exists, rename it to testplan.2~
# if testplan.2~ already exists, rename it to testplan.3~
# if testplan.$n~ already exists, rename it to testplan.$(n + 1)~
#

FILE_PATH=$1

#look for the first instance of a none existant backup file.
#if the maximum number is reached, it is removed, and presumed irelevent.
i=1

while [[ $i -le 255 ]] ; do
    
    if [[ ! -e "$FILE_PATH.$i~" ]]; then
    
        break
    fi
    

    i=$(expr $i + 1)
done

#as mentioned above, if it turns out that
#there are no spare backup files, the last one
#will be deleted.
if [[ $i -eq 256 ]]; then
    rm "$FILE_PATH.255~"
    i=255
fi

#then loop backwards from the discovered number
#creating the further backups.
OUTPUT_FILE="$FILE_PATH.$i~"
while [[ $i -ge 1 ]]; do
    NEW_FILE="$FILE_PATH.$i~"


    
    if [[ $i -eq 1 ]] ; then
        cp "debug/custom/temp/backup_file" "$NEW_FILE"
        rm "debug/custom/temp/backup_file"
    else
        OLD_FILE="$FILE_PATH.$(expr $i - 1)~"
        mv "$OLD_FILE" "$NEW_FILE"
    fi
    
    i=$(expr $i - 1)
done


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
