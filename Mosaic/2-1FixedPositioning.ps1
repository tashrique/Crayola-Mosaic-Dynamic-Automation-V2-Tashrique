#----------------------------------------------------------------------------------#
# INITILAIZE FILE NAMES
$textPath = Get-Content -Path ".\workingFolderPath.txt"
$outputPath = Join-Path -Path $textPath -ChildPath "Output"
$csvPath = Join-Path -Path $outputPath -ChildPath "temp.csv"
$data = Import-Csv -Path $csvPath
$data = $data | Select-Object -Skip 1
$data | Sort-Object {[double]$_.'Contrast'}, @{Expression = {[double]$_.'Colorfulness'}; Descending = $true} | Export-Csv $csvPath -NoTypeInformation
#----------------------------------------------------------------------------------#

# Top 5 images
$top5Images = $data[0..4]

# Remaining images
$remainingImages = $data[5..($data.Count - 1)]

# Generate a list of final names and shuffle them
$finalNames = 1..25 | ForEach-Object { "{0:D2}.jpg" -f $_ } | Get-Random -Count 25

# Specific names for the top 5 images
$top5Names = "13.jpg", "01.jpg", "05.jpg", "20.jpg", "25.jpg"

# Remove the top 5 names from the list of final names
$remainingNames = $finalNames | Where-Object { $_ -notin $top5Names }

# Rename the top 5 images
for ($i = 0; $i -lt $top5Images.Count; $i++) {
    # Rename the image
    $oldImageName = Split-Path -Path $top5Images[$i].'File path' -Leaf
    $newImageName = $top5Names[$i]
    Get-Item -Path (Join-Path -Path $outputPath -ChildPath $oldImageName) | Rename-Item -NewName $newImageName -Force

    # Update the corresponding row in the data
    $top5Images[$i].'File path' = Join-Path -Path $outputPath -ChildPath $newImageName
}

# Rename the remaining images
for ($i = 0; $i -lt $remainingImages.Count; $i++) {
    # Rename the image
    $oldImageName = Split-Path -Path $remainingImages[$i].'File path' -Leaf
    $newImageName = $remainingNames[$i]
    Get-Item -Path (Join-Path -Path $outputPath -ChildPath $oldImageName) | Rename-Item -NewName $newImageName -Force

    # Update the corresponding row in the data
    $remainingImages[$i].'File path' = Join-Path -Path $outputPath -ChildPath $newImageName
}

# Combine the two parts of the data
$updatedData = $top5Images + $remainingImages

# Save changes to CSV
$outputCsvPath = Join-Path -Path $textPath -ChildPath "Output\MosaicColorData.csv"
$updatedData | Export-Csv -Path $outputCsvPath -NoTypeInformation
Write-Host "Photo Order Arrangement: SUCCESS"


# PREPARED FOR RENAMING - COMPLEMENTARY COLORS
#-------------------------------------------------------------------------#
# ADD COLUMN TO SHEET FOR RGB
$newData = @()
foreach ($item in $data) {

    $originalFilePath = $item.'File path'
    $pythonOutput = & python "3get_dominant_color.py" "$originalFilePath"
    $colors = $pythonOutput.Trim("[]")
    $dominant_color, $complementary_color = $colors -split ';'
    $R, $G, $B = $dominant_color -split ','
    $cR, $cG, $cB = $complementary_color -split ','

    # Create a copy of the item and add the new "Dominant" and "Complementary" properties
    $newItem = $item | Add-Member -MemberType NoteProperty -Name "R" -Value $R -PassThru
    $newItem = $newItem | Add-Member -MemberType NoteProperty -Name "G" -Value $G -PassThru
    $newItem = $newItem | Add-Member -MemberType NoteProperty -Name "B" -Value $B -PassThru
    $newItem = $newItem | Add-Member -MemberType NoteProperty -Name "cR" -Value $cR -PassThru
    $newItem = $newItem | Add-Member -MemberType NoteProperty -Name "cG" -Value $cG -PassThru
    $newItem = $newItem | Add-Member -MemberType NoteProperty -Name "cB" -Value $cB -PassThru

    # Add the new item to the new data array
    $newData += $newItem


    $OfileName = Split-Path -Path $originalFilePath -Leaf
    Write-Host "$OfileName : OK"

}

$newData | Export-Csv -Path $outputCsvPath -NoTypeInformation
Write-Host "RGB added to CSV: SUCCESS"
#------------------------------------------------------------------------------------#

& cscript.exe '.\4runNextStep.vbs'