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
