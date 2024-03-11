Attribute VB_Name = "modCheckStrAdd"
Option Explicit

'****************************************************************************************************
'*
'*      Title:          Check Street Addressing
'*
'*      Purpose:        The purpose will of this script is to take a csv text file containing
'*                      the addressing range information for every street segment in the
'*                      Carson City GIS street centerline file and look for addressing range
'*                      errors.  It will report the errors it finds to another text file.
'*                      This text file will allow us to then correct any addressing range
'*                      errors within the system.
'*
'*      Version:        1.0
'*
'*      Date:           10/18/2007
'*
'*      Notes:          This script was written using VBA out of Microsft Excel 2003
'*
'*      Contact:        Matt Forrest
'*                      Carson City GIS Supervisor
'*                      3505 Butti Way
'*                      Carson City, NV 89701
'*                      (775) 887-2355 - voice
'*                      (775) 887-2112 - fax
'*                      mforrest@ci.carson-city.nv.us
'*
'****************************************************************************************************

Private Type StrtData
' User defined type to hold the elements in the street data text file
    lngID As Long           'Arc ID
    strPrefix As String     'Street Name - Prefix
    strName As String       'Street Name - Name
    strType As String       'Street Name - Type
    strSuffix As String     'Street Name - Suffix
    strLabel As String      'Street Name - Label
    intLF_Add As Integer    'Street Left From Address
    intLT_Add As Integer    'Street Left To Address
    intRF_Add As Integer    'Street Right From Address
    intRT_Add As Integer    'Street Right To Address
End Type

Private Type StrtError
' User Defined Type to hold the errored street data
    lngID As Long           'Error ID
    strErrType As String    'Error Type
    lngArcID As Long        'Arc ID
    strLabel As String      'Street Name - Label
    intLF_Add As Integer    'Street Left From Address
    intLT_Add As Integer    'Street Left To Address
    intRF_Add As Integer    'Street Right From Address
    intRT_Add As Integer    'Street Right To Address
End Type

Private Function OpenFile(ByVal strPath As String) As StrtData()
'Opens the .txt file and inputs it's values into a string array
    Dim strFile() As StrtData   'Array of lines in the file
    Dim i As Integer            'counter
    
    i = 0
    ReDim strFile(0)
    Open strPath For Input As #1
    Do Until EOF(1) = True
        ReDim Preserve strFile(i)
        Input #1, strFile(i).lngID, strFile(i).strPrefix, strFile(i).strName, _
            strFile(i).strType, strFile(i).strSuffix, strFile(i).strLabel, _
            strFile(i).intLF_Add, strFile(i).intLT_Add, strFile(i).intRF_Add, _
            strFile(i).intRT_Add
        
        i = i + 1
    Loop
    Close #1
    OpenFile = strFile
End Function

Private Sub WriteFile(ByVal strPath As String, ByRef strFileData() As String)
    'Writes the file data to a text file who's name is given in the path
    Dim i As Long
    
    Open strPath For Output As #1
        For i = 0 To UBound(strFileData)
            Print #1, strFileData(i)
        Next
    Close #1
End Sub

Private Sub SortStrArray(ByRef strArray() As String)
    'Returns a sorted (Ascending) string array
    Dim i As Long
    Dim j As Long
    Dim strTemp As String
    
    For i = 0 To UBound(strArray)
        For j = i To UBound(strArray)
            If strArray(i) > strArray(j) Then
                strTemp = strArray(i)
                strArray(i) = strArray(j)
                strArray(j) = strTemp
            End If
        Next
    Next
End Sub

Private Sub SortRFArray(ByRef udtArray() As StrtData)
    'Returns a sorted (Ascending) StrtData array using the Right From Address field
    Dim i As Long
    Dim j As Long
    Dim udtTemp As StrtData
    
    For i = 0 To UBound(udtArray)
        For j = i To UBound(udtArray)
            If udtArray(i).intRF_Add > udtArray(j).intRF_Add Then
                udtTemp = udtArray(i)
                udtArray(i) = udtArray(j)
                udtArray(j) = udtTemp
            End If
        Next
    Next
End Sub

