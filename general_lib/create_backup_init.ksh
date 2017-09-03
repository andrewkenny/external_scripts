
#this script is called at the start of another script if there is a change
#that the file to be "backed up" may change.
#
#if the file does not change, then no further backup script needs calling.
#if the file does change, then create_backup.ksh should be called.




FILE_PATH=$1

cp $FILE_PATH "debug/custom/temp/backup_file"

echo "debug/custom/temp/backup_file"
