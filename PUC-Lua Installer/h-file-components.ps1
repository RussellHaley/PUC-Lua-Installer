$homedir = $PWD

$comps_file = "includes.xml"
$comprefs_file = "comps.xml"

$install_part = "incl"
$writefile = $PWD.Path + '\' + $install_part + '_' + $comps_file
$compfile = $PWD.Path + '\' + $install_part + '_' + $comprefs_file
echo $writefile

$src = "C:\Users\russh\git\LuaBuilds\PrivateBuild\src\lua-5.3.4\src"
#cd $src 
rm $writefile
rm $compfile

Get-ChildItem $src -Filter *.h | 
Foreach-Object {
    #$content = Get-Content $_.FullName

    #filter and save content to the original file
    #echo $_.FullName
    echo $_.Name 
   $Id = [GUID]::NewGuid()
   echo $Id
   
   
   $comp = '<Component Id="' + $_.Name + '" Guid="' + $Id + '">'
   
   $file = '    <File Id="' + $_.Name + '" Source="' + $_.FullName + '" KeyPath="yes" Checksum="yes"/>'
   $endcomp = '</Component>'
   $compRef = '<ComponentRef Id="' + $_.Name + '"/>' 

   echo $comp
   echo $file
   echo $endcomp
   
   
    Add-Content $writefile $comp   
    Add-Content $writefile $file
    Add-Content $writefile $endcomp
    Add-Content $compfile $compRef
    #filter and save content to a new file     
}

$install_part = "src"
$writefile = $PWD.Path + '\' + $install_part + '_' + $comps_file
$compfile = $PWD.Path + '\' + $install_part + '_' + $comprefs_file
echo $writefile

$src = "C:\Users\russh\git\LuaBuilds\PrivateBuild\src\lua-5.3.4\src"
#cd $src 
rm $writefile
rm $compfile

Get-ChildItem $src -Filter *.* | 
Foreach-Object {
    #$content = Get-Content $_.FullName

    #filter and save content to the original file
    #echo $_.FullName
    echo $_.Name 
   $Id = [GUID]::NewGuid()
   echo $Id
   
   
   $comp = '<Component Id="' + $_.Name + '" Guid="' + $Id + '">'
   
   $file = '    <File Id="' + $_.Name + '" Source="' + $_.FullName + '" KeyPath="yes" Checksum="yes"/>'
   $endcomp = '</Component>'
   $compRef = '<ComponentRef Id="' + $_.Name + '"/>' 

   echo $comp
   echo $file
   echo $endcomp
   
   
    Add-Content $writefile $comp   
    Add-Content $writefile $file
    Add-Content $writefile $endcomp
    Add-Content $compfile $compRef
    #filter and save content to a new file     
}

$install_part = "bin"
$writefile = $PWD.Path + '\' + $install_part + '_' + $comps_file
$compfile = $PWD.Path + '\' + $install_part + '_' + $comprefs_file

rm $writefile
rm $compfile

$src = "C:\Users\russh\git\LuaBuilds\PrivateBuild\src\lua-5.3.4\src\bin64"

Get-ChildItem $src -Filter *.* | 
Foreach-Object {
    #$content = Get-Content $_.FullName

    #filter and save content to the original file
    #echo $_.FullName
    echo $_.Name 
   $Id = [GUID]::NewGuid()
   echo $Id
   
   
   $comp = '<Component Id="' + $_.Name + '" Guid="' + $Id + '">'
   
   $file = '    <File Id="' + $_.Name + '" Source="' + $_.FullName + '" KeyPath="yes" Checksum="yes"/>'
   $endcomp = '</Component>'
   $compRef = '<ComponentRef Id="' + $_.Name + '"/>' 

   echo $comp
   echo $file
   echo $endcomp
   
   
    Add-Content $writefile $comp   
    Add-Content $writefile $file
    Add-Content $writefile $endcomp
    Add-Content $compfile $compRef
    #filter and save content to a new file     
}

