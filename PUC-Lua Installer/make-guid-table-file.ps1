$src = "C:\Users\russh\git\LuaBuilds\PrivateBuild\src\lua-5.3.4\src\bin64"
$files = @()



Get-ChildItem $src -Filter *.* | 
Foreach-Object {

$Id = [GUID]::NewGuid()
$fileItem = New-Object System.Object

$fileItem | Add-Member -type NoteProperty -name FileName -Value $_.Name
$fileItem | Add-Member -type NoteProperty -name Guid -Value $Id
$fileItem | Add-Member -type NoteProperty -name Path -Value $_.Directory

$files += $fileItem
}


$files | ForEach-Object{

    $line = '{'+$_.FileName+'="'+$_.Guid+'",source="' + $_.Path + '"},'

    Write-Host $line
}


