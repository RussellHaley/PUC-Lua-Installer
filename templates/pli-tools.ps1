<# 
 .Synopsis
  Creates WIX Components and ComponentRef lists for the directory

 .Description
  Creates WIX Components and ComponentRef lists for the directory

	  [string] $sourceLocation,
	[string] $version,
	[string] $outDir

 .Parameter sourceLocation
  Location of the lua source files.

 .Parameter version
  Lua version to install

 .Parameter outDir
  Output directory for installer AND intermediary files for debugging

 .Example
  
#>


#This function scans a directory and creates 
#WIX entries in two xml files, one for the Component/files list,
#and one for the list of component references. 
#sourceDir - The directory to scan
#filter - a file fileter: i.e. *.h
#include - ?
#writeDirt - The output directory
#componentFile - the nameof the file that contains the components/files list
#compRefFile - The name of the file that contains the ComponentReference items for the features list
function Generate-WixItems { param(
	[string] $sourceDir,
	[string] $binDir="",
	[string] $filter,
	[string[]] $include,
	[string] $writeDir,
	[string] $componentFile,
	[string] $compRefFile,
	[string] $appendToName="",
	[boolean] $removePrevious=$true
	)

	#Create the output paths
	$compPath = Join-Path $writeDir $componentFile
	$comRefPath = Join-Path $writeDir $compRefFile 
	
	#remove previous files
	if($removePrevious)
	{
		rm $compPath
		rm $comRefPath
	}

	
	
	Get-ChildItem $(Join-Path $sourceDir $binDir) -Filter $filter -File |
		Foreach-Object {
			#$content = Get-Content $_.FullName

			#filter and save content to the original file
			#echo $_.FullName
			#echo $_.Name 
		   $Id = [GUID]::NewGuid()
		   #echo $Id
   
		   $name = $_.Name + $appendToName
   
		   $comp = '<Component Id="' + $name + '" Guid="' + $Id + '">'
			
			$source = $_.FullName
			if($binDir -ne "")
			{
				#single quotes stops the $(...) from expanding
				$source = $sourceDir + "\" + '$(var.Platform)\' + $_.Name
			}

		   $file = '    <File Id="' + $name + '" Source="' + $source + '" KeyPath="yes" Checksum="yes"/>'
		   $endcomp = '</Component>'
		   $compRef = '<ComponentRef Id="' + $name + '"/>' 

		   #echo $comp
		   #echo $file
		   #echo $endcomp
   
   
			Add-Content $compPath $comp   
			Add-Content $compPath $file
			Add-Content $compPath $endcomp
			Add-Content $comRefPath $compRef
			#filter and save content to a new file     
		}

}

#Use Regex to perform simple find and replace
function Find-And-Replace{
param(
[string] $filePath,
$replacements,
[string] $outputFile
)


# Join all (escaped) keys from the hashtable into one regular expression.
[regex]$r = @($replacements.Keys | foreach { [regex]::Escape( $_ ) }) -join '|'

[scriptblock]$matchEval = { param( [Text.RegularExpressions.Match]$matchInfo )
  # Return replacement value for each matched value.
  $matchedValue = $matchInfo.Groups[0].Value
  $replacements[$matchedValue]
}

# Perform replace over every line in the file and append to log.
Get-Content $filePath |
  foreach { $r.Replace( $_, $matchEval ) } |
  Add-Content $outputFile

}


function Create-LuaRocksSetup_wxs{}

function Create-LuaRocksFiles_wxs{}

