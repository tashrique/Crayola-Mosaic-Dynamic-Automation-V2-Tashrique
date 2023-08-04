$gridImageCount = 9

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
$print = New-Object -ComObject Wscript.Shell

# Get folder path
$folderPath = Join-Path $PSScriptRoot "/Crayola Folder"
if (!(Test-Path -Path $folderPath)) {
    Write-Output "Folder: $folderPath does not exist."
    Start-Sleep 5
    exit
}

# Function to get colorfulness, white percentage, and contrast
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
    exit
}

# Get the colorfulness data
foreach ($file in $jpgFiles) {
    $colorfulness, $white, $contrast = Get-Colorfulness -imagePath $file.FullName
    $imageData += , @($file.FullName, $colorfulness, $white, $contrast)
}

# Sort by colorfulness and select top 9
$top = $imageData | Sort-Object -Property @{Expression = { $_[1] }; Ascending = $false } | Select-Object -First $gridImageCount

# Delete all other images
$jpgFiles | Where-Object { $top.FullName -notcontains $_.FullName } | ForEach-Object { Remove-Item $_.FullName -Force }

# Generate a list of final names and shuffle them
$finalNames = 1..$gridImageCount | ForEach-Object { "{0:D2}.jpg" -f $_ }
$finalNames = $finalNames | Sort-Object { Get-Random }

# Rename top 9 images
for ($i = 0; $i -lt $gridImageCount; $i++) {
    $oldImagePath = $top[$i][0]
    $newImageName = $finalNames[$i]
    $newImagePath = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($oldImagePath), $newImageName)
    Rename-Item -Path $oldImagePath -NewName $newImagePath -Force
}

Write-Host "Select $gridImageCount Top Pictures and Rename: SUCCESS"

#------------------------------------------------------------------#
  