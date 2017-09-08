import re
import sys
import pathlib
import itertools

boards_re = re.compile(r"^boards (?P<Start>\d+) to (?P<Stop>\d+)")


test_re_pattern = r"""^(?P<Test_Status>test|skip)[ ]               #is test skipped?
                      (?P<Test_Type>[a-z ]+)[ ]                    #gets test type
                      "(?P<Test_Name>[^"]+)"                       #gets test name
                      ([ ]version[ ]"(?P<Version>[^"]+)")?         #extracts version (optional)
                  """
    
test_re   = re.compile(test_re_pattern, re.VERBOSE)

test_list_dir          = "debug/test_list.csv"
test_list_warnings_dir = "debug/test_list_warnings"

test_list_fmt = "{Test_Status},{Start},{Stop},{Test_Name},{Test_Path},{Test_Type},{Version}\n"

Start = 0
Stop  = 0
Test_Status = "test"
Test_Path   = "pins"
Test_Name   = "pins"
Test_Type   = "pins"
Version     = "V1"


class TestRange():
    def __init__(self, Test_Path, Start, Stop, Test_Name):
        self.Test_Path = Test_Path
        self.Start     = Start
        self.Stop      = Stop
        self.Test_Name = Test_Name
    
    
    #returns an iterator looping through the range of boards.
    def range(self):
        
        for board_num in range(self.Start, self.Stop + 1):
            yield board_num
    
    #gives the filename
    def File_Name(self, board_num):
        if board_num == 0:
            return self.Test_Name
        
        return "{0}%{1}".format(board_num,Test_Name)
    
    #returns the full path of a test (as a path object)
    #if the compile flag is passed, the filename of the
    #compiled object is returned.
    def Full_Path(self, board_num,compiled=False):
    
        Test_Path = pathlib.Path(self.Test_Path)
        
        Full_Path = Test_Path / self.File_Name(board_num)
    
        if not compiled:
            return Full_Path

        if Full_Path.is_file():
            return Test_Path / (self.File_Name(board_num) + ".o")
        else:
            return Full_Path / "test.o"
                
        

    #This generator yeilds all of the paths of a test.
    def Test_Path_Iterator(self, compiled=False):

        
        if self.Start == 0:
            yield self.Full_Path(Start,compiled)
        else:
            for board_num in self.range():
                yield self.Full_Path(board_num,compiled)
    
    
    #this function returns a list containing each board number
    #which is missing a test.    
    def check_for_missing_tests(self):
        
        missing_list = []
            
        for Full_Path in self.Test_Path_Iterator():
        
            if not Full_Path.exists():
                missing_list.append(board_num)
        
        return  missing_list

    
    #for each test in a range, yields 1 if a test is a file
    #and 0 if a test is a folder.
    def is_test_file(self):
        
        for Full_Path in self.Test_Path_Iterator():
            yield Full_Path.is_file()
    
    #returns a list of inodes for each relevent test_file.
    def get_test_inodes(self):
        
        
        if self.Full_Path(self.Start).is_file():
            Sub_Files = [""]
        else:
            Sub_Files = ["analog", "digital", "serial"]
    

        test_inode_list = []
        for Sub_File in Sub_Files:
            file_inode_list = set()
            for Full_Path in self.Test_Path_Iterator():
                try:
                    inode = (Full_Path / Sub_File).stat().st_ino
                except FileNotFoundError:
                    inode = 0
    
                file_inode_list.add(inode)
    
            test_inode_list.append(file_inode_list)
    
        return test_inode_list
    

            
            
     
    

#This function looks for the given test in the
#relevent folders, and returns a list of
#all locations the test is found in.
def file_lookup(Test_Name, Start, Stop, *, prepend=None):

    dir_list = set()
    
    #when prepend is None - we are in the base dir.
    #otherwise, we are in the version directory.
    
    if prepend is None:
        prepend = pathlib.Path(".")
    else:
        prepend = pathlib.Path(prepend)
    
    
    #loop through possible folders and the board range.
    folder_iter = (pathlib.Path(s) for s in [".", "analog","digital","mixed"])

    for i in range(int(Start), int(Stop) + 1):
        for subfolder in folder_iter:
            
            if i == 0:
                File_Name = Test_Name
            else:
                File_Name = "{}%{}".format(i,Test_Name)
        
            test_path =  prepend / subfolder / File_Name
            
            if test_path.exists():
                dir_list.add((prepend / subfolder).as_posix())
        
    return list(dir_list)