Private Function NoDup(ByRef strArray() As String) As String()
'Returns a string array that contains no duplicates
    Dim i As Long               'counter
    Dim j As Long               'counter
    Dim blnExists As Boolean    'boolean value Yes/No exists
    Dim strTemp As String
    Dim strNewArray() As String 'Holds the new array without dublicates
    
    For i = 0 To UBound(strArray)
        blnExists = False   'initialize exists boolean as false, must test to be true
        If i = 0 Then
            'if first time through the loop, then just take the string
            ReDim strNewArray(0)
            strNewArray(0) = strArray(0)
        Else
            For j = 0 To UBound(strNewArray)
            'loop throug all of the existing new string to see if the current string matches
                If strArray(i) = strNewArray(j) Then
                'if it does, then set exists to true
                    blnExists = True
                    Exit For
                End If
            Next
            
            If blnExists = False Then
            'if exists is still false, then add the current string to the new string array
                ReDim Preserve strNewArray(UBound(strNewArray) + 1)
                strNewArray(UBound(strNewArray)) = strArray(i)
            End If
        End If
    Next
    NoDup = strNewArray
End Function

Private Function isEven(ByVal intVal As Integer) As Boolean
' Returns True if the value is an even integer, False if it is odd
    Dim blnResult As Boolean
    Dim dblTest As Double
    
    blnResult = False
    
    dblTest = CDbl(intVal) / 2#
    
    If dblTest = CInt(dblTest) Then
        blnResult = True
    End If
    isEven = blnResult
End Function

