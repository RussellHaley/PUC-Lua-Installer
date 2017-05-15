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
   # Show a default display of this month.
   Show-Calendar

 .Example
   # Display a date range.
   Show-Calendar -Start "March, 2010" -End "May, 2010"

 .Example
   # Highlight a range of days.
   Show-Calendar -HighlightDay (1..10 + 22) -HighlightDate "December 25, 2008"
#>


function Generate-WixItems { param(
    [string] $sourceDir,
    [string] $filter,
    [string] $writeDir,
    [string] $componentFile,
    [string] $compRefFile
    )

    $compPath = Join-Path $writeDir $componentFile
    $comRefPath = Join-Path $writeDir $compRefFile 
    
    rm $compPath
    rm $comRefPath

    Get-ChildItem $sourceDir -Filter $filter | 
        Foreach-Object {
            #$content = Get-Content $_.FullName

            #filter and save content to the original file
            #echo $_.FullName
            #echo $_.Name 
           $Id = [GUID]::NewGuid()
           #echo $Id
   
   
           $comp = '<Component Id="' + $_.Name + '" Guid="' + $Id + '">'
   
           $file = '    <File Id="' + $_.Name + '" Source="' + $_.FullName + '" KeyPath="yes" Checksum="yes"/>'
           $endcomp = '</Component>'
           $compRef = '<ComponentRef Id="' + $_.Name + '"/>' 

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
    [string] $bin64Location = "",
    [string] $bin32Location = "",
    [string] $version = "1.0.0",
    [string] $outDir
    )
     
    if($bin64Location -eq "")
    {
        $bin64Location = Join-Path $sourceLocation "bin64"
    }
    
    if($bin32Location -eq "")
    {
        $bin32Location = Join-Path $sourceLocation "bin32"
    }

    Generate-WixItems -sourceDir $sourceLocation -filter "*.*" -writeDir $outDir  -componentFile "source_comps.xml" -compRefFile "source_comprefs.xml"
    Generate-WixItems -sourceDir $sourceLocation -filter "*.h" -writeDir $outDir  -componentFile "include_comps.xml" -compRefFile "include_comprefs.xml"
    Generate-WixItems -sourceDir $bin64Location -filter "*.*" -writeDir $outDir  -componentFile "binary64_comps.xml" -compRefFile "binary64_comprefs.xml"
    #Generate-WixItems -sourceDir $bin32Location -filter "*.*" -writeDir $outDir  -componentFile "binary32_comps.xml" -compRefFile "binary32_comprefs.xml"

    $tmp = Join-Path $outDir "source_comps.xml"
    $content = Get-Content $tmp

    $luaFileReplacements = @{
        "%version%" = $version; 
        "%binary64_dir%" = Get-Content (Join-Path $outDir "binary64_comps.xml");
        #"%binary32_dir%" = Get-Content (Join-Path $outDir "binary32_comps.xml");
        "%luainclude_dir%" = Get-Content (Join-Path $outDir "include_comps.xml");
        "%luasource_dir%" = Get-Content (Join-Path $outDir "source_comps.xml");
    }

    $luaSetupReplacements = @{
        "%version%"=$version; 
        "%source_feature%" =  Get-Content (Join-Path $outDir "source_comprefs.xml");
        "%include_feature%"= Get-Content (Join-Path $outDir "include_comprefs.xml");
        "%binary64_feature%" = Get-Content (Join-Path $outDir "binary64_comprefs.xml");
        #"%binary32_feature%" = Get-Content (Join-Path $outDir "binary32_comprefs.xml");
    }

    #$luaFileReplacements
    #$luaSetupReplacements

    Find-And-Replace -filePath "Files-Template.wxs" -replacements $luaFileReplacements -outputFile "Filetest.wxs"
    Find-And-Replace -filePath "Setup-Template.wxs" -replacements $luaSetupReplacements -outputFile "Setuptest.wxs"

    echo "Processing Complete." 
}

#export-modulemember -function Create-LuaInstaller