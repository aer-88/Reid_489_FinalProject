import sys
from PyQt5.QtWidgets import QApplication, QMainWindow, QFileDialog
from PyQt5.Qt import QT

#import other python files for project
import streetCL_QC_gui
import StreetCL_QC_core_functions

# ======================================================
# ====== GUI event handler and related functions (classes?) ====== #
# ======================================================

###### Example - run the open buttons to select shapefiles  ##
def select_country_shapefile():
    ''' open file dialog to select country polygon shapefile and if accepted, update GUI LE with file name'''
#    countryFileName, _ = QFileDialog.getOpenFileName(mainWindow,"Select shapefile",r"D:\PennState\Geog489\Lesson2\Geog489_L2_Assignment2\Received\assignment2data\countries.shp","Shapefile (*.shp)")
    countryFileName, _ = QFileDialog.getOpenFileName(mainWindow,"Select shapefile",r"C:\geog489\Lesson2\A2_testing\assignment2data\countries.shp","Shapefile (*.shp)")
    if countryFileName:
        geog489_L2A2_core_functions.countryFileName = countryFileName
        ui.polygonshpLE.setText(countryFileName)
        ui.statusbar.showMessage('File selected: '+ countryFileName)

#### Examples of toggle checkboxes ############
def toggleShopType():
    '''toggle the shop type combo box picker using the All Shops checkbox'''
    if ui.queryAllShopsCKBX.isChecked():
        ui.statusbar.showMessage('All shops selected.')
        ui.queryOneShopCB.setDisabled(True) # disable the combo box
        geog489_L2A2_core_functions.poiQueryResult = shop_types  # assign the hardcoded list of shop types to the poiQueryResult list
    else:
        ui.statusbar.clearMessage()
        ui.queryOneShopCB.setEnabled(True) # Enable the combo box
        
def currentTextFromOneShopCB():
    '''Get one shop type from combo box and assign to query result'''
    geog489_L2A2_core_functions.poiQueryResult = ui.queryOneShopCB.currentText()
    print("inside currentTextFromOneShopCB, poiShopType is: " + geog489_L2A2_core_functions.poiQueryResult)


# run the open button to select output path and filename
#todo: change from shapefile - maybe need 2 of these, for table & csv
def outputFilePath():
    '''Create output file path via dialog box'''
    outputFileName, _ = QFileDialog.getSaveFileName(mainWindow,'Output folder and filename',"CSV (*.csv)")

    if outputFileName:
        StreetCL_QC_core_functions.outputFileName = outputFileName
        ui.outputNameLE.setText(outputFileName)
        ui.statusbar.showMessage('Output shapefile to be saved to: {}'.format(outputFileName))
   

# ========================================================= 
# ====== Create app and main window + dialogs GUI ====== #
# =========================================================
app = QApplication(sys.argv)

# Set up main window
mainWindow = QMainWindow()
ui = streetCL_QC_gui.Ui_MainWindow()
ui.setupUi(mainWindow)

# ============================== 
# ====== Connect signals ====== #
# ============================== 

# ====== Run app ====== #
mainWindow.show()
sys.exit(app.exec())


fc = r'D:\PennState\Geog489\Final Project\Final Project\FinalProj489.gdb\StrCLWorking'