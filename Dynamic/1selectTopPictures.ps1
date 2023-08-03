#-------------------------------------------------------#
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

$outputtxt = Join-Path -Path $pwd -ChildPath "Dynamic\workingFolderPath.txt"
$folderPath | Out-File -FilePath $outputtxt

#------------------------------------------------------------------
# Get colorfulness, white percentage and contrast
function Get-Colorfulness([string]$imagePath) {

    $bmp = [System.Drawing.Bitmap]::FromFile($imagePath)

    $totalColorfulness = 0
    $totalIntensity = 0
    $whitePixels = 0
    $whiteThreshold = 200
    $intensities = New-Object System.Collections.ArrayList

    for ($x = 120; $x -lt $bmp.Width - 120; $x += 500) {
        for ($y = 120; $y -lt $bmp.Height - 120; $y += 500) {
            $pixelColor = $bmp.GetPixel($x, $y)

            $r = $pixelColor.R
            $g = $pixelColor.G
            $b = $pixelColor.B

            $totalColorfulness += ($r - $g) * ($r - $g) + ($r - $b) * ($r - $b) + ($g - $b) * ($g - $b)

            if ($r -gt $whiteThreshold -and $g -gt $whiteThreshold -and $b -gt $whiteThreshold) {
                $whitePixels++
            }

            $intensity = ($r + $g + $b) / 3
            $intensities.Add($intensity) | Out-Null
            $totalIntensity += $intensity
        }
    }

    $avgColorfulness = $totalColorfulness / ($bmp.Width * $bmp.Height)

    $whitePixelsPercentage = $whitePixels / ($bmp.Width * $bmp.Height) * 100

    $avgIntensity = $totalIntensity / ($bmp.Width * $bmp.Height)
    $sumOfSquaresOfDifferences = 0
    foreach ($intensity in $intensities) {
        $sumOfSquaresOfDifferences += [Math]::Pow($intensity - $avgIntensity, 2)
    }
    $contrast = [Math]::Sqrt($sumOfSquaresOfDifferences / $intensities.Count)

    $bmp.Dispose()
    return $avgColorfulness, $whitePixelsPercentage, $contrast
}
#------------------------------------------------------------------
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
} else {
    $sortHelper = $gridImageCount
}

$whiteSort = $imageData | Sort-Object -Property @{Expression = { $_[2] }; Ascending = $true }
$topWhite = $whiteSort | Select-Object -First $sortHelper

$colorSort = $topWhite | Sort-Object -Property @{Expression = { $_[1] }; Ascending = $false }
$top = $colorSort | Select-Object -First $gridImageCount


#------------------------------------------------------------------#
$outputPath = Join-Path -Path $folderPath -ChildPath "Output"
if (Test-Path $outputPath) {
    Remove-Item -Path $outputPath -Recurse -Force
}
    
New-Item -Path $outputPath -ItemType Directory | Out-Null
$dataToExport = New-Object System.Collections.ArrayList
$firstRow = New-Object PSObject -Property @{
    "File path"    = $gridImageCount
    "Colorfulness" = $folderPath
    "White"        = $null
    "Contrast"     = $null
}
$dataToExport.Add($firstRow) | Out-Null

foreach ($item in $top) {
    Copy-Item -Path $item[0] -Destination $outputPath
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



















# & cscript.exe '.\4runNextStep.vbs'

