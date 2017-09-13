
EXTERNAL_PATH=$1

SCRIPT_PATH="$EXTERNAL_PATH/generate_test_list/generate_test_list.py"



if [[ ! -e "$SCRIPT_PATH" ]] ; then
    print "not implemented"

fi

if ! hash python 2>/dev/null ; then
    print "install python 3"
    print "(3.4 recomended)"
    print "to run this program"
    exit
fi



python "$SCRIPT_PATH" "$EXTERNAL_PATH"




