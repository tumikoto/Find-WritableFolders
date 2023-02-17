#
# Script to look for user-writable directories for persistence options where arbitrary paths can be used (run, startup, task, COM hijack, etc)
#

Write-Host " "

# Sanity checks
if (!(get-module NTFSSecurity)) {
	Write-Host "[!] Module NTFSSecurity not installed, aborting"
	Write-Host " "
	exit
}

# Init
Import-Module NTFSSecurity
$recursiveDirs = @()
$recursiveDirs += $env:userprofile + '\Desktop'
$recursiveDirs += $env:userprofile + '\Downloads'
$recursiveDirs += $env:userprofile + '\Documents'
$recursiveDirs += $env:userprofile + '\AppData\Roaming'
$recursiveDirs += $env:userprofile + '\AppData\Local'
$recursiveDirs += 'C:\ProgramData'
$recursiveDirs += 'C:\Program Files'
$recursiveDirs += 'C:\Program Files (x86)'
$nonRecursiveDirs = @()
$nonRecursiveDirs += 'C:\'

# Recursive function to check folders for user-writable subdirs
function getWritableDirs($dir) {
	if (Test-Path $dir) {
		($useraccess  = Get-NTFSEffectiveAccess $dir) *> $null
		if ($useraccess.AccessRights -in ("Modify","Write","FullControl")) {
			Write-Host $dir
		}
		$subDirs = Get-ChildItem -Path $dir -Directory -Recurse | select -ExpandProperty fullname
		if ($subDirs)
		{
			foreach ($subDir in $subDirs)
			{
				($subdiruseraccess  = Get-NTFSEffectiveAccess $subDir) *> $null
				if ($subdiruseraccess.AccessRights -in ("Modify","Write","FullControl")) {
					Write-Host $subDir
				}
			}
		}
	}
}

# Looking for user-writable directories
Write-Host "[+] Looking for user-writable directories"
Write-Host " "
foreach ($dir in $nonRecursiveDirs) {
	if (Test-Path $dir) {
		($useraccess  = Get-NTFSEffectiveAccess $dir) *> $null
		if ($useraccess.AccessRights -in ("Modify","Write","FullControl")) {
			Write-Host $dir
		}
		$subDirs = Get-ChildItem -Path $dir -Directory | select -ExpandProperty fullname
		if ($subDirs)
		{
			foreach ($subDir in $subDirs)
			{
				($subdiruseraccess  = Get-NTFSEffectiveAccess $subDir) *> $null
				if ($subdiruseraccess.AccessRights -in ("Modify","Write","FullControl")) {
					Write-Host $subDir
				}
			}
		}
	}
}
foreach ($dir in $recursiveDirs) {
	getWritableDirs $dir
}

# Done
Write-Host " "
Write-Host "[+] Done!"
Write-Host " "

