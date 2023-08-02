#----------------------------------------------------------------------------------#
# INITILAIZE FILE NAMES
# Read the folder path from the text file
$textPath = Get-Content -Path ".\workingFolderPath.txt"
$outputPath = Join-Path -Path $textPath -ChildPath "Output"
$csvPath = Join-Path -Path $outputPath -ChildPath "temp.csv"
$data = Import-Csv -Path $csvPath
$data = $data | Select-Object -Skip 1
#----------------------------------------------------------------------------------#

# RANDOMIZE

# Get all images in the folder
$images = Get-ChildItem -Path $outputPath -Filter *.jpg

# Generate a list of new names and shuffle them
$tempNames = 1..$images.Count | ForEach-Object { "temp{0:D2}.jpg" -f $_ }
$tempNames = $tempNames | Sort-Object { Get-Random }
$updatedData = @()

# Rename all images with a temporary name
for ($i = 0; $i -lt $images.Count; $i++) {
    # Save the old image name
    $oldImageName = $images[$i].Name

    # Rename the image
    $images[$i] | Rename-Item -NewName $tempNames[$i] -Force

    # Update the corresponding row in the data
    for ($j = 0; $j -lt $data.Count; $j++) {
        if ($data[$j].'File path' -like "*$oldImageName") {
            $data[$j].'File path' = Join-Path -Path $outputPath -ChildPath $tempNames[$i]
            $updatedData += $data[$j]
        }
    }
}

# Get new list of images after renaming
$images = Get-ChildItem -Path $outputPath -Filter *.jpg

# Generate a list of final names and shuffle them
$finalNames = 1..$images.Count | ForEach-Object { "{0:D2}.jpg" -f $_ }
$finalNames = $finalNames | Sort-Object { Get-Random }

# Rename all images with the final name
for ($i = 0; $i -lt $images.Count; $i++) {
    # Save the old image name
    $oldImageName = $images[$i].Name

    # Rename the image
    $images[$i] | Rename-Item -NewName $finalNames[$i] -Force

    # Update the corresponding row in the data
    for ($j = 0; $j -lt $updatedData.Count; $j++) {
        if ($updatedData[$j].'File path' -like "*$oldImageName") {
            $updatedData[$j].'File path' = Join-Path -Path $outputPath -ChildPath $finalNames[$i]
        }
    }
}

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


# # Export the new data to a CSV file
$newData | Export-Csv -Path $outputCsvPath -NoTypeInformation
# $sortCSV = Import-Csv -Path $outputCsvPath
Write-Host "RGB added to CSV: SUCCESS"
#------------------------------------------------------------------------------------#


& cscript.exe '.\4runNextStep.vbs'