##
## On command line paramerters, see :
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

# Create a zip file with the contents of :$DATA
$zip_file_name = -join("$Path", '.zip')

# Check if target zip file already exists.
# If so, delete it first.
if (Test-Path -Path $zip_file_name)
{
    Remove-Item -Path $zip_file_name -Force
}

Compress-Archive -Path $Path -DestinationPath $zip_file_name -Force

# Create a Manifest file.
# If Manifest file already exists, remove it.
$targetDir = Split-Path -Path $path
$manifest_file_name = -join($targetDir, '\', 'MANIFEST')

if (Test-Path -Path $manifest_file_name)
{
    Remove-Item -Path $manifest_file_name -Force
}

# New-Item will now create the Manifest file.
New-Item -Path $manifest_file_name -ItemType "file" -Force

# Add the name of the target file to the Manifest file.
# The name of the target file must be the first line in 
# the Manifest file. This is how we identify the target file.
$target_file_name = Split-Path -Path $Path -Leaf -Resolve
Add-Content -Path $manifest_file_name -Value $target_file_name

# Iterate the ADS streams of the target file.
foreach ($stream in $streams)
{
    # We will ignore the :$DATA stream because
    # it has already been archived in the earlier
    # call to Compress-Archive.
    if ($stream.Stream -eq ':$DATA')
    {
        continue
    }

    # We will now create a physical file for the current stream.
    # Note that this is a temporary file which will later be deleted.
    $item = Get-Content $Path -Stream $stream.Stream
    $stream_file_name = -join($targetDir, '\', $stream.Stream)

    # We will do some special processing if $item is 
    # an array of Objects or if the current stream 
    # is Zone.Identifier.
    if (($item -is [System.Object[]]) -or ($stream.Stream -eq "Zone.Identifier"))
    {
        # Create a file with the name of the stream.
        New-Item -Path $stream_file_name -ItemType "file" -Force

        # If $item is an array, we add its contents to the file.
        # As the current stream is an array of objects, we iterate
        # this array and add each element separately into the file.
        for ($i = 0; $i -lt $item.Length; $i++)
        {
            Add-Content -Path $stream_file_name -Value $item[$i] -Force
        }
    }
    else
    {
        # We add the contents of $item to the file straight away.
        New-Item -Path $stream_file_name -ItemType "file" -Value $item -Force
    }

    # Add the current stream file to the zip file.
    # (Existing files in the zip file with the same name are replaced) 
    Compress-Archive -Path $stream_file_name -Update -DestinationPath $zip_file_name

    # We remove the physical file of the current stream after adding it to the archive.
    Remove-Item -Path $stream_file_name -Force

    # Add the name of the stream to the Manifest file.
    Add-Content -Path $manifest_file_name -Value $stream.Stream
}

# Add the Manifest file to the zip file.
Compress-Archive -Path $manifest_file_name -Update -DestinationPath $zip_file_name

# We remove the physical Manifest file after adding it to the archive.
Remove-Item -Path $manifest_file_name -Force