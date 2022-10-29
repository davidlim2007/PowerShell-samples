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

$streams = Get-Item -Path $Path -Stream * -Force
$streamExists = $false

foreach ($stream in $streams)
{
    ## Check if the Hash stream exists.
    if ($stream.Stream -eq "Hash")
    {
        $streamExists = $true
        break
    }
}

if (!$streamExists)
{
    return $false
}

$hashValue = Get-Content -Path $path -Stream Hash
$hashCompute = Get-FileHash -Path $path

if ($hashValue -eq $hashCompute.Hash)
{
    return $true
}
else
{
    return $false
}