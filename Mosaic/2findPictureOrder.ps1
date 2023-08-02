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

# # Calculate color distance function
# function Update-ColorDistance() {
#     param (
#         [string]$R1,
#         [string]$G1,
#         [string]$B1,
#         [string]$R2,
#         [string]$G2,
#         [string]$B2
#     )

#     # $R1 = [int]::Parse($R1)
#     # $G1 = [int]::Parse($G1)
#     # $B1 = [int]::Parse($B1)
#     # $R2 = [int]::Parse($R2)
#     # $G2 = [int]::Parse($G2)
#     # $B2 = [int]::Parse($B2)

#     $distance = [Math]::Sqrt([Math]::Pow(($R2 - $R1), 2) + [Math]::Pow(($G2 - $G1), 2) + [Math]::Pow(($B2 - $B1), 2))
#     return $distance
# }
# #------------------------------------------------------------------------------------#

# $newDataSorted = @()

# # Pick a starting image (here we're just using the first one)
# $startItem = $newData[0]
# $newDataSorted += $startItem

# $indicesChosen = @(0)
# $count = $newData.Count

# for ($currentIndex = 1; $currentIndex -lt $count; $currentIndex++) {
#     # if ($indicesChosen -contains $currentIndex) {
#     #     Write-Host "Remove: $currentIndex"
#     #     continue
#     # }

#     $lastItem = $newDataSorted[-1]

#     # Calculate the color distance from the last item's dominant color to every other item's complementary color
#     $distances = $newData | ForEach-Object {
#         if ($indicesChosen -contains $newData.IndexOf($_)) {
#             return
#         }

#         New-Object PSObject -Property @{
#             'Item'     = $_
#             'Distance' = Update-ColorDistance $lastItem.R $lastItem.G $lastItem.B $_.cR $_.cG $_.cB
#         }
#     }

#     # Find the item with the smallest color distance and add it to the sorted data
#     $nextItem = ($distances | Sort-Object -Property Distance)[0].Item

#     $newDataSorted += $nextItem
#     $indicesChosen += $newData.IndexOf($nextItem)
# }


# # At this point, $newDataSorted should hold the data sorted by color distance
# #------------------------------------------------------------------------------------#


# # Rename the images based on the sorted data

# $counter = 1
# foreach ($item in $newDataSorted) {
#     $originalFilePath = $item.'File path'
#     $extension = (Get-Item $originalFilePath).Extension

#     # Convert the counter to a string and pad with '0' if necessary
#     $counterString = $counter.ToString().PadLeft(2, '0')

#     $newFileName = "$counterString$extension"
#     $newFilePath = Join-Path -Path $textPath -ChildPath "Output\$newFileName"

#     # Rename the file
#     Rename-Item -Path $originalFilePath -NewName $newFileName

#     # Update the 'File path' property in the data
#     $item.'File path' = $newFilePath

#     $counter++
# }


# # Export the updated data to a CSV file
# $newDataSorted | Export-Csv -Path $outputCsvPath -NoTypeInformation

# Write-Host "Complementary Color Arrangement: SUCCESS"

# # Delete the temp text file
# #Remove-Item -Path ".\workingFolderPath.txt"
# Remove-Item -Path $csvPath
# # Remove-Item -Path $outputCsvPath


& cscript.exe '.\4runNextStep.vbs'