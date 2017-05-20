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


function Generate-WixItems { param(
    [string] $sourceDir,
    [string] $filter,
    [string[]] $include,
    [string] $writeDir,
    [string] $componentFile,
    [string] $compRefFile,
    [string] $appendToName="",
    [boolean] $removePrevious=$true
    )

    $compPath = Join-Path $writeDir $componentFile
    $comRefPath = Join-Path $writeDir $compRefFile 
    
    if($removePrevious)
    {
        rm $compPath
        rm $comRefPath
    }

    Get-ChildItem $sourceDir -Filter $filter -File |
        Foreach-Object {
            #$content = Get-Content $_.FullName

            #filter and save content to the original file
            #echo $_.FullName
            #echo $_.Name 
           $Id = [GUID]::NewGuid()
           #echo $Id
   
           $name = $_.Name + $appendToName
   
           $comp = '<Component Id="' + $name + '" Guid="' + $Id + '">'
   
           $file = '    <File Id="' + $name + '" Source="' + $_.FullName + '" KeyPath="yes" Checksum="yes"/>'
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

function Create-LuaInstaller{
param(
    [string] $sourceLocation,
    [string] $bin32Location = "",
    [string] $version = "1.0.0",
    [string] $outDir
    )

    
    if($bin32Location -eq "")
    {
        $bin32Location = Join-Path $sourceLocation "bin"
    }

    Generate-WixItems -sourceDir $sourceLocation -filter "*.*" -writeDir $outDir  -componentFile "source_comps.xml" -compRefFile "source_comprefs.xml"    
     Generate-WixItems -sourceDir $bin32Location -filter "*.*" -writeDir $outDir  -componentFile "binary32_comps.xml" -compRefFile "binary32_comprefs.xml" -appendToName "_32"

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
        "%binary32_dir%" = Get-Content (Join-Path $outDir "binary32_comps.xml");
        "%luainclude_dir%" = Get-Content (Join-Path $outDir "include_comps.xml");
        "%luasource_dir%" = Get-Content (Join-Path $outDir "source_comps.xml");
    }

    $luaSetupReplacements = @{
        "%version%"=$version; 
        "%source_feature%" =  Get-Content (Join-Path $outDir "source_comprefs.xml");
        "%include_feature%"= Get-Content (Join-Path $outDir "include_comprefs.xml");
        "%binary32_feature%" = Get-Content (Join-Path $outDir "binary32_comprefs.xml");
    }

    #$luaFileReplacements
    #$luaSetupReplacements

    rm "..\PUC-Lua 32\Files.wxs"
    rm "..\PUC-Lua 32\Setup.wxs"

    $proj32Dir = ""

    Find-And-Replace -filePath "Files-Template32.wxs" -replacements $luaFileReplacements -outputFile "..\PUC-Lua 32\Files.wxs"
    Find-And-Replace -filePath "Setup-Template32.wxs" -replacements $luaSetupReplacements -outputFile "..\PUC-Lua 32\Setup.wxs"

    echo "Processing Complete." 
}

#export-modulemember -function Create-LuaInstaller