#This function looks within a job dir for the provided test name,
#checking in the test_version folder first (if it exists.)
#
#It is possible that the file being looked for exists twice.
#
#In this event, both paths will be returned.
#
#Equally, if the test cannot be found, an empty
#list will be returned.
def get_source_path(Test_Name, Version, Start, Stop):
    

    if Version is not None:
    
        dir_list = file_lookup(Test_Name, Start, Stop, prepend=Version)

        #return test directories if found.
        if dir_list:
            return dir_list
    
    #if Versions is None, or no tests in
    #version directory have been found, look though
    #the base tests.
    dir_list = file_lookup(Test_Name, Start, Stop)

    return dir_list



 

with open("testorder") as testorder, \
     open(test_list_dir,'w') as test_list, \
     open(test_list_warnings_dir,'w') as test_list_warnings:
    for line_no, raw_line in enumerate(testorder):
    
        #remove surrounding whitespace.
        line=raw_line.strip()
    
        if not line or line.startswith("!"):
            continue
    
        if "!" in line:
            line = re.sub('!.*','',line)
    
        #remove duplicate spaces
        if "  " in line:
            line = re.sub(r' +',' ',line)
    
        if line.startswith("boards"):
            range_extract = boards_re.search(line)
            Start = range_extract.group("Start")
            Stop  = range_extract.group("Stop")
            continue

        line_match = test_re.search(line)
        if line_match is None:
            print("Error Parsing the following line:\n")
            print("    {0}\n\n".format(raw_line))
            input("Press Enter to quit")
            sys.exit()
    
        Test_Status = line_match.group("Test_Status")
        Test_Type   = line_match.group("Test_Type")
        Test_Name   = line_match.group("Test_Name")
        Version     = line_match.group("Version")
    
        if " " in Test_Name:
            test_list_warning.write("\nSpace character found in test name on line {}\n".format(line_no))
            test_list_warning.write("Full line: \n")
            test_list_warning.write("    {0}\n\n".format(raw_line))
        
        #look for a test for each board in the range.
        Test_Path   = get_source_path(Test_Name, Version, Start, Stop)
        
        #if test is found, leave loop
        if not Test_Path:
            #write warning if test path not found.
            test_list_warnings.write("\nTest file or folder not found: '{}'\n".format(raw_line.strip()))
            continue
        
        
        if len(Test_Path) > 1:
            test_list_warnings.write("\nduplicate tests matching: '{}'\n".format(raw_line.strip()))
            test_list_warnings.write("found in folders:\n")
            for folder in Test_Path:
                test_list_warnings.write("    '{0}'\n".format(folder))
    
            continue

    
            
        Test_Corpus = TestRange(Test_Path[0], int(Start), int(Stop), Test_Name)
        
        #check for missing tests.
        missing_list = Test_Corpus.check_for_missing_tests()
        #print("missing list: ",missing_list)
        if missing_list:
            print("\n{} is cannot be found for the following boards:\n".format(Test_Corpus.Test_Name))
            for board_num in missing_list:
                print("    {}".format(board_num))
        
        
        file_flag_list = Test_Corpus.is_test_file()
        #print("file_flag list: ",list(Test_Corpus.is_test_file()))
        #a length of more than 1 means an inconsistency.
        if len(set(file_flag_list)) > 1:
            print("\nThe test files / folders for {} are inconsistant\n".format(Test_Corpus.Test_Name))
            
            #continue to prevent problems with later code.
            continue
    
        #check for broken links.
        file_inode_list = Test_Corpus.get_test_inodes()
        for inodes in file_inode_list:
            if len(inodes) > 1:
                #add error message code here
                print("\nA problem has been found with the linking of test: {}".format(Test_Corpus.Test_Name))
    

        #could also warn about the lack of a
        #.o / test.o for lines where the Test_Status is "test"
        #warn if testorder testtype differs from test contents.
        
    
        output_line = test_list_fmt.format(\
                      Test_Status=Test_Status,\
                      Start=Start,\
                      Stop=Stop,\
                      Test_Name=Test_Name,\
                      Test_Path=Test_Path[0],\
                      Test_Type=Test_Type,\
                      Version=Version or " ")
    
    
        test_list.write(output_line)


