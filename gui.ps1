Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = 'Mosaic/Crayola Automation'
$mainForm.Size = New-Object System.Drawing.Size(500, 250)
$mainForm.StartPosition = 'CenterScreen'
$Font = New-Object System.Drawing.Font("Roboto", 12)
$mainForm.Font = $Font

$questionLabel = New-Object System.Windows.Forms.Label
$questionLabel.Location = New-Object System.Drawing.Point(30,10)
$questionLabel.Size = New-Object System.Drawing.Size(250,20)
$questionLabel.Text = 'Which automation to run?'
$mainForm.Controls.Add($questionLabel)

$radioButton1 = New-Object System.Windows.Forms.RadioButton
$radioButton1.Location = New-Object System.Drawing.Point(30, 40)
$radioButton1.Size = New-Object System.Drawing.Size(200, 20)
$radioButton1.Text = 'Mosaic 5x5'
$radioButton1.Checked = $true 
$radioButton1.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$mainForm.Controls.Add($radioButton1)

$radioButton2 = New-Object System.Windows.Forms.RadioButton
$radioButton2.Location = New-Object System.Drawing.Point(30, 65)
$radioButton2.Size = New-Object System.Drawing.Size(200, 20)
$radioButton2.Text = 'Crayola 3x3'
$radioButton2.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$mainForm.Controls.Add($radioButton2)

$radioButton3 = New-Object System.Windows.Forms.RadioButton
$radioButton3.Location = New-Object System.Drawing.Point(30, 90)
$radioButton3.Size = New-Object System.Drawing.Size(200, 20)
$radioButton3.Text = 'Both'
$radioButton3.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$mainForm.Controls.Add($radioButton3)

$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(30, 120)
$button.Size = New-Object System.Drawing.Size(120, 30)
$button.Text = 'Run'
$button.BackColor = [System.Drawing.Color]::LightGreen
$mainForm.Controls.Add($button)

$scriptPath = $PSScriptRoot
$logo = Join-Path $scriptPath "\Dynamic\Artkive_GC.png"


# Create a PictureBox control
$logoPictureBox = New-Object System.Windows.Forms.PictureBox
$logoPictureBox.Location = New-Object System.Drawing.Point(250, 40) # Adjust the location as needed
$logoPictureBox.Size = New-Object System.Drawing.Size(300, 100) # Adjust the size as needed
$logoPictureBox.Image = [System.Drawing.Image]::FromFile($logo) # Replace with the correct path to your PNG
$logoPictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage

$mainForm.Controls.Add($logoPictureBox)


$scriptPath = $PSScriptRoot
$batchFile1 = Join-Path $scriptPath "\Mosaic\00000 Start Here.bat"
$batchFile2 = Join-Path $scriptPath "\Crayola\00000 Start Here.bat"
$batchFile3 = Join-Path $scriptPath "\Dynamic\00000 Start Here.bat"

$button.Add_Click({
        if ($radioButton1.Checked) {
            Start-Process $batchFile1
        }
        elseif ($radioButton2.Checked) {
            Start-Process $batchFile2
        }
        elseif ($radioButton3.Checked) {
            Start-Process $batchFile3
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("Please select an option!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }
        $mainForm.Close()
    })

$mainForm.ShowDialog()
