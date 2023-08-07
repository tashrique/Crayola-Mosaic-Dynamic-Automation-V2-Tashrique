Dim appRef
Dim javaScriptFile
Dim fso, currentDirectory

Set fso = CreateObject("Scripting.FileSystemObject")
currentDirectory = fso.GetParentFolderName(WScript.ScriptFullName)

Set appRef = CreateObject("Photoshop.Application")
javaScriptFile = currentDirectory & "\After_SaveDoc.jsx"
appRef.DoJavaScriptFile(javaScriptFile)
