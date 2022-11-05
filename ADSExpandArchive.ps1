##
## On command line parameters, see :
## How to handle command-line arguments in PowerShell
## https://stackoverflow.com/questions/2157554/how-to-handle-command-line-arguments-in-powershell
##
param 
(
    [Parameter(Mandatory=$true)]
    [ValidateScript(
	{ 
        ## The -PathType Leaf param indicates to 
        ## to check that the path is a file.
        ## See : 
        ## Validate PowerShell to Check if a File Exists (Examples)
        ## https://adamtheautomator.com/powershell-check-if-file-exists/
		Test-Path -Path $_ -PathType Leaf
	})]
    [string]$path
)

# Open the Zip file archive for reading
try 
{
    $zipFile = [System.IO.Compression.ZipFile]::OpenRead($path)
}
catch 
{
    # If the Zip file fails to open, print error message and exit.
    Write-Host "Failed to open Zip file : " $path
    exit
}

# Get the manifest file
$manifestFile = $zipFile.Entries | Where-Object {$_.Name -eq "MANIFEST"}

if ($null -eq $manifestFile)
{
    # If no Manifest file found, print error message and exit.
    Write-Host "Manifest file not found."
    $zipFile.Dispose()
    exit
}

# Get the Directory of the Zip file to expand to.
# This Directory is where the extracted files will be stored.
$targetDir = Split-Path -Path $path
$manifestFilePath = -join($targetDir, "\", $manifestFile.Name)

try 
{
    # Extract the Manifest file.
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($manifestFile, $manifestFilePath, $true)    
}
catch 
{
    # If we are unable to extract the target file, print error message and exit.
    Write-Host "Unable to extract Manifest file : " $manifestFile.Name
    $zipFile.Dispose()
    exit
}

# We use Get-Content to read each line of the Manifest file
# into a string array.
# We then extract the name of the target file (i.e. the first 
# file listed in the Manifest).
$manifestFileContent = Get-Content -Path $manifestFilePath
$targetFileName = -join($targetDir, "\", $manifestFileContent[0])

try
{
    # Extract the target file.
    $targetFile = $zipFile.Entries | Where-Object {$_.Name -eq $manifestFileContent[0]}
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($targetFile, $targetFileName, $true)
}
catch
{
    # If we are unable to extract the target file, print error message and exit.
    Write-Host "Unable to extract target file : " $manifestFileContent[0]
    $zipFile.Dispose()
    exit
}

# Iterate through each line of the Manifest file.
# For each line, check if the corresponding file can be found
# in the Zip file.
foreach ($line in $manifestFileContent)
{
    $file = $zipFile.Entries | Where-Object {$_.Name -eq $line}

    # If a file listed in the Manifest cannot be found in the
    # archive, print an error message and exit.
    if ($null -eq $file)
    {
        Write-Host "File $line is listed in the Manifest but not found."
        $zipFile.Dispose()
        exit
    }

    # We ignore the target file.
    if ($file.Name -eq $manifestFileContent[0])
    {
        continue
    }

    # Extract the current file and add it as a Stream to the target file.
    # Note that the extracted file is only a temporary physical file.
    $currentFileName = -join($targetDir, "\", $file.Name)
    
    try 
    {
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($file, $currentFileName, $true)    
    }
    catch 
    {
        # If we are unable to extract the current file, print error message and exit.
        Write-Host "Unable to extract file : " $currentFileName
        $zipFile.Dispose()
        exit
    }

    $fileContent = Get-Content -Path $currentFileName
    Add-Content -Path $targetFileName -Stream $file.Name -Value $fileContent

    # Remove the extracted file for cleanup purposes.
    Remove-Item -Path $currentFileName -Force
}

# Remove the extracted Manifest file for cleanup purposes.
Remove-Item -Path $manifestFilePath -Force

# Close Zip file
$zipFile.Dispose()