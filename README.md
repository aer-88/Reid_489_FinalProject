### Background
My company works as a data steward for street centerlines used with E911/NG911. A street centerline file contains addressing information used for computer-aided dispatch tools, so having accurate information is critical for emergency services. We did a large address quality control program for one of our clients several years ago, but it was focused on address points. The street centerlines were also updated but a thorough quality control check of the data was not performed.
My supervisor used to have a VB Script that ran in Excel to produce an Excel spreadsheet of street centerlines with address gaps, overlaps, nulls, and polarity errors. Then he would use this excel sheet while he reviewed the data in ArcMap Desktop and mark off when the issue had been resolved and/or if it was an allowed exception on the spreadsheet.
### Project Proposal
I will be recreating my supervisor’s old solution but updated in python. It will be used to quality check the street centerline file for our client. We don’t have budget to develop this solution and bill it to the client, and there are no ESRI tools that perform this type of comparison that we have found. ~~I do not have his old script, so this is not a porting project, rather a completely new script.~~ We do have the script, so now it is somewhat of a porting project.

I plan to create a GUI in QT Designer with PyQT. This might be standalone or might be run in conjunction with ArcGIS Pro, this will be decided later. 
There will be buttons and fields for loading the file, choosing what analysis to run (or all of them) and what form of output is desired (an Excel file or table in a geodatabase). 

A stretch goal is displaying the results in the GUI, with a way to mark if the row is ‘Completed’ or an ‘Exception’ as the issue is addressed in ArcGIS. Another stretch goal is to design the solution to be flexible enough to use with other county’s street centerlines for address validation.

In addition to the file handling and GUI portions mention already, the script will:
-	Sort the streets by name and address range
-	Check for:
    -	 Overlaps - if a street ended at 125, but the next street segment started at 100, then there was an overlap of 25 between the two
    -	 Gaps - if a street ended at 100, and the next street segment started at 125, then there was a gap of 25
    -	 Nulls – no information in the address fields
    -	 Flow  -  (on side of the street having both even and odd street numbers). If the from node started odd (i.e. 1) and ended with even (i.e. 10), then that is a polarity error. Checks to see if address range flows in least to greatest direction. Start node is smaller than ending node check.
-	Produce an Excel file or fgdb table of the results with a description of what the error was. Returned attributes are: Error ID, Object ID(s), Error Type, Street Label, Left & Right from & to node values.
### Deliverables
Deliverables for this task will be the python code that performs the solution, including any GUI files. I will also include test data (the data is public so the tool can be graded on the intended data) and documentation for running the tool. I could also include a statement from my supervisor about whether it met business needs if that were something that would fit this kind of assignment.

### Example Data
![image](https://github.com/aer-88/Reid_489_FinalProject/assets/154938117/117a8610-20ba-4ae4-b9da-6436ddf93951)
Fig. 1 - Snip of portion of street centerline attribute table.

![image](https://github.com/aer-88/Reid_489_FinalProject/assets/154938117/cdedc629-c85d-4938-ae6f-d8c2a26dfe82)
Fig. 2 - Graphic example of types of quality control checks needed on street centerline addresses
