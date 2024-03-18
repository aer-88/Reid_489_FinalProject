# Step 1: Import necessary libraries
import sys
from PyQt5.QtWidgets import QApplication, QMainWindow
from PyQt5 import uic
import pandas as pd

# Step 2: Define a class for the GUI
class GUI(QMainWindow):
    def __init__(self):
        super(GUI, self).__init__()
        uic.loadUi('design.ui', self)  # Load the design file
        # Connect buttons to methods
        self.loadFileButton.clicked.connect(self.load_file)
        self.runAnalysisButton.clicked.connect(self.run_analysis)
        self.chooseOutputButton.clicked.connect(self.choose_output)

    def load_file(self):
        # Method to load the file
        pass

    def run_analysis(self):
        # Method to run the chosen analysis
        pass

    def choose_output(self):
        # Method to choose the form of output
        pass

# Step 3: Define a class for the Street Centerline Quality Check
class StreetCenterlineQualityCheck:
    def __init__(self, file):
        self.file = file

    def sort_streets(self):
        # Method to sort the streets by name and address range

        pass

    def check_overlaps(self):
        # Method to check for overlaps
        pass

    def check_gaps(self):
        # Method to check for gaps
        pass

    def check_nulls(self):
        # Method to check for nulls
        pass

    def check_broken_polarity(self):
        # Method to check for broken polarity
        pass

    def produce_output(self):
        # Method to produce an Excel file or fgdb table of the results
        pass

# Step 4: Main function to run the GUI
def main():
    app = QApplication(sys.argv)
    gui = GUI()
    gui.show()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()

'''
##################
Steps from VB Script:
- set data types
- set error messages

Functions:
- Open File 
- Write File: takes a file path (strPath) and an array of strings (strFileData) as parameters. that writes an array of strings to a text. file The file is then closed.
- SortStrArray: takes an array of strings (strArray) as a parameter. It sorts the elements of the strArray in ascending order using a simple bubble sort algorithm. The sorted array is modified in place.
- SortRFArray: takes an array of custom data structures (udtArray) called StrtData as a parameter. It sorts the elements of the udtArray based on the intRF_Add ("Right From Address") field of each StrtData structure. The sorting is done in ascending order using a bubble sort algorithm.
- #// no_dup: removes duplicates from a string array.
- #// is_even: checks if an integer value is even.

- Run: performs a series of operations using the data from the file.
  1. The code starts with the declaration of variables that will be used throughout the subroutine. These variables include strFile, strWFile, strWriteFile, udtFile, strStreets, udtCurStrt, udtErrStrt, udtTempStrt, and several counter variables (i, j, k, e).
  2. The user is prompted to input the path and file name of the input text file (strFile) and the output text file (strWFile).
  3. The OpenFile function is called, passing the strFile variable as an argument. This function reads the contents of the input text file and returns an array of StrtData structures (udtFile).
  4. The code initializes an array (strStreets) to store unique street names extracted from the udtFile array.
  5. A loop iterates through each element in the udtFile array, excluding the header row. If the address of the street segment is greater than 0, the street name is added to the strStreets array.
  6. The SortStrArray function is called to sort the strStreets array in alphabetical order.
  7. The NoDup function is called to remove duplicate street names from the strStreets array.
  8. Another loop iterates through each street name in the strStreets array.
  9. Inside this loop, a new array (udtCurStrt) is initialized to store all the street segments for the current street.
  10. Another loop iterates through the udtFile array to collect each segment for the current street.
  11. The SortRFArray function is called to sort the udtCurStrt array by the "Right From" address.
  12. If there is more than one street segment in the udtCurStrt array, the code proceeds to check for errors.
  13. A temporary street segment (udtTempStrt) is initialized to store the last street segment for comparison.
  14. Another loop iterates through all the street segments in the udtCurStrt array and compares them for three types of errors: Flow, Overlap, and Gap.
  15. If a flow error is detected (i.e., the flow of addresses is inconsistent between segments), the error details are added to the udtErrStrt array.
  16. If an overlap error is detected (i.e., the address ranges of segments overlap), the error details are added to the udtErrStrt array.
  17. The code includes commented-out code for checking gap errors (i.e., address gaps between segments), but it is currently disabled.
  18. After checking all the street segments, the code builds an output text array (strWriteFile) that will be written to the output text file.
  19. The error details from the udtErrStrt array are added to the strWriteFile array.
  20. Finally, the WriteFile function is called to write the contents of the strWriteFile array to the output text file specified by strWFile.

'''
# for reference only
# arcpy.management.ApplySymbologyFromLayer(
#     in_layer="Projects",
#     in_symbology_layer="Projects_GDB",
#     symbology_fields="VALUE_FIELD projectofficialname projectofficialname",
#     update_symbology="MAINTAIN"
# )

def sort_str_array(str_array):
    # Returns a sorted (ascending) string array
    for i in range(len(str_array)):
        for j in range(i, len(str_array)):
            if str_array[i] > str_array[j]:
                str_array[i], str_array[j] = str_array[j], str_array[i]

def sort_rf_array(udt_array):
    # Returns a sorted (ascending) StrtData array using the Right From Address field
    for i in range(len(udt_array)):
        for j in range(i, len(udt_array)):
            if udt_array[i].intRF_Add > udt_array[j].intRF_Add:
                udt_array[i], udt_array[j] = udt_array[j], udt_array[i]

'''
Good Code
'''
def no_dup(strList):
    # Returns a list that contains no duplicates
    clean_street_list = []
    
    for string in strList:
        if string not in clean_street_list:
            clean_street_list.append(string)
    
    return clean_street_list

def is_even(int_val):
    # Returns True if the value is an even integer, False if it is odd
    return int_val % 2 == 0
# may not need this? 
class street_data_class:
    def __init__(self, lngID, strPrefix, strName, strType, strSuffix, strLabel, intLF_Add, intLT_Add, intRF_Add, intRT_Add):
        self.lngID = lngID
        self.strPrefix = strPrefix
        self.strName = strName
        self.strType = strType
        self.strSuffix = strSuffix
        self.strLabel = strLabel
        self.intLF_Add = intLF_Add
        self.intLT_Add = intLT_Add
        self.intRF_Add = intRF_Add
        self.intRT_Add = intRT_Add

class street_error_class:
    def __init__(self, lngID, strErrType, lngArcID, strLabel, intLF_Add, intLT_Add, intRF_Add):
        self.lngID = lngID
        self.strErrType = strErrType
        self.lngArcID = lngArcID
        self.strLabel = strLabel
        self.intLF_Add = intLF_Add
        self.intLT_Add = intLT_Add
        self.intRF_Add = intRF_Add

## access like this:
# data = street_data_class(1, 'N', 'Main', 'St', '', 'Main St', 100, 200, 101, 201)
# print(data.strName)

# read in data 
def open_file(str_path):
    # Opens the .txt file and inputs its values into a list of street_data_class objects
    str_file = []
    with open(str_path, 'r') as file:
        for line in file:
            data = line.strip().split(',')
            street_data = street_data_class(
                lngID=int(data[0]),
                strPrefix=data[1],
                strName=data[2],
                strType=data[3],
                strSuffix=data[4],
                strLabel=data[5],
                intLF_Add=int(data[6]),
                intLT_Add=int(data[7]),
                intRF_Add=int(data[8]),
                intRT_Add=int(data[9])
            )
            str_file.append(street_data)
    return str_file
