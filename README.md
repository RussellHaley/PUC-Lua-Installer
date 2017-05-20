# PUC-Lua Installer v1.1 (MinGW Build)

This project is an open source Windows installer for 32 Lua. 

Requirements:
Microsoft .Net 3.5.1 (In Windows 8+ this must be "turned on" in Windows Features (Windows Key + type "Turn Windows Features" and the system will find it).
Wix Toolset 3.11 - http://wixtoolset.org/releases/

Optionally:
SharpDevelop 5.x - http://www.icsharpcode.net/OpenSource/SD/Download/Default.aspx#SharpDevelop5x
	- Microsoft .Net 4.5
	- vcredist
OR
Visual Studio 2008+ (Not Tested)
OR
MonoDevelop (Not Tested)

*Note: If you are using the optional IDEs noted above, your version of the framework can be higher. For more information see:
https://social.msdn.microsoft.com/Forums/windowsapps/en-US/23a7dc5d-c337-4eed-8af4-c016def5516e/location-of-msbuildexe?forum=msbuild *

First, clone this repo. I have git installed to run from powershell:
mkdir ~/git
cd ~/git
git clone https://github.com/russellhaley/puc-lua-installer


To build the MSI, there are two main steps: Download the target items, and execute the commands.

1) Download and extract the binaries and the sources. From Archives:

JoeDFs Binaries (replacing 5.3.4 with the desired version number):
 https://github.com/joedf/LuaBuilds/tree/gh-pages/PrivateBuild/builds/lua-5.3.4/x86

Lua Sources: https://www.lua.org/ftp/
You will need 7-Zip to extract the archive. 

*Note: Alternatively, you could clone joedf/LuaBuilds and it gives you access to all the binaries and all the sources in one place. The over head is a bit extreme but I'm a lazy sod. That's why I created an installer ;) *


2) Run the following commands in powershell (Note that # is a comment in powershell):

```
#1 Navigate to the dir and source the powershell script. This loads the script for execution.
cd C:\Users\russh\git\PUC-Lua-Installer\Base-Files
. .\pli-tools.ps1

#2 Execute the Create-LuaInstaller funtion loaded by the script. 
Create-LuaInstaller -version "5.3.4" `
-sourceLocation "C:\Users\russh\Downloads\lua-sources\src\" `
-bin32Location  "C:\Users\russh\Downloads\lua-5.3.4\src\bin\" `
-outDir $PWD..\Puc-Lua32 

#3 Move to the main install builder and execute MS Build, which assembles the package.
#  On a 32 bit machine use C:\Windows\Microsoft.Net\Framework\v3.5\MSBuild.exe
cd ..\"PUC-Lua 32"
C:\Windows\Microsoft.Net\Framework64\v3.5\MSBuild.exe 

```

Adjusting version, sourceLocation and bin32Location to suite your downloads. You will recieve one warning; two if using the 32 bit build tools. Neither seemingly affect the output. 

The output will be under ...\PUC-Lua-Installer\PUC-Lua 32\bin
	
Happy Installing!

Russ
