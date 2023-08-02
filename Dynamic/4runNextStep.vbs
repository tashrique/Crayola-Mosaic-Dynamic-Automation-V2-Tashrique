Dim appRef
Dim javaScriptFile
Dim fso, currentDirectory

Set fso = CreateObject("Scripting.FileSystemObject")
currentDirectory = fso.GetParentFolderName(WScript.ScriptFullName)

Set appRef = CreateObject("Photoshop.Application")
javaScriptFile = currentDirectory & "\5OpenAndDecide3D.jsx"

' Print the path
WScript.Echo javaScriptFile

' Check if file exists
If (fso.FileExists(javaScriptFile)) Then
    appRef.DoJavaScriptFile(javaScriptFile)
Else
    WScript.Echo "File does not exist"
End If