Public Sub Run()
' Runs the whole process
On Error GoTo Error:

    Dim strFile As String           'File to open
    Dim strWFile As String          'File Name & Location of write file
    Dim strWriteFile() As String    'file to write
    Dim udtFile() As StrtData       'Array holding the opened file
    Dim strStreets() As String      'An array of street names
    Dim udtCurStrt() As StrtData    'All of the arcs for the current street
    Dim udtErrStrt() As StrtError   'Array of Errors
    Dim udtTempStrt As StrtData     'Holds the last street to compare too
    Dim i As Long                   'Counter
    Dim j As Long                   'Counter
    Dim k As Long                   'Counter
    Dim e As Long                   'Error Counter
    
    ' Get text file from user
    ' File must be cleaned to only contain fields:
    '   ID,Prefix,Name,Type,Suffix,Label,RF,RT,LF,LT  in a csv file
    strFile = InputBox("Paste path & file name into the input box", "File containing street data")
    strWFile = InputBox("Please input the path and file name of the output text file", "Write file location")
    'strFile = "C:\Carson\Streets\StreetData_071018.csv"
    
    ReDim udtErrStrt(0) 'initilize the error array
    e = 0               'set error counter to 0
    
    udtFile = OpenFile(strFile) 'get the text data
    ReDim strStreets(0)         'initilize the street name array
    j = 0                       'set j counter to 0
    
    ' loop through each street in the file
    For i = 0 To UBound(udtFile)
        If i <> 0 Then  'skip the header row
            'Only get streets who's address are greater than 0
            If udtFile(i).intLF_Add > 0 Or udtFile(i).intRF_Add > 0 Then
                ReDim Preserve strStreets(j)
                strStreets(j) = udtFile(i).strLabel 'add street name to array
                j = j + 1
            End If
        End If
    Next
    
    ' sort the street names array
    Call SortStrArray(strStreets)
    ' remove the duplicate street names
    strStreets = NoDup(strStreets)
    
    ' retreive all of the street segments for each street name in
    ' in the array and compare their address to each other.
    For i = 0 To UBound(strStreets)
        ' initilize the array to hold all of the street segments
        ' for the current street
        ReDim udtCurStrt(0)
        k = 0   'set k counter to 0 for each new street
        
        ' loop through the file and collect each segment for the
        ' current street
        For j = 0 To UBound(udtFile)
            If strStreets(i) = udtFile(j).strLabel Then
                ReDim Preserve udtCurStrt(k)
                udtCurStrt(k) = udtFile(j)
                k = k + 1
            End If
        Next
        
        ' sort the current street segments array by the Right From address
        Call SortRFArray(udtCurStrt)
        
        ' If there is only one street segment, don't waste time going through
        ' the rest of the process, no error
        If UBound(udtCurStrt) > 0 Then
            
            ' clear the temp street variable for first run through loop
            With udtTempStrt
                .lngID = -1
                .strPrefix = ""
                .strName = ""
                .strType = ""
                .strSuffix = ""
                .strLabel = ""
                .intLF_Add = -1
                .intLT_Add = -1
                .intRF_Add = -1
                .intRT_Add = -1
            End With
            
            ' loop through all of the current street segments and look for errors
            For j = 0 To UBound(udtCurStrt)
                ' Skip any address that are set to 0, no errors there
                If udtCurStrt(j).intLF_Add <> 0 And udtCurStrt(j).intRF_Add <> 0 Then
                    ' check to see if this is the first time through the loop.  If ID = -1
                    ' then just skip to the next segment making the current one the temporary
                    ' comparison segment.
                    If udtTempStrt.lngID <> -1 Then
                        'If not first time through the loop, then
                        'compare the two for all three error types
                        
                        '1) Flow (Even/Odd)
                        '  if the from and too columns don't match the isEven test, then the
                        '  street segment has flow errors
                        If isEven(udtTempStrt.intLF_Add) <> isEven(udtCurStrt(j).intLF_Add) Or _
                            isEven(udtTempStrt.intLT_Add) <> isEven(udtCurStrt(j).intLT_Add) Or _
                            isEven(udtTempStrt.intRF_Add) <> isEven(udtCurStrt(j).intRF_Add) Or _
                            isEven(udtTempStrt.intRT_Add) <> isEven(udtCurStrt(j).intRT_Add) Then
                            
                            'Flow Error
                            'Add error to the error array
                            e = e + 1   'count for next error id
                            
                            ' check to see if this is the first error to be added to the array
                            If UBound(udtErrStrt) = 0 Then
                                ReDim udtErrStrt(1) 'initilize the error array
                            Else
                                ' add two more elements to the array for the two streets being
                                ' compared
                                ReDim Preserve udtErrStrt(UBound(udtErrStrt) + 2)
                            End If
                        
                            ' add first street segment to error array
                            With udtErrStrt(UBound(udtErrStrt) - 1)
                                .lngID = e
                                .strErrType = "Flow"
                                .lngArcID = udtTempStrt.lngID
                                .strLabel = udtTempStrt.strLabel
                                .intLF_Add = udtTempStrt.intLF_Add
                                .intLT_Add = udtTempStrt.intLT_Add
                                .intRF_Add = udtTempStrt.intRF_Add
                                .intRT_Add = udtTempStrt.intRT_Add
                            End With
                            
                            ' add second street segment to error array
                            With udtErrStrt(UBound(udtErrStrt))
                                .lngID = e
                                .strErrType = "Flow"
                                .lngArcID = udtCurStrt(j).lngID
                                .strLabel = udtCurStrt(j).strLabel
                                .intLF_Add = udtCurStrt(j).intLF_Add
                                .intLT_Add = udtCurStrt(j).intLT_Add
                                .intRF_Add = udtCurStrt(j).intRF_Add
                                .intRT_Add = udtCurStrt(j).intRT_Add
                            End With
                        
                        End If
                        
                        '2) Overlap (Address ranges overlap each other)
                        '  If the too field from the first street segment is greater than
                        '  the from field from the second street segment, then we have an
                        '  overlap error
                        If udtTempStrt.intLT_Add >= udtCurStrt(j).intLF_Add Or _
                            udtTempStrt.intRT_Add >= udtCurStrt(j).intRF_Add Then
                            
                            'Overlap Error
                            'add error to the error array
                            e = e + 1 'get next id for error array
                            
                            'test to see if this is the first error to be added to the array
                            If UBound(udtErrStrt) = 0 Then
                                ReDim udtErrStrt(1) 'initilize the error array
                            Else
                                'add two more elements to the error array
                                ReDim Preserve udtErrStrt(UBound(udtErrStrt) + 2)
                            End If
                        
                            ' add first street segment to the error array
                            With udtErrStrt(UBound(udtErrStrt) - 1)
                                .lngID = e
                                .strErrType = "Overlap"
                                .lngArcID = udtTempStrt.lngID
                                .strLabel = udtTempStrt.strLabel
                                .intLF_Add = udtTempStrt.intLF_Add
                                .intLT_Add = udtTempStrt.intLT_Add
                                .intRF_Add = udtTempStrt.intRF_Add
                                .intRT_Add = udtTempStrt.intRT_Add
                            End With
                            
                            ' add second street segment to the error array
                            With udtErrStrt(UBound(udtErrStrt))
                                .lngID = e
                                .strErrType = "Overlap"
                                .lngArcID = udtCurStrt(j).lngID
                                .strLabel = udtCurStrt(j).strLabel
                                .intLF_Add = udtCurStrt(j).intLF_Add
                                .intLT_Add = udtCurStrt(j).intLT_Add
                                .intRF_Add = udtCurStrt(j).intRF_Add
                                .intRT_Add = udtCurStrt(j).intRT_Add
                            End With
                        End If
                        
                        
