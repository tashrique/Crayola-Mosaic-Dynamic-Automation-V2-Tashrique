#-------------------------------------------------------#
# 9 = 3x3
# 16 = 4x4
# 25 = 5x5
$gridImageCount = 25

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
$print = New-Object -ComObject Wscript.Shell


# Get the path to the temp.txt file
$tempFile = Join-Path $PSScriptRoot "temp.txt"
if (!(Test-Path -Path $tempFile)) {
    Write-Output "File $tempFile does not exist."
    Start-Sleep 5
    exit
}

# Read the folderPath from the temp.txt file
$folderPath = Get-Content -Path $tempFile
if (!(Test-Path -Path $folderPath)) {
    Write-Output "Folder $folderPath does not exist."
    Start-Sleep 5
    exit
}


# If the folder exists, write the folder path to a text file
Write-Host "You selected: $folderPath"

$outputtxt = Join-Path -Path $pwd -ChildPath "workingFolderPath.txt"
$folderPath | Out-File -FilePath $outputtxt


#------------------------------------------------------------------#
#CHECK IF CORNERS ARE WHITE - ROUND PICTURE?

#------------------------------------------------------------------#
# Get colorfulness, white percentage and contrast
function Get-Colorfulness([string]$imagePath) {

    # Import image as bitmap 
    $bmp = [System.Drawing.Bitmap]::FromFile($imagePath)
    #Write-Host "Image dimensions: $($bmp.Width)x$($bmp.Height)"

    # Initialize variables
    $totalColorfulness = 0
    $totalIntensity = 0
    $whitePixels = 0
    $whiteThreshold = 200
    $intensities = New-Object System.Collections.ArrayList


    # Go through the pixels in the image
    for ($x = 120; $x -lt $bmp.Width - 120; $x += 500) {
        for ($y = 120; $y -lt $bmp.Height - 120; $y += 500) {
            $pixelColor = $bmp.GetPixel($x, $y)
            # Write-Host "Color at ($x, $y): $pixelColor"

            # Get RGB color values
            $r = $pixelColor.R
            $g = $pixelColor.G
            $b = $pixelColor.B

            # Get colorfulness
            $totalColorfulness += ($r - $g) * ($r - $g) + ($r - $b) * ($r - $b) + ($g - $b) * ($g - $b)

            # Check if pixel is white
            if ($r -gt $whiteThreshold -and $g -gt $whiteThreshold -and $b -gt $whiteThreshold) {
                $whitePixels++
            }
            # Get contrast
            $intensity = ($r + $g + $b) / 3
            $intensities.Add($intensity) | Out-Null
            $totalIntensity += $intensity
        }
    }

    # Average colrofulness
    $avgColorfulness = $totalColorfulness / ($bmp.Width * $bmp.Height)

    # Calculate percentage of white pixels
    $whitePixelsPercentage = $whitePixels / ($bmp.Width * $bmp.Height) * 100

    # SD of intensities for contrast
    $avgIntensity = $totalIntensity / ($bmp.Width * $bmp.Height)
    $sumOfSquaresOfDifferences = 0
    foreach ($intensity in $intensities) {
        $sumOfSquaresOfDifferences += [Math]::Pow($intensity - $avgIntensity, 2)
    }
    $contrast = [Math]::Sqrt($sumOfSquaresOfDifferences / $intensities.Count)

    # Return the 3 varaibles and get rid of the bitmap file
    $bmp.Dispose()
    return $avgColorfulness, $whitePixelsPercentage, $contrast
}




#------------------------------------------------------------------#
# Initialize and get images

$jpgFiles = Get-ChildItem -Path $folderPath -Filter "*.jpg"
$imageData = @()
$folderImageCount = $jpgFiles.Length
if ($folderImageCount -lt $gridImageCount) {
    $print.Popup("Folder Doesn't Have Enough Images")
}

foreach ($file in $jpgFiles) {
    $colorfulness, $white, $contrast = Get-Colorfulness -imagePath $file.FullName
    $imageData += , @($file.FullName, $colorfulness, $white, $contrast)
}


#------------------------------------------------------------------#
#Sort Images
if (($folderImageCount - $gridImageCount) -gt 2) {
    $sortHelper = $gridImageCount + ([math]::Round(($folderImageCount - $gridImageCount) / 2))
}
else {
    $sortHelper = $gridImageCount
}

# Sort by white percentage and eliminate 50% of the unnecessary images
$whiteSort = $imageData | Sort-Object -Property @{Expression = { $_[2] }; Ascending = $true }
$topWhite = $whiteSort | Select-Object -First $sortHelper

# Second Sort by colorfulness and eliminate all of the unnecessary images
$colorSort = $topWhite | Sort-Object -Property @{Expression = { $_[1] }; Ascending = $false }
$top = $colorSort | Select-Object -First $gridImageCount

#------------------------------------------------------------------#
# Define 'Output' folder in the selected directory
$outputPath = Join-Path -Path $folderPath -ChildPath "Output"

# Check if 'Output' folder exists
if (Test-Path $outputPath) {
    # Delete 'Output' folder and all its contents
    Remove-Item -Path $outputPath -Recurse -Force
}

# Create 'Output' folder in the selected directory
New-Item -Path $outputPath -ItemType Directory | Out-Null

# Create an ArrayList to store the output data
$dataToExport = New-Object System.Collections.ArrayList

# Add the first row with $gridImageCount and $folderPath
$firstRow = New-Object PSObject -Property @{
    "File path"    = $gridImageCount
    "Colorfulness" = $folderPath
    "White"        = $null
    "Contrast"     = $null
}
$dataToExport.Add($firstRow) | Out-Null

# Output the file paths of the top most images to the console, copy them to 'Output' folder, and add their data to the ArrayList
#Write-Host "Top $gridImageCount Most Colorful Images:"
foreach ($item in $top) {
    #Write-Host "File path: $($item[0]) | Colorfulness: $($item[1]) | White: $($item[2]) | contrast: $($item[3])"
    Copy-Item -Path $item[0] -Destination $outputPath
    
    # Create a PSObject with the image's data and add it to the ArrayList
    $row = New-Object PSObject -Property @{
        "File path"    = $item[0]
        "Colorfulness" = $item[1]
        "White"        = $item[2]
        "Contrast"     = $item[3]
    }
    $dataToExport.Add($row) | Out-Null 
} 

# Export the ArrayList to a CSV file
$dataToExport | Export-Csv -Path (Join-Path -Path $outputPath -ChildPath 'temp.csv') -NoTypeInformation
Write-Host "Select $gridImageCount Top Pictures: SUCCESS"


    
# Execute findPictureOrder.ps1 script
$scriptPath = ".\2findPictureOrder.ps1"
$scriptPath1 = ".\2-1FixedPositioning.ps1"


if (Test-Path $scriptPath1) {
    & $scriptPath
}
else {
    Write-Host "1findPictureOrder.ps1 does not exist in the directory $scriptPath1"
}
#------------------------------------------------------------------#
#END OF SELECT TOP


