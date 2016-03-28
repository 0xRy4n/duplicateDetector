'Author: Ryan J Gordon, March 2016

'This programs purpose is to identify duplicate account entries in a client database (though it could easily be tweaked for any database)
'To be flagged as duplicates, accounts need not be identical.
'Duplicate flagging works by using a 'duplication threshold'. If two accounts are similar enough to meet this threshold, they are marked as duplicates.
'In this version, first name and last name are weighted- meaning they are required to be matching in order to meet the threshold.
'In addition to having the same first and last name, accounts must also share either physical address, or email address, to be marked as duplicates.
'Everything is case insensitive

'Future versions will detect minor spelling differences on accounts and intelligently decide whether the differences are mistakes or intentional.
'Future versions will also have email spelling mistake correction (i.e. gmial.com -> gmail.com) using both intelligent string comparison algorithms and SMTP port checking

'This code assumes the following: column A is last name, column B is first name, column C is address, column D is email, and columns E and F are empty.


'************* Technical Details ***************'
'This reads the entire sheet into a massive array, made up of subarrays, where each subarray is the column data for the given row.
'For each row not marked as a duplicate, it loops through every row after it searching for duplicates of it (and marking them when found).
'I've calculated this to lead to roughly a complexity of O[1/2(n-1)^2 + (n-1)].
'Once completed it writes the array back into the sheet.
'All application features that lead to possible slow downs are disabled before running and enabled afterwords.

Const similarityThreshold As Double = 0.75


Sub Main():
    Application.ActiveSheet.UsedRange
    Dim lRowCount As Integer
    lRowCount = Worksheets(ActiveSheet.Name).UsedRange.Rows.count


    Application.ScreenUpdating = False
    Application.DisplayStatusBar = False
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False
    ActiveSheet.DisplayPageBreaks = False
    
    Dim sheet() As Variant
    sheet = sheetArray(lRowCount)
    Call duplicates(sheet, lRowCount)
    Call writeToSheet(sheet, lRowCount)
    
    Application.ScreenUpdating = True
    Application.DisplayStatusBar = True
    Application.EnableEvents = True
    ActiveSheet.DisplayPageBreaks = True
End Sub

'Reads data from sheet into sheetArray
Function sheetArray(ByRef lRowCount):
    Dim sheetArr() As Variant
    ReDim sheetArr(lRowCount)
    For i = 1 To lRowCount:
        Dim Fields(1 To 6) As String
        
        Fields(1) = Range("A" & i).Value
        Fields(2) = Range("B" & i).Value
        Fields(3) = Range("C" & i).Value
        Fields(4) = Range("D" & i).Value
        Fields(5) = Range("E" & i).Value
        Fields(6) = Range("F" & i).Value
        
        sheetArr(i) = Fields
    Next
    sheetArray = sheetArr
End Function


' Slightly modified version of function taken from wikibooks.org
Function LongestCommonSubstring(S1, S2)
  MaxSubstrStart = 1
  MaxLenFound = 0
  For i1 = 1 To Len(S1)
    For i2 = 1 To Len(S2)
      X = 0
      While i1 + X <= Len(S1) And _
            i2 + X <= Len(S2) And _
            Mid(S1, i1 + X, 1) = Mid(S2, i2 + X, 1)
        X = X + 1
      Wend
      If X > MaxLenFound Then
        MaxLenFound = X
        MaxSubstrStart = i1
      End If
    Next
  Next

  If (MaxLenFound > 0) Then
    LongestCommonSubstring = Mid(S1, MaxSubstrStart, MaxLenFound)
  Else
    LongestCommonSubstring = "NONE"
  End If

End Function


Function commonSubstrings(string1, string2)
    Dim S1 As String
    S1 = UCase(string1)
    Dim S2 As String
    S2 = UCase(string2)
    Dim finding As Boolean
    finding = True
    Dim commonSubs() As String

    Dim lcs As String

    Dim count As Integer
    count = 0
    Do While (finding = True)
        lcs = LongestCommonSubstring(S1, S2)
        If Not (StrComp(lcs, "NONE") = 0) Then
          ReDim Preserve commonSubs(count)
          commonSubs(count) = lcs
          count = count + 1
          S1 = Replace(S1, lcs, "")
          S2 = Replace(S2, lcs, "")
        Else
          finding = False
        End If
    Loop
    
    commonSubstrings = commonSubs
End Function

Function IsVarArrayEmpty(anArray As Variant)
    Dim i As Integer
    
    On Error Resume Next
        i = UBound(anArray, 1)
    If Err.Number = 0 Then
        IsVarArrayEmpty = False
    Else
        IsVarArrayEmpty = True
    End If
End Function


Function similarity(string1, string2) As Double
  Dim substrings() As String
  Dim totalStringLength As Integer
  Dim totalSubstringLength As Double
  Dim element As Variant

  substrings = commonSubstrings(string1, string2)
  If (IsVarArrayEmpty(substrings) = False) Then
      totalStringLength = Len(string1) + Len(string2)
    
      totalSubstringLength = 0
      For Each element In substrings
        If (Len(element) = 1) Then
            totalSubstringLength = totalSubstringLength + 0.5
        Else
            totalSubstringLength = totalSubstringLength + Len(element)
        End If
      Next element
    
      totalSubstringLength = totalSubstringLength * 2
      
      similarity = totalSubstringLength / totalStringLength
  Else
    similarity = 0
  End If

End Function


'Writes data back into sheet
Sub writeToSheet(ByRef sheet, ByVal lRowCount):
    For i = 1 To lRowCount:
        Range("A" & i).Value = sheet(i)(1)
        Range("B" & i).Value = sheet(i)(2)
        Range("C" & i).Value = sheet(i)(3)
        Range("D" & i).Value = sheet(i)(4)
        Range("E" & i).Value = sheet(i)(5)
        Range("F" & i).Value = sheet(i)(6)
    Next
End Sub


Sub duplicates(ByRef sheet As Variant, ByVal lRowCount As Integer):
    For i = 1 To lRowCount

        Dim lastName, firstName, email, address As String
        
        lastName = sheet(i)(1)
        firstName = sheet(i)(2)
        address = sheet(i)(3)
        email = sheet(i)(4)
        Duplicate = sheet(i)(5)
        
        If Not Duplicate = "YES" Then
        
            For n = (i + 1) To lRowCount
                
                Dim duplicateCounter As Integer
                duplicateCounter = 0
                
                Dim lastName2, firstName2, email2, address2 As String
                
                lastName2 = sheet(n)(1)
                firstName2 = sheet(n)(2)
                address2 = sheet(n)(3)
                email2 = sheet(n)(4)
                
                ' Fuzzy string comparisons
                If (similarity(firstName + lastName, firstName2 + lastName2) > similarityThreshold) Then
                    duplicateCounter = duplicateCounter + 4
                End If
                
                MsgBox (lastName + " " + lastName2)
                MsgBox (similarity(firstName + lastName, firstName2 + lastName2))
                
                If (similarity(address, address2) > similarityThreshold) Or (similarity(email, email2) > similarityThreshold) Then
                    duplicateCounter = duplicateCounter + 1
                End If
                
                If duplicateCounter >= 5 Then
                    sheet(i)(5) = "YES"
                    sheet(i)(6) = i
                    sheet(n)(5) = "YES"
                    sheet(n)(6) = i
                End If
                
            Next
        End If
    Next
End Sub


