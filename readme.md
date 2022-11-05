# ADSHash.ps1

`ADSHash.ps1` is a simple script that performs the following :

* It obtains the ADS streams of the target file via Get-Item and stores it into a variable `$streams`.
* It then iterates through the streams and check if one named “Hash” already exist.
* This checking is important because the file may already have a Hash stream and if so, this Hash stream must first be cleared via `Clear-Content`.
* If an existing Hash stream is not cleared first, a later call to `Add-Content` will append a new Hash string into the existing one, thus messing things up.
* After this initial check is done, we will obtain the current Hash of the file using the `Get-FileHash` cmdlet.
* We will next add the current hash string to the file as an ADS stream via `Add-Content`.
* Note that the clearing of any existing hash string and then obtaining and inserting the latest hash ensures that if the file was already hashed and then modified, it will be updated with the latest hash string.

The following is the format of a call to `ADSHash` :

```PowerShell
.\ADSHash.ps1 <path-to-target-file>
```

# ADSVerifyHash.ps1

ADSVerifyHash.ps1 is similarly simple. It performs the following :

* It obtains the ADS streams of a target file and stores them into a variable `$streams`.
* It then iterates through the streams and checks whether one named “Hash” exists.
* If a Hash stream does not exist, there is nothing to do. The cmdlet exits and a value of `$false` is returned to the PowerShell Pipeline.
* If a Hash stream exists, it is stored into a variable `$hashValue`.
* The current hash of the file is then computed using the `Get-FileHash` cmdlet and stored into a variable `$hashCompute`.
* The hash string of `$hashCompute` is accessed through its “Hash” property.
* Finally the `$hash` and `$hashCompute` Hash are string compared. The boolean result is returned to the PowerShell Pipeline.

The following is the format of a call to `ADSVerifyHash` :

```PowerShell
.\ADSVerifyHash.ps1 <path-to-target-file>
```

# ADSCompressArchive.ps1

Please refer to the comments in the script source to understand how it works. It would be even better if you can step through the code using a good editor/debugger like Visual Studio Code. 

The following is a summary of how it works :

* It starts by collecting all the streams of the target file into a variable named `$streams`.
* It then creates an empty .zip file named after the target file using `Compress-Archive`.
	* The name of the .zip file to be created is formed by concatenating the name of the original file with “.zip”.
	* Hence if the original file is “HelloWorld.txt”, the eventual zip file will be “HelloWorld.txt.zip”.
	* `Compress-Archive` will add the target file to the .zip file.
* A Manifest file (a text file) is created and the name of the original file will be added as the first line in this file.
	* The purpose of the Manifest file will be explained below.
* The script then iterates through the `$streams` variable. For each stream, it creates a file named after the stream.
* The contents of the stream file comprises the binary data associated with the stream.
* Each stream file is then added to the .zip file.
* After the stream file has been added to the .zip, the name of this stream file is appended to the Manifest file.
* The stream file is then deleted from the file system (it is temporary).

Eventually, the .zip file will contain the target file, a Manifest file, and a file for each of its streams.

The following is the format of a call to `ADSCompressArchive` :

```PowerShell
.\ADSCompressArchive.ps1 <path-to-target-file>
```

## The Manifest file.

The purpose of the Manifest file (a plain text file) is to list down all the files that have been archived into the .zip file. This way, when the .zip file is expanded by `ADSExpandArchive.ps1`, `ADSExpandArchive.ps1` will know what files to look for in the .zip and expand them accordingly.

Why the need for such a Manifest file? Wouldn’t the contents of the .zip file be sufficient to know what to expand? The following summary are the reasons for the Manifest file :

* The .zip file may contain more files than the ones added by `ADSCompressArchive.ps1`.
* Some of the files added by `ADSCompressArchive.ps1` may not be present.
	* In other words, the .zip file could have been modified (more files added or files removed) manually using WinRAR.
	* We do not wish to restrict people from adding more files to the archive.
* The .zip file may not even have been produced by `ADSCompressArchive.ps1`.
* The name of the .zip file may not match that of the original file (with all its ADS streams), which will make identification of the original file impossible.

Note that the Manifest file is formatted as follows : the target file name is the first line of the file, while the subsequent lines are the names of the stream files now added to the archive.

# ADSExpandArchive.ps1

The following is a summary of how `ADSExpandArchive.ps1` works :

* Note that instead of using the `Expand-Archive` cmdlet, I have opted to use the `System.IO.Compression.ZipFile` and the `System.IO.Compression.ZipFileExtensions` classes to perform the .zip file extractions.
	* The advantage of using these two classes is that we can extract specific files from a .zip file archive.
* It starts by using `ZipFile.OpenRead` to open the specified .zip file for reading.
	* The .zip file is referred to using the variable `$zipFile`.
* It then searches for the Manifest file from within the .zip file.
	* As explained in an earlier section, the Manifest file is important in the re-construction of the original file with all its associated streams.
	* Hence if the Manifest file cannot be found, the script will exit.
* The script then extracts the Manifest file from the .zip file using `ZipFileExtensions.ExtractToFile`.
* It then uses `Get-Content` to read the contents of the Manifest file into a string array.
	* The variable `$manifestFileContent` is used to refer to this string array.
	* The original file name is the first element of `$manifestFileContent`.
* It extracts the original file from the .zip file.
	* If the original file or any of its associated stream files cannot be found, the script will exit as we are unable to properly reconstruct the original file.
* Once the original file is extracted, the script iterates through `$manifestFileContent`.
	* For each line in `$manifestFileContent`, it extracts the relevant stream file from the .zip file.
	* Note that it will ignore the original file name as the original file has already been extracted at this point.
	* If the original stream file is not found or cannot be extracted, the script will exit.
	* Once the stream file is extracted, it will be added to the original file as a stream.
	* The stream file is then deleted.
* Once all stream files have been added to the original file, the Manifest file is also deleted.

The following is the format of a call to `ADSExpandArchive` :

```PowerShell
.\ADSExpandArchive.ps1 <path-to-target-file>
```