'                        '3) Gap (Address ranges have an address gap between arc segments)
'                        '  if the from address of the second street segment does not equal
'                        '  the too address + 2 from the first street segment, then we have
'                        '  a gap error
'                        If udtCurStrt(j).intLF_Add <> udtTempStrt.intLT_Add + 2 Or _
'                            udtCurStrt(j).intRF_Add <> udtTempStrt.intRT_Add + 2 Then
'
'                            'Gap Error
'                            'add error to the error array
'                            e = e + 1   'get next error id
'
'                            'check to see if this is the first error to be added to the
'                            'error array
'                            If UBound(udtErrStrt) = 0 Then
'                                ReDim udtErrStrt(1) 'initilize the error array
'                            Else
'                                'add two more elements to the error array
'                                ReDim Preserve udtErrStrt(UBound(udtErrStrt) + 2)
'                            End If
'
'                            'add first street segment to the error array
'                            With udtErrStrt(UBound(udtErrStrt) - 1)
'                                .lngID = e
'                                .strErrType = "Gap"
'                                .lngArcID = udtTempStrt.lngID
'                                .strLabel = udtTempStrt.strLabel
'                                .intLF_Add = udtTempStrt.intLF_Add
'                                .intLT_Add = udtTempStrt.intLT_Add
'                                .intRF_Add = udtTempStrt.intRF_Add
'                                .intRT_Add = udtTempStrt.intRT_Add
'                            End With
'
'                            'add second street segment to the error array
'                            With udtErrStrt(UBound(udtErrStrt))
'                                .lngID = e
'                                .strErrType = "Gap"
'                                .lngArcID = udtCurStrt(j).lngID
'                                .strLabel = udtCurStrt(j).strLabel
'                                .intLF_Add = udtCurStrt(j).intLF_Add
'                                .intLT_Add = udtCurStrt(j).intLT_Add
'                                .intRF_Add = udtCurStrt(j).intRF_Add
'                                .intRT_Add = udtCurStrt(j).intRT_Add
'                            End With
'                        End If

                        'make current street segment the temporary comparison street segment
                        udtTempStrt = udtCurStrt(j)
                    Else
                        ' first time through the loop, make current street segment the temporary
                        ' comparison street segment and loop to the next street segment
                        udtTempStrt = udtCurStrt(j)
                    End If
                End If
            Next
        End If
    Next
    
    'Build the output text array
    ReDim strWriteFile(0)   'initilize the write file array
    
    'loop through the error array and build the write file array that will be written out to a text file
    For i = 0 To UBound(udtErrStrt)
        'always 1 ahead of the array counter because of the header row
        ReDim Preserve strWriteFile(i + 1)
        
        If i = 0 Then
        'first time through the loop, create the header row as well as the first element in the error
            strWriteFile(0) = "ID,Type,ArcID,StrLabel,LF_Add,LT_Add,RF_Add,RT_Add"
            strWriteFile(i + 1) = udtErrStrt(i).lngID & "," & _
                            udtErrStrt(i).strErrType & "," & _
                            udtErrStrt(i).lngArcID & "," & _
                            udtErrStrt(i).strLabel & "," & _
                            udtErrStrt(i).intLF_Add & "," & _
                            udtErrStrt(i).intLT_Add & "," & _
                            udtErrStrt(i).intRF_Add & "," & _
                            udtErrStrt(i).intRT_Add
        Else
        'not first time through loop, so just add the error element
            strWriteFile(i + 1) = udtErrStrt(i).lngID & "," & _
                            udtErrStrt(i).strErrType & "," & _
                            udtErrStrt(i).lngArcID & "," & _
                            udtErrStrt(i).strLabel & "," & _
                            udtErrStrt(i).intLF_Add & "," & _
                            udtErrStrt(i).intLT_Add & "," & _
                            udtErrStrt(i).intRF_Add & "," & _
                            udtErrStrt(i).intRT_Add
        End If
    Next
    
    'finished building the file, write it out to a text file
    Call WriteFile(strWFile, strWriteFile)
    
    Exit Sub
Error:
    Call MsgBox("Error Running Script", vbInformation + vbOKOnly, "Error!")
End Sub
