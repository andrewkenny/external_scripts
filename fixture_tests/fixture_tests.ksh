
#This script is the top level script which is called by the
#"generate fixture_Tests" macro.

External_Path=$1

#add the fixture test macros to the job.
ksh $EXTERNAL_PATH/fixture_tests/generate_fixture_test_macros.ksh   "$External_Path"


#generate the actual fixture_Tests.
ksh $EXTERNAL_PATH/fixture_tests/generate_fixture_tests.ksh   "$External_Path"