#Create the installer
function Create-LuaInstaller{
param(
	[string] $sourceLocation,
	[string] $binBasePath = "",
	[string] $binDirectory = "bin",
	#[string] $bin64Directory = "bin64",
	[string] $srcVersion = "1.0.0",
	[string] $outDir
	)

	
	#First, Generate the installer components for the source file
	Generate-WixItems -sourceDir $sourceLocation -filter "*.*" -writeDir $outDir  -componentFile "source_comps.xml" -compRefFile "source_comprefs.xml"    
	#Then, Generate theh binary items. Only generate for ONE platform as we will be replacing the 32/64 location via Visual Studio macros 
	Generate-WixItems -sourceDir $binBasePath -binDir $binDirectory -filter "*.*" -writeDir $outDir  -componentFile "binary_comps.xml" -compRefFile "binary_comprefs.xml" #-appendToName "_32"


	#Hard to specify multiple items.     
	Generate-WixItems -sourceDir $sourceLocation -filter "lua.h" -removePrevious $true -writeDir $outDir  -componentFile "include_comps.xml" -compRefFile "include_comprefs.xml" -appendToName "_h"
	Generate-WixItems -sourceDir $sourceLocation -filter "lualib.h" -removePrevious $false -writeDir $outDir  -componentFile "include_comps.xml" -compRefFile "include_comprefs.xml" -appendToName "_h"
	Generate-WixItems -sourceDir $sourceLocation -filter "lauxlib.h" -removePrevious $false -writeDir $outDir  -componentFile "include_comps.xml" -compRefFile "include_comprefs.xml" -appendToName "_h"
	Generate-WixItems -sourceDir $sourceLocation -filter "luaconf.h" -removePrevious $false -writeDir $outDir  -componentFile "include_comps.xml" -compRefFile "include_comprefs.xml" -appendToName "_h"
	Generate-WixItems -sourceDir $sourceLocation -filter "lua.hpp" -removePrevious $false -writeDir $outDir  -componentFile "include_comps.xml" -compRefFile "include_comprefs.xml" -appendToName "_h"
	

	$tmp = Join-Path $outDir "source_comps.xml"
	$content = Get-Content $tmp

	$luaFileReplacements = @{
		"%version%" = $version; 
		"%binary_dir%" = Get-Content (Join-Path $outDir "binary_comps.xml");
		"%luainclude_dir%" = Get-Content (Join-Path $outDir "include_comps.xml");
		"%luasource_dir%" = Get-Content (Join-Path $outDir "source_comps.xml");
	}

	$luaSetupReplacements = @{
		"%version%"=$version; 
		"%source_feature%" =  Get-Content (Join-Path $outDir "source_comprefs.xml");
		"%include_feature%"= Get-Content (Join-Path $outDir "include_comprefs.xml");
		"%binary_feature%" = Get-Content (Join-Path $outDir "binary_comprefs.xml");
	}

	#$luaFileReplacements
	#$luaSetupReplacements

	#THIS IS HARD CODED. 
	$setupFile = "Setup.wxs"
	$fileFile = "Files.wxs"
	
	rm $(join-path $outDir $setupFile)
	rm $(join-path $outDir $fileFile)
	#rm "..\PUC-Lua-Installer\Setup.wxs"

	$proj32Dir = ""

	Find-And-Replace -filePath "templates\Files-Template.wxs" -replacements $luaFileReplacements -outputFile $(join-path $outDir $fileFile)
	Find-And-Replace -filePath "templates\Setup-Template.wxs" -replacements $luaSetupReplacements -outputFile $(join-path $outDir $setupFile)

	echo "Processing Complete." 
}

#export-modulemember -function Create-LuaInstaller

Create-LuaInstaller `
-sourceLocation "N:\lua-temp\lua-5.3.4\src" `
-binBasePath  "N:\lua-temp\lua-5.3.4\src\bin" `
-binDirectory "x86" `
-srcVersion = "5.3.4" `
-outDir "C:\Users\russh\git\PUC-Lua-Installer"

#Create-LuaInstaller `
#-sourceLocation "N:\lua-temp\lua-5.3.4\src" `
#-binBasePath  "N:\lua-temp\lua-5.3.4\src\bin" `
#-binDirectory "x86" `
#-srcVersion = "5.3.4" `
#-outDir "N:\lua-temp"