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

foreach ($stream in $streams)
{
    ## If the Hash stream already exists, we clear it and re-add it later.
    if ($stream.Stream -eq "Hash")
    {
        Clear-Content -Path $path -Stream Hash
        break
    }
}

$hash = Get-FileHash -Path $path
Add-Content -Path $path -Stream Hash -Value $hash.Hash

return $hash