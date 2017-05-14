###PUC-Lua Installer v1.0

This project is an open source Windows installer for "PUC-Lua". 

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

To Build the msi, navigate to the directory containing the solution (.../LuaInstaller) and type
C:\Windows\Microsoft.Net\Framework64\v3.5\MSBuild.exe
	
(If you are using the optional IDEs noted above, your version of the framework can be higher. For more information see:

https://social.msdn.microsoft.com/Forums/windowsapps/en-US/23a7dc5d-c337-4eed-8af4-c016def5516e/location-of-msbuildexe?forum=msbuild 


