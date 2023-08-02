# Get the BAT file path
$scriptDir = $PSScriptRoot
$batFile = Join-Path $scriptDir 'RunForOneMosaic.bat'
if (!(Test-Path -Path $batFile)) {
    Write-Output "File $batFile does not exist."
    return
}

# Get the ORDERS IN PROGRESS directory
$parentDir = Split-Path $PSScriptRoot -Parent
$outputDir = Join-Path $parentDir 'Orders in Progress\'
if (!(Test-Path -Path $outputDir)) {
    Write-Output "Directory $outputDir does not exist."
    return
}

# Get the subdirectories in the MOSAIC ORDERS SAMPLE directory
$subDirs = Get-ChildItem -Path $outputDir -Directory


# Counter for iterations
$i = 1

# For each subdirectory
foreach ($dir in $subDirs) {
    # Change directory to the subdirectory
    Set-Location -Path $dir.FullName

    # Create a temporary text file in the script directory and write the directory path to it
    $tempFile = Join-Path $scriptDir "temp.txt"
    $dir.FullName | Out-File -FilePath $tempFile

    # Run the BAT file
    & $batFile

    # Remove the temporary text file
    Remove-Item -Path $tempFile

    # Increment the counter
    $i++

    # If it's the 5th iteration
    if ($i % 5 -eq 0) {
        # Close Photoshop if it's running
        $photoshopProcess = Get-Process -Name 'Photoshop' -ErrorAction SilentlyContinue
        if ($null -ne $photoshopProcess) {
            Write-Output "Photoshop Closing for Clearing Scratch Disks..."
            Stop-Process -Name 'Photoshop'
            Write-Output "Photoshop is starting now"
        }
    }
}
