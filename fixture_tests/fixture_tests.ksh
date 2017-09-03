
#This script is the top level script which is called by the
#"generate fixture_Tests" macro.

EXTERNAL_PATH=$1

#add the fixture test macros to the job.
ksh $EXTERNAL_PATH/fixture_tests/generate_fixture_test_macros.ksh   "$EXTERNAL_PATH"


#generate the actual fixture_Tests.
#also prints the potentially generated
#fixture tests for the calling bt basic script to compile.
#considered complete.
ksh $EXTERNAL_PATH/fixture_tests/generate_fixture_tests.ksh   "$EXTERNAL_PATH" 
    
   

