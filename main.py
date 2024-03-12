import sys
from PyQt5.QtWidgets import QApplication, QMainWindow, QFileDialog
from PyQT5.Qt import QT

#import other python files for project
import StreetCL_QC_GUI
import StreetCL_QC_core_functions

# ======================================================
# ====== GUI event handler and related functions (classes?) ====== #
# ======================================================

# run the open button to select output path and filename
#todo: change from shapefile - maybe need 2 of these, for table & csv
def outputFilePath():
    '''Create output file path via dialog box'''
    outputFileName, _ = QFileDialog.getSaveFileName(mainWindow,'',"Shapefile (*.shp)")

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
ui = StreetCL_QC_GUI.Ui_MainWindow()
ui.setupUi(mainWindow)

# ============================== 
# ====== Connect signals ====== #
# ============================== 

# ====== Run app ====== #
mainWindow.show()
sys.exit(app.exec())